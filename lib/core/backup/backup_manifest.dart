/// Версия приложения для манифеста (информационно). Совпадает с pubspec.
const String kAppVersion = '1.0.0';

/// Манифест архива `.kiseki` (TECH_DESIGN §8.1). Правила чтения:
/// `formatVersion` новее приложения → отказ; `schemaVersion` старее → restore
/// + штатный Drift `onUpgrade`; новее → отказ.
class BackupManifest {
  const BackupManifest({
    required this.formatVersion,
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAtMs,
    required this.counts,
    required this.integrity,
  });

  /// Версия нашего формата архива.
  final int formatVersion;

  /// `schemaVersion` Drift на момент снимка.
  final int schemaVersion;

  final String appVersion;

  /// Время создания (Unix-мс UTC).
  final int createdAtMs;

  /// Счётчики содержимого (items/tags/images…).
  final Map<String, int> counts;

  /// sha256 каждого файла в архиве (имя → hex-дайджест).
  final Map<String, String> integrity;

  Map<String, dynamic> toJson() => {
        'format_version': formatVersion,
        'schema_version': schemaVersion,
        'app_version': appVersion,
        'created_at': createdAtMs,
        'counts': counts,
        'integrity': integrity,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) => BackupManifest(
        formatVersion: json['format_version'] as int,
        schemaVersion: json['schema_version'] as int,
        appVersion: json['app_version'] as String? ?? '?',
        createdAtMs: json['created_at'] as int,
        counts: Map<String, int>.from(json['counts'] as Map? ?? const {}),
        integrity:
            Map<String, String>.from(json['integrity'] as Map? ?? const {}),
      );
}
