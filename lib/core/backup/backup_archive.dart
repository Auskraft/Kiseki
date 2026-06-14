import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import '../images/media_paths.dart';
import 'backup_manifest.dart';

/// Ошибка формата/целостности архива (для понятного сообщения в UI).
class BackupException implements Exception {
  const BackupException(this.message);
  final String message;
  @override
  String toString() => 'BackupException: $message';
}

/// Распакованный и проверенный архив: манифест + временный каталог с
/// `snapshot.sqlite` и `images/`. Каталог удаляет вызывающий ([dispose]).
class UnpackedBackup {
  UnpackedBackup({required this.manifest, required this.dir});

  final BackupManifest manifest;
  final Directory dir;

  File get snapshot => File(p.join(dir.path, 'snapshot.sqlite'));
  Directory get imagesDir => Directory(p.join(dir.path, 'images'));

  Future<void> dispose() async {
    if (dir.existsSync()) await dir.delete(recursive: true);
  }
}

/// Сборка/разбор архива `.kiseki` (ZIP: snapshot.sqlite + images/ + manifest.json
/// + sha256-целостность). TECH_DESIGN §8.1.
class BackupArchive {
  BackupArchive(this._db, this._paths, {DateTime Function()? clock})
      : _now = clock ?? DateTime.now;

  final AppDatabase _db;
  final MediaPaths _paths;
  final DateTime Function() _now;

  static const String remoteFileName = 'kiseki_backup.kiseki';
  static const int formatVersion = 1;

  /// Упаковывает текущее состояние в архив (bytes). Картинки берутся как есть
  /// (пока C2 не сделан — обычно их нет).
  Future<Uint8List> pack() async {
    final tmp = await Directory.systemTemp.createTemp('kiseki_pack_');
    try {
      final snapPath = p.join(tmp.path, 'snapshot.sqlite');
      await _db.snapshotInto(snapPath);

      final archive = Archive();
      final integrity = <String, String>{};

      void add(String name, List<int> bytes) {
        archive.addFile(ArchiveFile(name, bytes.length, bytes));
        integrity[name] = sha256.convert(bytes).toString();
      }

      add('snapshot.sqlite', await File(snapPath).readAsBytes());

      var imageFiles = 0;
      for (final dir in [_paths.fullDir, _paths.thumbDir]) {
        if (!dir.existsSync()) continue;
        final sub = p.basename(dir.path); // full | thumb
        for (final f in dir.listSync().whereType<File>()) {
          add('images/$sub/${p.basename(f.path)}', await f.readAsBytes());
          imageFiles++;
        }
      }

      final counts = await _counts()..['image_files'] = imageFiles;
      final manifest = BackupManifest(
        formatVersion: formatVersion,
        schemaVersion: _db.schemaVersion,
        appVersion: kAppVersion,
        createdAtMs: _now().toUtc().millisecondsSinceEpoch,
        counts: counts,
        integrity: integrity,
      );
      final mbytes = utf8.encode(jsonEncode(manifest.toJson()));
      archive.addFile(ArchiveFile('manifest.json', mbytes.length, mbytes));

      final zipped = ZipEncoder().encode(archive);
      if (zipped == null) {
        throw const BackupException('Не удалось упаковать архив');
      }
      return Uint8List.fromList(zipped);
    } finally {
      await tmp.delete(recursive: true);
    }
  }

  /// Разбирает и валидирует архив (формат, наличие снимка, sha256-целостность),
  /// распаковывает во временный каталог. Бросает [BackupException] при проблеме.
  Future<UnpackedBackup> unpack(Uint8List bytes) async {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const BackupException('Файл не распознан как архив Kiseki');
    }

    // Любая ошибка инфляции/IO ниже → понятная BackupException.
    try {
      final manifestFile = archive.findFile('manifest.json');
      if (manifestFile == null) {
        throw const BackupException('В архиве нет manifest.json');
      }
      final manifest = BackupManifest.fromJson(
        jsonDecode(utf8.decode(manifestFile.content as List<int>))
            as Map<String, dynamic>,
      );

      if (manifest.formatVersion > formatVersion) {
        throw const BackupException(
            'Архив создан более новой версией приложения');
      }
      if (archive.findFile('snapshot.sqlite') == null) {
        throw const BackupException('В архиве нет снимка базы');
      }

      for (final entry in manifest.integrity.entries) {
        final f = archive.findFile(entry.key);
        if (f == null) {
          throw BackupException('В архиве нет файла ${entry.key}');
        }
        final digest = sha256.convert(f.content as List<int>).toString();
        if (digest != entry.value) {
          throw BackupException('Файл повреждён: ${entry.key}');
        }
      }

      final tmp = await Directory.systemTemp.createTemp('kiseki_unpack_');
      for (final f in archive.files) {
        if (!f.isFile) continue;
        final out = File(p.join(tmp.path, f.name));
        out.parent.createSync(recursive: true);
        await out.writeAsBytes(f.content as List<int>);
      }
      return UnpackedBackup(manifest: manifest, dir: tmp);
    } on BackupException {
      rethrow;
    } catch (_) {
      throw const BackupException('Архив повреждён');
    }
  }

  Future<Map<String, int>> _counts() async {
    Future<int> count(String table) async {
      final row =
          await _db.customSelect('SELECT COUNT(*) AS c FROM $table').getSingle();
      return row.read<int>('c');
    }

    return {
      'items': await count('catalog_items'),
      'tags': await count('tags'),
      'images': await count('images'),
    };
  }
}
