/// Структурированная причина «не досмотрел» (ядро). Осмыслена при статусах
/// `paused`/`dropped`. Важно: `waitingEpisodes` («жду серии») — это пауза,
/// не заброс (TECH_DESIGN §6.3). Детали причины пишутся в общий `note`.
enum UnfinishedReason {
  waitingEpisodes('waiting_episodes'),
  lostQuality('lost_quality'),
  notForMe('not_for_me'),
  noTime('no_time'),
  other('other');

  const UnfinishedReason(this.code);

  final String code;

  static UnfinishedReason fromCode(String code) => values.firstWhere(
        (e) => e.code == code,
        orElse: () => throw ArgumentError('Unknown UnfinishedReason code: $code'),
      );
}
