import 'package:flutter/material.dart';

import '../core/backup/backup_archive.dart';
import '../core/backup/yandex_disk_service.dart';
import '../core/error/failures.dart';
import '../core/theme/app_dimens.dart';
import '../core/theme/theme_context.dart';
import '../core/ui/confirm_sheet.dart';
import 'di/injector.dart';
import 'restore_flow.dart';

/// Экран восстановления при повреждённой/неоткрываемой БД (TECH_DESIGN §9).
/// Показывается [AppBootstrap] вместо приложения, когда `quick_check` не 'ok'.
/// Варианты: восстановить из бэкапа Я.Диска или начать заново (стереть).
/// При успехе любого из действий дерево перезапускается (RestartWidget),
/// [AppBootstrap] перепроверяет БД и пускает в приложение.
class DbRecoveryScreen extends StatefulWidget {
  const DbRecoveryScreen({super.key, this.detail});

  /// Техническая причина (сообщение sqlite/миграции либо результат quick_check)
  /// — показывается мелким текстом для диагностики.
  final String? detail;

  @override
  State<DbRecoveryScreen> createState() => _DbRecoveryScreenState();
}

class _DbRecoveryScreenState extends State<DbRecoveryScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _restore() async {
    final disk = getIt<YandexDiskService>();
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (!disk.isLinked) {
        final ok = await disk.loginWithBrowser();
        if (!ok) {
          if (mounted) {
            setState(() {
              _busy = false;
              _error = 'Не удалось подключить Я.Диск';
            });
          }
          return;
        }
      }
      if (!mounted) return;
      await runRestore(context); // успех → дерево перезапущено
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = switch (e) {
          BackupException b => b.message,
          Failure f => f.message,
          _ => 'Не удалось восстановить',
        };
      });
    }
  }

  Future<void> _wipe() async {
    final ok = await showConfirmDeleteSheet(
      context,
      title: 'Начать заново?',
      message: 'Локальные данные будут стёрты безвозвратно. '
          'Выбирайте, только если восстановить не получается.',
      confirmLabel: 'Стереть',
    );
    if (!ok || !mounted) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await runWipeAndRestart(context); // успех → дерево перезапущено
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Не удалось сбросить данные';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tk = context.tokens;
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tk.tint(tk.error, 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.report_gmailerrorred_rounded,
                      size: 38, color: tk.error),
                ),
                const SizedBox(height: 20),
                Text('Не удалось открыть базу',
                    style: text.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  'Файл данных повреждён. Восстановите карточки из резервной '
                  'копии на Я.Диске или начните заново.',
                  style: text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                if (widget.detail != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: tk.surface2,
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(color: tk.outlineSoft),
                    ),
                    child: SelectableText(
                      widget.detail!,
                      style: text.bodySmall?.copyWith(color: tk.onMuted),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: tk.tint(tk.error, 0.10),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                    ),
                    child: Text(_error!,
                        style: text.bodySmall?.copyWith(color: tk.error),
                        textAlign: TextAlign.center),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _busy ? null : _restore,
                    icon: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.settings_backup_restore_rounded,
                            size: 19),
                    label: Text(_busy ? 'Подождите…' : 'Восстановить из бэкапа'),
                  ),
                ),
                const SizedBox(height: 6),
                TextButton(
                  onPressed: _busy ? null : _wipe,
                  child: Text('Начать заново',
                      style: TextStyle(color: tk.onMuted)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
