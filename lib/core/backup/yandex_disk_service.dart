import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_links/app_links.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../error/failures.dart';

/// Результат проверки авторизации: подключён / реально отключён (нет токена
/// или 401/403) / связь не удалось проверить (токен есть, но сеть моргнула).
enum YandexAuthStatus { authenticated, unauthenticated, networkError }

/// Доступ к Яндекс.Диску для бэкапа Kiseki: OAuth 2.0 (Implicit Flow,
/// токен в `#fragment` через deep link) + REST загрузка/скачивание архива
/// в папку приложения (`app:/`, scope `cloud_api:disk.app_folder`).
///
/// Зарегистрировано в Яндекс ID: client_id ниже, redirect — кастомная схема
/// `com.auskraft.kiseki://oauth` (intent-filter в AndroidManifest).
class YandexDiskService {
  YandexDiskService(this._prefs);

  final SharedPreferences _prefs;

  static const _clientId = 'ba3daa2a2499480d8089db0e558bd118';
  static const _scheme = 'com.auskraft.kiseki';
  static const _redirectUri = '$_scheme://oauth';
  static const _backupPath = 'app:/kiseki_backup.kiseki';

  static const _tokenKey = 'yandex_disk_token';
  static const _displayNameKey = 'yandex_disk_display_name';
  static const _lastBackupKey = 'yandex_last_backup';

  static const _apiTimeout = Duration(seconds: 30);

  /// Выполняет HTTP-запрос, мапя транспортные сбои (таймаут/нет сети) в
  /// типизированный [NetworkFailure] — чтобы UI показал понятное действие.
  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      return await call();
    } on TimeoutException {
      throw const NetworkFailure();
    } on SocketException {
      throw const NetworkFailure();
    } on http.ClientException {
      throw const NetworkFailure();
    }
  }

  /// Мапит не-успешный HTTP-код в типизированный [Failure]: мёртвый токен →
  /// переавторизация, прочее → сетевой сбой с кодом.
  Never _failStatus(int code) {
    if (code == 401 || code == 403) throw const AuthExpiredFailure();
    throw NetworkFailure('Я.Диск вернул $code');
  }

  // ─── OAuth (браузер → deep link) ─────────────────────────────

  /// Открывает браузер для авторизации и ждёт возврата по deep link.
  /// Возвращает `true`, если получили токен.
  Future<bool> loginWithBrowser() async {
    final url = Uri.https('oauth.yandex.ru', '/authorize', {
      'response_type': 'token',
      'client_id': _clientId,
      'redirect_uri': _redirectUri,
      // Принудительный экран подтверждения — чтобы можно было выбрать аккаунт.
      'force_confirm': 'yes',
    });

    final completer = Completer<bool>();
    final appLinks = AppLinks();
    late StreamSubscription<Uri> sub;
    sub = appLinks.uriLinkStream.listen((uri) async {
      if (uri.scheme == _scheme && uri.host == 'oauth') {
        await sub.cancel();
        final params = Uri.splitQueryString(uri.fragment);
        final token = params['access_token'];
        if (token != null && token.isNotEmpty) {
          await _prefs.setString(_tokenKey, token);
          unawaited(getDisplayName(forceRefresh: true));
          if (!completer.isCompleted) completer.complete(true);
        } else if (!completer.isCompleted) {
          completer.complete(false);
        }
      }
    });

    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Браузер не открылся — отменяем подписку (иначе утечка) и пробрасываем.
      await sub.cancel();
      rethrow;
    }

    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        sub.cancel();
        return false;
      },
    );
  }

  Future<YandexAuthStatus> checkAuthStatus() async {
    final token = _token();
    if (token == null || token.isEmpty) return YandexAuthStatus.unauthenticated;
    try {
      final resp = await http.get(
        Uri.parse('https://cloud-api.yandex.net/v1/disk'),
        headers: {'Authorization': 'OAuth $token'},
      ).timeout(_apiTimeout);
      if (resp.statusCode == 200) return YandexAuthStatus.authenticated;
      if (resp.statusCode == 401 || resp.statusCode == 403) {
        return YandexAuthStatus.unauthenticated; // токен мёртв
      }
      return YandexAuthStatus.networkError;
    } catch (_) {
      return YandexAuthStatus.networkError;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_displayNameKey);
    await _prefs.remove(_lastBackupKey);
  }

  bool get isLinked => (_token() ?? '').isNotEmpty;

  /// «Человеческое» имя аккаунта (display_name → login → email). Кэшируется.
  Future<String?> getDisplayName({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _prefs.getString(_displayNameKey);
      if (cached != null && cached.isNotEmpty) return cached;
    }
    final token = _token();
    if (token == null) return null;
    try {
      final resp = await http.get(
        Uri.parse('https://login.yandex.ru/info?format=json'),
        headers: {'Authorization': 'OAuth $token'},
      ).timeout(_apiTimeout);
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final name = (data['display_name'] as String?) ??
          (data['login'] as String?) ??
          (data['default_email'] as String?);
      if (name != null && name.isNotEmpty) {
        await _prefs.setString(_displayNameKey, name);
        return name;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ─── Бэкап / восстановление архива ───────────────────────────

  /// Заливает архив в папку приложения (перезапись).
  Future<void> uploadBackup(Uint8List bytes) async {
    final token = _requireToken();
    final linkResp = await _send(() => http.get(
          Uri.parse('https://cloud-api.yandex.net/v1/disk/resources/upload')
              .replace(
                  queryParameters: {'path': _backupPath, 'overwrite': 'true'}),
          headers: {'Authorization': 'OAuth $token'},
        ).timeout(_apiTimeout));
    if (linkResp.statusCode != 200) _failStatus(linkResp.statusCode);
    final href = (jsonDecode(linkResp.body) as Map<String, dynamic>)['href']
        as String?;
    if (href == null) throw Exception('Не удалось получить ссылку загрузки');

    final putResp = await _send(
        () => http.put(Uri.parse(href), body: bytes).timeout(_apiTimeout));
    if (putResp.statusCode != 201 &&
        putResp.statusCode != 202 &&
        putResp.statusCode != 200) {
      _failStatus(putResp.statusCode);
    }
    await _prefs.setString(_lastBackupKey, DateTime.now().toIso8601String());
  }

  /// Скачивает архив. `null` — копии ещё нет (404).
  Future<Uint8List?> downloadBackup() async {
    final token = _requireToken();
    final linkResp = await _send(() => http.get(
          Uri.parse('https://cloud-api.yandex.net/v1/disk/resources/download')
              .replace(queryParameters: {'path': _backupPath}),
          headers: {'Authorization': 'OAuth $token'},
        ).timeout(_apiTimeout));
    if (linkResp.statusCode == 404) return null;
    if (linkResp.statusCode != 200) _failStatus(linkResp.statusCode);
    final href = (jsonDecode(linkResp.body) as Map<String, dynamic>)['href']
        as String?;
    if (href == null) throw Exception('Не удалось получить ссылку скачивания');

    final fileResp =
        await _send(() => http.get(Uri.parse(href)).timeout(_apiTimeout));
    if (fileResp.statusCode != 200) _failStatus(fileResp.statusCode);
    return fileResp.bodyBytes;
  }

  /// Время последней успешной загрузки с этого устройства.
  DateTime? lastBackupTime() {
    final s = _prefs.getString(_lastBackupKey);
    return s == null ? null : DateTime.tryParse(s);
  }

  String? _token() => _prefs.getString(_tokenKey);

  String _requireToken() {
    final t = _token();
    if (t == null || t.isEmpty) {
      throw Exception('Не авторизован в Яндекс.Диске');
    }
    return t;
  }
}
