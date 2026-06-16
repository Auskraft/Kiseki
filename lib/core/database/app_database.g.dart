// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CatalogItemsTable extends CatalogItems
    with TableInfo<$CatalogItemsTable, CatalogItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CatalogItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<CatalogDomain, String> domain =
      GeneratedColumn<String>(
        'domain',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CatalogDomain>($CatalogItemsTable.$converterdomain);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 500,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<WatchStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<WatchStatus>($CatalogItemsTable.$converterstatus);
  @override
  late final GeneratedColumnWithTypeConverter<UnfinishedReason?, String>
  unfinishedReason =
      GeneratedColumn<String>(
        'unfinished_reason',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<UnfinishedReason?>(
        $CatalogItemsTable.$converterunfinishedReasonn,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _eventCountMeta = const VerificationMeta(
    'eventCount',
  );
  @override
  late final GeneratedColumn<int> eventCount = GeneratedColumn<int>(
    'event_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> startedAt =
      GeneratedColumn<int>(
        'started_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CatalogItemsTable.$converterstartedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DatePrecision?, String>
  startedAtPrec = GeneratedColumn<String>(
    'started_at_prec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<DatePrecision?>($CatalogItemsTable.$converterstartedAtPrecn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastActivityAt =
      GeneratedColumn<int>(
        'last_activity_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CatalogItemsTable.$converterlastActivityAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DatePrecision?, String>
  lastActivityAtPrec =
      GeneratedColumn<String>(
        'last_activity_at_prec',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DatePrecision?>(
        $CatalogItemsTable.$converterlastActivityAtPrecn,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> finishedAt =
      GeneratedColumn<int>(
        'finished_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CatalogItemsTable.$converterfinishedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DatePrecision?, String>
  finishedAtPrec = GeneratedColumn<String>(
    'finished_at_prec',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<DatePrecision?>($CatalogItemsTable.$converterfinishedAtPrecn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CatalogItemsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($CatalogItemsTable.$converterupdatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($CatalogItemsTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    domain,
    title,
    rating,
    status,
    unfinishedReason,
    note,
    isFavorite,
    eventCount,
    startedAt,
    startedAtPrec,
    lastActivityAt,
    lastActivityAtPrec,
    finishedAt,
    finishedAtPrec,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'catalog_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<CatalogItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('event_count')) {
      context.handle(
        _eventCountMeta,
        eventCount.isAcceptableOrUnknown(data['event_count']!, _eventCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CatalogItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CatalogItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      domain: $CatalogItemsTable.$converterdomain.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}domain'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      status: $CatalogItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      unfinishedReason: $CatalogItemsTable.$converterunfinishedReasonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}unfinished_reason'],
        ),
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      eventCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}event_count'],
      )!,
      startedAt: $CatalogItemsTable.$converterstartedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}started_at'],
        ),
      ),
      startedAtPrec: $CatalogItemsTable.$converterstartedAtPrecn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}started_at_prec'],
        ),
      ),
      lastActivityAt: $CatalogItemsTable.$converterlastActivityAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_activity_at'],
        ),
      ),
      lastActivityAtPrec: $CatalogItemsTable.$converterlastActivityAtPrecn
          .fromSql(
            attachedDatabase.typeMapping.read(
              DriftSqlType.string,
              data['${effectivePrefix}last_activity_at_prec'],
            ),
          ),
      finishedAt: $CatalogItemsTable.$converterfinishedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}finished_at'],
        ),
      ),
      finishedAtPrec: $CatalogItemsTable.$converterfinishedAtPrecn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}finished_at_prec'],
        ),
      ),
      createdAt: $CatalogItemsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $CatalogItemsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      deletedAt: $CatalogItemsTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $CatalogItemsTable createAlias(String alias) {
    return $CatalogItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<CatalogDomain, String> $converterdomain =
      const CatalogDomainConverter();
  static TypeConverter<WatchStatus, String> $converterstatus =
      const WatchStatusConverter();
  static TypeConverter<UnfinishedReason, String> $converterunfinishedReason =
      const UnfinishedReasonConverter();
  static TypeConverter<UnfinishedReason?, String?> $converterunfinishedReasonn =
      NullAwareTypeConverter.wrap($converterunfinishedReason);
  static TypeConverter<DateTime, int> $converterstartedAt =
      const DateTimeMsConverter();
  static TypeConverter<DateTime?, int?> $converterstartedAtn =
      NullAwareTypeConverter.wrap($converterstartedAt);
  static TypeConverter<DatePrecision, String> $converterstartedAtPrec =
      const DatePrecisionConverter();
  static TypeConverter<DatePrecision?, String?> $converterstartedAtPrecn =
      NullAwareTypeConverter.wrap($converterstartedAtPrec);
  static TypeConverter<DateTime, int> $converterlastActivityAt =
      const DateTimeMsConverter();
  static TypeConverter<DateTime?, int?> $converterlastActivityAtn =
      NullAwareTypeConverter.wrap($converterlastActivityAt);
  static TypeConverter<DatePrecision, String> $converterlastActivityAtPrec =
      const DatePrecisionConverter();
  static TypeConverter<DatePrecision?, String?> $converterlastActivityAtPrecn =
      NullAwareTypeConverter.wrap($converterlastActivityAtPrec);
  static TypeConverter<DateTime, int> $converterfinishedAt =
      const DateTimeMsConverter();
  static TypeConverter<DateTime?, int?> $converterfinishedAtn =
      NullAwareTypeConverter.wrap($converterfinishedAt);
  static TypeConverter<DatePrecision, String> $converterfinishedAtPrec =
      const DatePrecisionConverter();
  static TypeConverter<DatePrecision?, String?> $converterfinishedAtPrecn =
      NullAwareTypeConverter.wrap($converterfinishedAtPrec);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeMsConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const DateTimeMsConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const DateTimeMsConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class CatalogItem extends DataClass implements Insertable<CatalogItem> {
  /// UUID v4, генерирует приложение до вставки.
  final String id;
  final CatalogDomain domain;
  final String title;
  final int? rating;
  final WatchStatus status;
  final UnfinishedReason? unfinishedReason;
  final String? note;
  final bool isFavorite;

  /// Обобщённый счётчик «событий»: для медиа — пересмотры (ADR / §4.2).
  final int eventCount;
  final DateTime? startedAt;
  final DatePrecision? startedAtPrec;
  final DateTime? lastActivityAt;
  final DatePrecision? lastActivityAtPrec;
  final DateTime? finishedAt;
  final DatePrecision? finishedAtPrec;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  const CatalogItem({
    required this.id,
    required this.domain,
    required this.title,
    this.rating,
    required this.status,
    this.unfinishedReason,
    this.note,
    required this.isFavorite,
    required this.eventCount,
    this.startedAt,
    this.startedAtPrec,
    this.lastActivityAt,
    this.lastActivityAtPrec,
    this.finishedAt,
    this.finishedAtPrec,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    {
      map['domain'] = Variable<String>(
        $CatalogItemsTable.$converterdomain.toSql(domain),
      );
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    {
      map['status'] = Variable<String>(
        $CatalogItemsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || unfinishedReason != null) {
      map['unfinished_reason'] = Variable<String>(
        $CatalogItemsTable.$converterunfinishedReasonn.toSql(unfinishedReason),
      );
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['event_count'] = Variable<int>(eventCount);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<int>(
        $CatalogItemsTable.$converterstartedAtn.toSql(startedAt),
      );
    }
    if (!nullToAbsent || startedAtPrec != null) {
      map['started_at_prec'] = Variable<String>(
        $CatalogItemsTable.$converterstartedAtPrecn.toSql(startedAtPrec),
      );
    }
    if (!nullToAbsent || lastActivityAt != null) {
      map['last_activity_at'] = Variable<int>(
        $CatalogItemsTable.$converterlastActivityAtn.toSql(lastActivityAt),
      );
    }
    if (!nullToAbsent || lastActivityAtPrec != null) {
      map['last_activity_at_prec'] = Variable<String>(
        $CatalogItemsTable.$converterlastActivityAtPrecn.toSql(
          lastActivityAtPrec,
        ),
      );
    }
    if (!nullToAbsent || finishedAt != null) {
      map['finished_at'] = Variable<int>(
        $CatalogItemsTable.$converterfinishedAtn.toSql(finishedAt),
      );
    }
    if (!nullToAbsent || finishedAtPrec != null) {
      map['finished_at_prec'] = Variable<String>(
        $CatalogItemsTable.$converterfinishedAtPrecn.toSql(finishedAtPrec),
      );
    }
    {
      map['created_at'] = Variable<int>(
        $CatalogItemsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $CatalogItemsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $CatalogItemsTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  CatalogItemsCompanion toCompanion(bool nullToAbsent) {
    return CatalogItemsCompanion(
      id: Value(id),
      domain: Value(domain),
      title: Value(title),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      status: Value(status),
      unfinishedReason: unfinishedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(unfinishedReason),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isFavorite: Value(isFavorite),
      eventCount: Value(eventCount),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      startedAtPrec: startedAtPrec == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAtPrec),
      lastActivityAt: lastActivityAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivityAt),
      lastActivityAtPrec: lastActivityAtPrec == null && nullToAbsent
          ? const Value.absent()
          : Value(lastActivityAtPrec),
      finishedAt: finishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAt),
      finishedAtPrec: finishedAtPrec == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedAtPrec),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory CatalogItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CatalogItem(
      id: serializer.fromJson<String>(json['id']),
      domain: serializer.fromJson<CatalogDomain>(json['domain']),
      title: serializer.fromJson<String>(json['title']),
      rating: serializer.fromJson<int?>(json['rating']),
      status: serializer.fromJson<WatchStatus>(json['status']),
      unfinishedReason: serializer.fromJson<UnfinishedReason?>(
        json['unfinishedReason'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      eventCount: serializer.fromJson<int>(json['eventCount']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      startedAtPrec: serializer.fromJson<DatePrecision?>(json['startedAtPrec']),
      lastActivityAt: serializer.fromJson<DateTime?>(json['lastActivityAt']),
      lastActivityAtPrec: serializer.fromJson<DatePrecision?>(
        json['lastActivityAtPrec'],
      ),
      finishedAt: serializer.fromJson<DateTime?>(json['finishedAt']),
      finishedAtPrec: serializer.fromJson<DatePrecision?>(
        json['finishedAtPrec'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'domain': serializer.toJson<CatalogDomain>(domain),
      'title': serializer.toJson<String>(title),
      'rating': serializer.toJson<int?>(rating),
      'status': serializer.toJson<WatchStatus>(status),
      'unfinishedReason': serializer.toJson<UnfinishedReason?>(
        unfinishedReason,
      ),
      'note': serializer.toJson<String?>(note),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'eventCount': serializer.toJson<int>(eventCount),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'startedAtPrec': serializer.toJson<DatePrecision?>(startedAtPrec),
      'lastActivityAt': serializer.toJson<DateTime?>(lastActivityAt),
      'lastActivityAtPrec': serializer.toJson<DatePrecision?>(
        lastActivityAtPrec,
      ),
      'finishedAt': serializer.toJson<DateTime?>(finishedAt),
      'finishedAtPrec': serializer.toJson<DatePrecision?>(finishedAtPrec),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  CatalogItem copyWith({
    String? id,
    CatalogDomain? domain,
    String? title,
    Value<int?> rating = const Value.absent(),
    WatchStatus? status,
    Value<UnfinishedReason?> unfinishedReason = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? isFavorite,
    int? eventCount,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DatePrecision?> startedAtPrec = const Value.absent(),
    Value<DateTime?> lastActivityAt = const Value.absent(),
    Value<DatePrecision?> lastActivityAtPrec = const Value.absent(),
    Value<DateTime?> finishedAt = const Value.absent(),
    Value<DatePrecision?> finishedAtPrec = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => CatalogItem(
    id: id ?? this.id,
    domain: domain ?? this.domain,
    title: title ?? this.title,
    rating: rating.present ? rating.value : this.rating,
    status: status ?? this.status,
    unfinishedReason: unfinishedReason.present
        ? unfinishedReason.value
        : this.unfinishedReason,
    note: note.present ? note.value : this.note,
    isFavorite: isFavorite ?? this.isFavorite,
    eventCount: eventCount ?? this.eventCount,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    startedAtPrec: startedAtPrec.present
        ? startedAtPrec.value
        : this.startedAtPrec,
    lastActivityAt: lastActivityAt.present
        ? lastActivityAt.value
        : this.lastActivityAt,
    lastActivityAtPrec: lastActivityAtPrec.present
        ? lastActivityAtPrec.value
        : this.lastActivityAtPrec,
    finishedAt: finishedAt.present ? finishedAt.value : this.finishedAt,
    finishedAtPrec: finishedAtPrec.present
        ? finishedAtPrec.value
        : this.finishedAtPrec,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  CatalogItem copyWithCompanion(CatalogItemsCompanion data) {
    return CatalogItem(
      id: data.id.present ? data.id.value : this.id,
      domain: data.domain.present ? data.domain.value : this.domain,
      title: data.title.present ? data.title.value : this.title,
      rating: data.rating.present ? data.rating.value : this.rating,
      status: data.status.present ? data.status.value : this.status,
      unfinishedReason: data.unfinishedReason.present
          ? data.unfinishedReason.value
          : this.unfinishedReason,
      note: data.note.present ? data.note.value : this.note,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      eventCount: data.eventCount.present
          ? data.eventCount.value
          : this.eventCount,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      startedAtPrec: data.startedAtPrec.present
          ? data.startedAtPrec.value
          : this.startedAtPrec,
      lastActivityAt: data.lastActivityAt.present
          ? data.lastActivityAt.value
          : this.lastActivityAt,
      lastActivityAtPrec: data.lastActivityAtPrec.present
          ? data.lastActivityAtPrec.value
          : this.lastActivityAtPrec,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      finishedAtPrec: data.finishedAtPrec.present
          ? data.finishedAtPrec.value
          : this.finishedAtPrec,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItem(')
          ..write('id: $id, ')
          ..write('domain: $domain, ')
          ..write('title: $title, ')
          ..write('rating: $rating, ')
          ..write('status: $status, ')
          ..write('unfinishedReason: $unfinishedReason, ')
          ..write('note: $note, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('eventCount: $eventCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('startedAtPrec: $startedAtPrec, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('lastActivityAtPrec: $lastActivityAtPrec, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('finishedAtPrec: $finishedAtPrec, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    domain,
    title,
    rating,
    status,
    unfinishedReason,
    note,
    isFavorite,
    eventCount,
    startedAt,
    startedAtPrec,
    lastActivityAt,
    lastActivityAtPrec,
    finishedAt,
    finishedAtPrec,
    createdAt,
    updatedAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CatalogItem &&
          other.id == this.id &&
          other.domain == this.domain &&
          other.title == this.title &&
          other.rating == this.rating &&
          other.status == this.status &&
          other.unfinishedReason == this.unfinishedReason &&
          other.note == this.note &&
          other.isFavorite == this.isFavorite &&
          other.eventCount == this.eventCount &&
          other.startedAt == this.startedAt &&
          other.startedAtPrec == this.startedAtPrec &&
          other.lastActivityAt == this.lastActivityAt &&
          other.lastActivityAtPrec == this.lastActivityAtPrec &&
          other.finishedAt == this.finishedAt &&
          other.finishedAtPrec == this.finishedAtPrec &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class CatalogItemsCompanion extends UpdateCompanion<CatalogItem> {
  final Value<String> id;
  final Value<CatalogDomain> domain;
  final Value<String> title;
  final Value<int?> rating;
  final Value<WatchStatus> status;
  final Value<UnfinishedReason?> unfinishedReason;
  final Value<String?> note;
  final Value<bool> isFavorite;
  final Value<int> eventCount;
  final Value<DateTime?> startedAt;
  final Value<DatePrecision?> startedAtPrec;
  final Value<DateTime?> lastActivityAt;
  final Value<DatePrecision?> lastActivityAtPrec;
  final Value<DateTime?> finishedAt;
  final Value<DatePrecision?> finishedAtPrec;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const CatalogItemsCompanion({
    this.id = const Value.absent(),
    this.domain = const Value.absent(),
    this.title = const Value.absent(),
    this.rating = const Value.absent(),
    this.status = const Value.absent(),
    this.unfinishedReason = const Value.absent(),
    this.note = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.eventCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.startedAtPrec = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    this.lastActivityAtPrec = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.finishedAtPrec = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CatalogItemsCompanion.insert({
    required String id,
    required CatalogDomain domain,
    required String title,
    this.rating = const Value.absent(),
    required WatchStatus status,
    this.unfinishedReason = const Value.absent(),
    this.note = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.eventCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.startedAtPrec = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
    this.lastActivityAtPrec = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.finishedAtPrec = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       domain = Value(domain),
       title = Value(title),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CatalogItem> custom({
    Expression<String>? id,
    Expression<String>? domain,
    Expression<String>? title,
    Expression<int>? rating,
    Expression<String>? status,
    Expression<String>? unfinishedReason,
    Expression<String>? note,
    Expression<bool>? isFavorite,
    Expression<int>? eventCount,
    Expression<int>? startedAt,
    Expression<String>? startedAtPrec,
    Expression<int>? lastActivityAt,
    Expression<String>? lastActivityAtPrec,
    Expression<int>? finishedAt,
    Expression<String>? finishedAtPrec,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (domain != null) 'domain': domain,
      if (title != null) 'title': title,
      if (rating != null) 'rating': rating,
      if (status != null) 'status': status,
      if (unfinishedReason != null) 'unfinished_reason': unfinishedReason,
      if (note != null) 'note': note,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (eventCount != null) 'event_count': eventCount,
      if (startedAt != null) 'started_at': startedAt,
      if (startedAtPrec != null) 'started_at_prec': startedAtPrec,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
      if (lastActivityAtPrec != null)
        'last_activity_at_prec': lastActivityAtPrec,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (finishedAtPrec != null) 'finished_at_prec': finishedAtPrec,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CatalogItemsCompanion copyWith({
    Value<String>? id,
    Value<CatalogDomain>? domain,
    Value<String>? title,
    Value<int?>? rating,
    Value<WatchStatus>? status,
    Value<UnfinishedReason?>? unfinishedReason,
    Value<String?>? note,
    Value<bool>? isFavorite,
    Value<int>? eventCount,
    Value<DateTime?>? startedAt,
    Value<DatePrecision?>? startedAtPrec,
    Value<DateTime?>? lastActivityAt,
    Value<DatePrecision?>? lastActivityAtPrec,
    Value<DateTime?>? finishedAt,
    Value<DatePrecision?>? finishedAtPrec,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return CatalogItemsCompanion(
      id: id ?? this.id,
      domain: domain ?? this.domain,
      title: title ?? this.title,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      unfinishedReason: unfinishedReason ?? this.unfinishedReason,
      note: note ?? this.note,
      isFavorite: isFavorite ?? this.isFavorite,
      eventCount: eventCount ?? this.eventCount,
      startedAt: startedAt ?? this.startedAt,
      startedAtPrec: startedAtPrec ?? this.startedAtPrec,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
      lastActivityAtPrec: lastActivityAtPrec ?? this.lastActivityAtPrec,
      finishedAt: finishedAt ?? this.finishedAt,
      finishedAtPrec: finishedAtPrec ?? this.finishedAtPrec,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(
        $CatalogItemsTable.$converterdomain.toSql(domain.value),
      );
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $CatalogItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (unfinishedReason.present) {
      map['unfinished_reason'] = Variable<String>(
        $CatalogItemsTable.$converterunfinishedReasonn.toSql(
          unfinishedReason.value,
        ),
      );
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (eventCount.present) {
      map['event_count'] = Variable<int>(eventCount.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(
        $CatalogItemsTable.$converterstartedAtn.toSql(startedAt.value),
      );
    }
    if (startedAtPrec.present) {
      map['started_at_prec'] = Variable<String>(
        $CatalogItemsTable.$converterstartedAtPrecn.toSql(startedAtPrec.value),
      );
    }
    if (lastActivityAt.present) {
      map['last_activity_at'] = Variable<int>(
        $CatalogItemsTable.$converterlastActivityAtn.toSql(
          lastActivityAt.value,
        ),
      );
    }
    if (lastActivityAtPrec.present) {
      map['last_activity_at_prec'] = Variable<String>(
        $CatalogItemsTable.$converterlastActivityAtPrecn.toSql(
          lastActivityAtPrec.value,
        ),
      );
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<int>(
        $CatalogItemsTable.$converterfinishedAtn.toSql(finishedAt.value),
      );
    }
    if (finishedAtPrec.present) {
      map['finished_at_prec'] = Variable<String>(
        $CatalogItemsTable.$converterfinishedAtPrecn.toSql(
          finishedAtPrec.value,
        ),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $CatalogItemsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $CatalogItemsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $CatalogItemsTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CatalogItemsCompanion(')
          ..write('id: $id, ')
          ..write('domain: $domain, ')
          ..write('title: $title, ')
          ..write('rating: $rating, ')
          ..write('status: $status, ')
          ..write('unfinishedReason: $unfinishedReason, ')
          ..write('note: $note, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('eventCount: $eventCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('startedAtPrec: $startedAtPrec, ')
          ..write('lastActivityAt: $lastActivityAt, ')
          ..write('lastActivityAtPrec: $lastActivityAtPrec, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('finishedAtPrec: $finishedAtPrec, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_items (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, String> mediaType =
      GeneratedColumn<String>(
        'media_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MediaType>($MediaItemsTable.$convertermediaType);
  @override
  late final GeneratedColumnWithTypeConverter<MediaFormat, String> format =
      GeneratedColumn<String>(
        'format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MediaFormat>($MediaItemsTable.$converterformat);
  static const VerificationMeta _originalTitleMeta = const VerificationMeta(
    'originalTitle',
  );
  @override
  late final GeneratedColumn<String> originalTitle = GeneratedColumn<String>(
    'original_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _countryMeta = const VerificationMeta(
    'country',
  );
  @override
  late final GeneratedColumn<String> country = GeneratedColumn<String>(
    'country',
    aliasedName,
    true,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 2,
      maxTextLength: 2,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentSeasonMeta = const VerificationMeta(
    'currentSeason',
  );
  @override
  late final GeneratedColumn<int> currentSeason = GeneratedColumn<int>(
    'current_season',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentEpisodeMeta = const VerificationMeta(
    'currentEpisode',
  );
  @override
  late final GeneratedColumn<int> currentEpisode = GeneratedColumn<int>(
    'current_episode',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalSeasonsMeta = const VerificationMeta(
    'totalSeasons',
  );
  @override
  late final GeneratedColumn<int> totalSeasons = GeneratedColumn<int>(
    'total_seasons',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalEpisodesMeta = const VerificationMeta(
    'totalEpisodes',
  );
  @override
  late final GeneratedColumn<int> totalEpisodes = GeneratedColumn<int>(
    'total_episodes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    mediaType,
    format,
    originalTitle,
    year,
    country,
    currentSeason,
    currentEpisode,
    totalSeasons,
    totalEpisodes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('original_title')) {
      context.handle(
        _originalTitleMeta,
        originalTitle.isAcceptableOrUnknown(
          data['original_title']!,
          _originalTitleMeta,
        ),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('country')) {
      context.handle(
        _countryMeta,
        country.isAcceptableOrUnknown(data['country']!, _countryMeta),
      );
    }
    if (data.containsKey('current_season')) {
      context.handle(
        _currentSeasonMeta,
        currentSeason.isAcceptableOrUnknown(
          data['current_season']!,
          _currentSeasonMeta,
        ),
      );
    }
    if (data.containsKey('current_episode')) {
      context.handle(
        _currentEpisodeMeta,
        currentEpisode.isAcceptableOrUnknown(
          data['current_episode']!,
          _currentEpisodeMeta,
        ),
      );
    }
    if (data.containsKey('total_seasons')) {
      context.handle(
        _totalSeasonsMeta,
        totalSeasons.isAcceptableOrUnknown(
          data['total_seasons']!,
          _totalSeasonsMeta,
        ),
      );
    }
    if (data.containsKey('total_episodes')) {
      context.handle(
        _totalEpisodesMeta,
        totalEpisodes.isAcceptableOrUnknown(
          data['total_episodes']!,
          _totalEpisodesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      mediaType: $MediaItemsTable.$convertermediaType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}media_type'],
        )!,
      ),
      format: $MediaItemsTable.$converterformat.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}format'],
        )!,
      ),
      originalTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}original_title'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      country: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}country'],
      ),
      currentSeason: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_season'],
      ),
      currentEpisode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_episode'],
      ),
      totalSeasons: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_seasons'],
      ),
      totalEpisodes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_episodes'],
      ),
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<MediaType, String> $convertermediaType =
      const MediaTypeConverter();
  static TypeConverter<MediaFormat, String> $converterformat =
      const MediaFormatConverter();
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final String itemId;
  final MediaType mediaType;
  final MediaFormat format;
  final String? originalTitle;
  final int? year;

  /// ISO 3166-1 alpha-2 (KR/JP/CN/...).
  final String? country;
  final int? currentSeason;
  final int? currentEpisode;
  final int? totalSeasons;
  final int? totalEpisodes;
  const MediaItem({
    required this.itemId,
    required this.mediaType,
    required this.format,
    this.originalTitle,
    this.year,
    this.country,
    this.currentSeason,
    this.currentEpisode,
    this.totalSeasons,
    this.totalEpisodes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    {
      map['media_type'] = Variable<String>(
        $MediaItemsTable.$convertermediaType.toSql(mediaType),
      );
    }
    {
      map['format'] = Variable<String>(
        $MediaItemsTable.$converterformat.toSql(format),
      );
    }
    if (!nullToAbsent || originalTitle != null) {
      map['original_title'] = Variable<String>(originalTitle);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || country != null) {
      map['country'] = Variable<String>(country);
    }
    if (!nullToAbsent || currentSeason != null) {
      map['current_season'] = Variable<int>(currentSeason);
    }
    if (!nullToAbsent || currentEpisode != null) {
      map['current_episode'] = Variable<int>(currentEpisode);
    }
    if (!nullToAbsent || totalSeasons != null) {
      map['total_seasons'] = Variable<int>(totalSeasons);
    }
    if (!nullToAbsent || totalEpisodes != null) {
      map['total_episodes'] = Variable<int>(totalEpisodes);
    }
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      itemId: Value(itemId),
      mediaType: Value(mediaType),
      format: Value(format),
      originalTitle: originalTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(originalTitle),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      country: country == null && nullToAbsent
          ? const Value.absent()
          : Value(country),
      currentSeason: currentSeason == null && nullToAbsent
          ? const Value.absent()
          : Value(currentSeason),
      currentEpisode: currentEpisode == null && nullToAbsent
          ? const Value.absent()
          : Value(currentEpisode),
      totalSeasons: totalSeasons == null && nullToAbsent
          ? const Value.absent()
          : Value(totalSeasons),
      totalEpisodes: totalEpisodes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalEpisodes),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      itemId: serializer.fromJson<String>(json['itemId']),
      mediaType: serializer.fromJson<MediaType>(json['mediaType']),
      format: serializer.fromJson<MediaFormat>(json['format']),
      originalTitle: serializer.fromJson<String?>(json['originalTitle']),
      year: serializer.fromJson<int?>(json['year']),
      country: serializer.fromJson<String?>(json['country']),
      currentSeason: serializer.fromJson<int?>(json['currentSeason']),
      currentEpisode: serializer.fromJson<int?>(json['currentEpisode']),
      totalSeasons: serializer.fromJson<int?>(json['totalSeasons']),
      totalEpisodes: serializer.fromJson<int?>(json['totalEpisodes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'mediaType': serializer.toJson<MediaType>(mediaType),
      'format': serializer.toJson<MediaFormat>(format),
      'originalTitle': serializer.toJson<String?>(originalTitle),
      'year': serializer.toJson<int?>(year),
      'country': serializer.toJson<String?>(country),
      'currentSeason': serializer.toJson<int?>(currentSeason),
      'currentEpisode': serializer.toJson<int?>(currentEpisode),
      'totalSeasons': serializer.toJson<int?>(totalSeasons),
      'totalEpisodes': serializer.toJson<int?>(totalEpisodes),
    };
  }

  MediaItem copyWith({
    String? itemId,
    MediaType? mediaType,
    MediaFormat? format,
    Value<String?> originalTitle = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> country = const Value.absent(),
    Value<int?> currentSeason = const Value.absent(),
    Value<int?> currentEpisode = const Value.absent(),
    Value<int?> totalSeasons = const Value.absent(),
    Value<int?> totalEpisodes = const Value.absent(),
  }) => MediaItem(
    itemId: itemId ?? this.itemId,
    mediaType: mediaType ?? this.mediaType,
    format: format ?? this.format,
    originalTitle: originalTitle.present
        ? originalTitle.value
        : this.originalTitle,
    year: year.present ? year.value : this.year,
    country: country.present ? country.value : this.country,
    currentSeason: currentSeason.present
        ? currentSeason.value
        : this.currentSeason,
    currentEpisode: currentEpisode.present
        ? currentEpisode.value
        : this.currentEpisode,
    totalSeasons: totalSeasons.present ? totalSeasons.value : this.totalSeasons,
    totalEpisodes: totalEpisodes.present
        ? totalEpisodes.value
        : this.totalEpisodes,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      format: data.format.present ? data.format.value : this.format,
      originalTitle: data.originalTitle.present
          ? data.originalTitle.value
          : this.originalTitle,
      year: data.year.present ? data.year.value : this.year,
      country: data.country.present ? data.country.value : this.country,
      currentSeason: data.currentSeason.present
          ? data.currentSeason.value
          : this.currentSeason,
      currentEpisode: data.currentEpisode.present
          ? data.currentEpisode.value
          : this.currentEpisode,
      totalSeasons: data.totalSeasons.present
          ? data.totalSeasons.value
          : this.totalSeasons,
      totalEpisodes: data.totalEpisodes.present
          ? data.totalEpisodes.value
          : this.totalEpisodes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('itemId: $itemId, ')
          ..write('mediaType: $mediaType, ')
          ..write('format: $format, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('year: $year, ')
          ..write('country: $country, ')
          ..write('currentSeason: $currentSeason, ')
          ..write('currentEpisode: $currentEpisode, ')
          ..write('totalSeasons: $totalSeasons, ')
          ..write('totalEpisodes: $totalEpisodes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    mediaType,
    format,
    originalTitle,
    year,
    country,
    currentSeason,
    currentEpisode,
    totalSeasons,
    totalEpisodes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.itemId == this.itemId &&
          other.mediaType == this.mediaType &&
          other.format == this.format &&
          other.originalTitle == this.originalTitle &&
          other.year == this.year &&
          other.country == this.country &&
          other.currentSeason == this.currentSeason &&
          other.currentEpisode == this.currentEpisode &&
          other.totalSeasons == this.totalSeasons &&
          other.totalEpisodes == this.totalEpisodes);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<String> itemId;
  final Value<MediaType> mediaType;
  final Value<MediaFormat> format;
  final Value<String?> originalTitle;
  final Value<int?> year;
  final Value<String?> country;
  final Value<int?> currentSeason;
  final Value<int?> currentEpisode;
  final Value<int?> totalSeasons;
  final Value<int?> totalEpisodes;
  final Value<int> rowid;
  const MediaItemsCompanion({
    this.itemId = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.format = const Value.absent(),
    this.originalTitle = const Value.absent(),
    this.year = const Value.absent(),
    this.country = const Value.absent(),
    this.currentSeason = const Value.absent(),
    this.currentEpisode = const Value.absent(),
    this.totalSeasons = const Value.absent(),
    this.totalEpisodes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    required String itemId,
    required MediaType mediaType,
    required MediaFormat format,
    this.originalTitle = const Value.absent(),
    this.year = const Value.absent(),
    this.country = const Value.absent(),
    this.currentSeason = const Value.absent(),
    this.currentEpisode = const Value.absent(),
    this.totalSeasons = const Value.absent(),
    this.totalEpisodes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       mediaType = Value(mediaType),
       format = Value(format);
  static Insertable<MediaItem> custom({
    Expression<String>? itemId,
    Expression<String>? mediaType,
    Expression<String>? format,
    Expression<String>? originalTitle,
    Expression<int>? year,
    Expression<String>? country,
    Expression<int>? currentSeason,
    Expression<int>? currentEpisode,
    Expression<int>? totalSeasons,
    Expression<int>? totalEpisodes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (mediaType != null) 'media_type': mediaType,
      if (format != null) 'format': format,
      if (originalTitle != null) 'original_title': originalTitle,
      if (year != null) 'year': year,
      if (country != null) 'country': country,
      if (currentSeason != null) 'current_season': currentSeason,
      if (currentEpisode != null) 'current_episode': currentEpisode,
      if (totalSeasons != null) 'total_seasons': totalSeasons,
      if (totalEpisodes != null) 'total_episodes': totalEpisodes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaItemsCompanion copyWith({
    Value<String>? itemId,
    Value<MediaType>? mediaType,
    Value<MediaFormat>? format,
    Value<String?>? originalTitle,
    Value<int?>? year,
    Value<String?>? country,
    Value<int?>? currentSeason,
    Value<int?>? currentEpisode,
    Value<int?>? totalSeasons,
    Value<int?>? totalEpisodes,
    Value<int>? rowid,
  }) {
    return MediaItemsCompanion(
      itemId: itemId ?? this.itemId,
      mediaType: mediaType ?? this.mediaType,
      format: format ?? this.format,
      originalTitle: originalTitle ?? this.originalTitle,
      year: year ?? this.year,
      country: country ?? this.country,
      currentSeason: currentSeason ?? this.currentSeason,
      currentEpisode: currentEpisode ?? this.currentEpisode,
      totalSeasons: totalSeasons ?? this.totalSeasons,
      totalEpisodes: totalEpisodes ?? this.totalEpisodes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(
        $MediaItemsTable.$convertermediaType.toSql(mediaType.value),
      );
    }
    if (format.present) {
      map['format'] = Variable<String>(
        $MediaItemsTable.$converterformat.toSql(format.value),
      );
    }
    if (originalTitle.present) {
      map['original_title'] = Variable<String>(originalTitle.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (country.present) {
      map['country'] = Variable<String>(country.value);
    }
    if (currentSeason.present) {
      map['current_season'] = Variable<int>(currentSeason.value);
    }
    if (currentEpisode.present) {
      map['current_episode'] = Variable<int>(currentEpisode.value);
    }
    if (totalSeasons.present) {
      map['total_seasons'] = Variable<int>(totalSeasons.value);
    }
    if (totalEpisodes.present) {
      map['total_episodes'] = Variable<int>(totalEpisodes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('mediaType: $mediaType, ')
          ..write('format: $format, ')
          ..write('originalTitle: $originalTitle, ')
          ..write('year: $year, ')
          ..write('country: $country, ')
          ..write('currentSeason: $currentSeason, ')
          ..write('currentEpisode: $currentEpisode, ')
          ..write('totalSeasons: $totalSeasons, ')
          ..write('totalEpisodes: $totalEpisodes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VapeItemsTable extends VapeItems
    with TableInfo<$VapeItemsTable, VapeItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VapeItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 30,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<NicotineType, String>
  nicotineType = GeneratedColumn<String>(
    'nicotine_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  ).withConverter<NicotineType>($VapeItemsTable.$converternicotineType);
  static const VerificationMeta _nicotineStrengthMeta = const VerificationMeta(
    'nicotineStrength',
  );
  @override
  late final GeneratedColumn<String> nicotineStrength = GeneratedColumn<String>(
    'nicotine_strength',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<FlavorCategory?, String>
  flavorCategory = GeneratedColumn<String>(
    'flavor_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  ).withConverter<FlavorCategory?>($VapeItemsTable.$converterflavorCategoryn);
  static const VerificationMeta _flavorDescriptionMeta = const VerificationMeta(
    'flavorDescription',
  );
  @override
  late final GeneratedColumn<String> flavorDescription =
      GeneratedColumn<String>(
        'flavor_description',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _sweetnessMeta = const VerificationMeta(
    'sweetness',
  );
  @override
  late final GeneratedColumn<int> sweetness = GeneratedColumn<int>(
    'sweetness',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coolnessMeta = const VerificationMeta(
    'coolness',
  );
  @override
  late final GeneratedColumn<int> coolness = GeneratedColumn<int>(
    'coolness',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _richnessMeta = const VerificationMeta(
    'richness',
  );
  @override
  late final GeneratedColumn<int> richness = GeneratedColumn<int>(
    'richness',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _canRebuyMeta = const VerificationMeta(
    'canRebuy',
  );
  @override
  late final GeneratedColumn<bool> canRebuy = GeneratedColumn<bool>(
    'can_rebuy',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("can_rebuy" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _flavorFadesMeta = const VerificationMeta(
    'flavorFades',
  );
  @override
  late final GeneratedColumn<bool> flavorFades = GeneratedColumn<bool>(
    'flavor_fades',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("flavor_fades" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _damagesHardwareMeta = const VerificationMeta(
    'damagesHardware',
  );
  @override
  late final GeneratedColumn<bool> damagesHardware = GeneratedColumn<bool>(
    'damages_hardware',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("damages_hardware" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    itemId,
    brand,
    nicotineType,
    nicotineStrength,
    flavorCategory,
    flavorDescription,
    sweetness,
    coolness,
    richness,
    canRebuy,
    flavorFades,
    damagesHardware,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vape_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<VapeItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    } else if (isInserting) {
      context.missing(_brandMeta);
    }
    if (data.containsKey('nicotine_strength')) {
      context.handle(
        _nicotineStrengthMeta,
        nicotineStrength.isAcceptableOrUnknown(
          data['nicotine_strength']!,
          _nicotineStrengthMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nicotineStrengthMeta);
    }
    if (data.containsKey('flavor_description')) {
      context.handle(
        _flavorDescriptionMeta,
        flavorDescription.isAcceptableOrUnknown(
          data['flavor_description']!,
          _flavorDescriptionMeta,
        ),
      );
    }
    if (data.containsKey('sweetness')) {
      context.handle(
        _sweetnessMeta,
        sweetness.isAcceptableOrUnknown(data['sweetness']!, _sweetnessMeta),
      );
    }
    if (data.containsKey('coolness')) {
      context.handle(
        _coolnessMeta,
        coolness.isAcceptableOrUnknown(data['coolness']!, _coolnessMeta),
      );
    }
    if (data.containsKey('richness')) {
      context.handle(
        _richnessMeta,
        richness.isAcceptableOrUnknown(data['richness']!, _richnessMeta),
      );
    }
    if (data.containsKey('can_rebuy')) {
      context.handle(
        _canRebuyMeta,
        canRebuy.isAcceptableOrUnknown(data['can_rebuy']!, _canRebuyMeta),
      );
    }
    if (data.containsKey('flavor_fades')) {
      context.handle(
        _flavorFadesMeta,
        flavorFades.isAcceptableOrUnknown(
          data['flavor_fades']!,
          _flavorFadesMeta,
        ),
      );
    }
    if (data.containsKey('damages_hardware')) {
      context.handle(
        _damagesHardwareMeta,
        damagesHardware.isAcceptableOrUnknown(
          data['damages_hardware']!,
          _damagesHardwareMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId};
  @override
  VapeItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VapeItem(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      )!,
      nicotineType: $VapeItemsTable.$converternicotineType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}nicotine_type'],
        )!,
      ),
      nicotineStrength: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nicotine_strength'],
      )!,
      flavorCategory: $VapeItemsTable.$converterflavorCategoryn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}flavor_category'],
        ),
      ),
      flavorDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}flavor_description'],
      ),
      sweetness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sweetness'],
      ),
      coolness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}coolness'],
      ),
      richness: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}richness'],
      ),
      canRebuy: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}can_rebuy'],
      )!,
      flavorFades: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}flavor_fades'],
      )!,
      damagesHardware: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}damages_hardware'],
      )!,
    );
  }

  @override
  $VapeItemsTable createAlias(String alias) {
    return $VapeItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<NicotineType, String> $converternicotineType =
      const NicotineTypeConverter();
  static TypeConverter<FlavorCategory, String> $converterflavorCategory =
      const FlavorCategoryConverter();
  static TypeConverter<FlavorCategory?, String?> $converterflavorCategoryn =
      NullAwareTypeConverter.wrap($converterflavorCategory);
}

class VapeItem extends DataClass implements Insertable<VapeItem> {
  final String itemId;

  /// Бренд (≤30) — обязателен.
  final String brand;
  final NicotineType nicotineType;

  /// Крепость (мг/мл) — значение из списка по типу; строка (есть диапазоны).
  final String nicotineStrength;
  final FlavorCategory? flavorCategory;

  /// Описание вкуса (≤150, валидация в UI).
  final String? flavorDescription;

  /// Уровни 0–100 (слайдер «оценки» /10): сладость / холодок / насыщенность.
  final int? sweetness;
  final int? coolness;
  final int? richness;

  /// Можно покупать снова / мылится ли вкус / портит железо (вата/картридж/
  /// испаритель).
  final bool canRebuy;
  final bool flavorFades;
  final bool damagesHardware;
  const VapeItem({
    required this.itemId,
    required this.brand,
    required this.nicotineType,
    required this.nicotineStrength,
    this.flavorCategory,
    this.flavorDescription,
    this.sweetness,
    this.coolness,
    this.richness,
    required this.canRebuy,
    required this.flavorFades,
    required this.damagesHardware,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['brand'] = Variable<String>(brand);
    {
      map['nicotine_type'] = Variable<String>(
        $VapeItemsTable.$converternicotineType.toSql(nicotineType),
      );
    }
    map['nicotine_strength'] = Variable<String>(nicotineStrength);
    if (!nullToAbsent || flavorCategory != null) {
      map['flavor_category'] = Variable<String>(
        $VapeItemsTable.$converterflavorCategoryn.toSql(flavorCategory),
      );
    }
    if (!nullToAbsent || flavorDescription != null) {
      map['flavor_description'] = Variable<String>(flavorDescription);
    }
    if (!nullToAbsent || sweetness != null) {
      map['sweetness'] = Variable<int>(sweetness);
    }
    if (!nullToAbsent || coolness != null) {
      map['coolness'] = Variable<int>(coolness);
    }
    if (!nullToAbsent || richness != null) {
      map['richness'] = Variable<int>(richness);
    }
    map['can_rebuy'] = Variable<bool>(canRebuy);
    map['flavor_fades'] = Variable<bool>(flavorFades);
    map['damages_hardware'] = Variable<bool>(damagesHardware);
    return map;
  }

  VapeItemsCompanion toCompanion(bool nullToAbsent) {
    return VapeItemsCompanion(
      itemId: Value(itemId),
      brand: Value(brand),
      nicotineType: Value(nicotineType),
      nicotineStrength: Value(nicotineStrength),
      flavorCategory: flavorCategory == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorCategory),
      flavorDescription: flavorDescription == null && nullToAbsent
          ? const Value.absent()
          : Value(flavorDescription),
      sweetness: sweetness == null && nullToAbsent
          ? const Value.absent()
          : Value(sweetness),
      coolness: coolness == null && nullToAbsent
          ? const Value.absent()
          : Value(coolness),
      richness: richness == null && nullToAbsent
          ? const Value.absent()
          : Value(richness),
      canRebuy: Value(canRebuy),
      flavorFades: Value(flavorFades),
      damagesHardware: Value(damagesHardware),
    );
  }

  factory VapeItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VapeItem(
      itemId: serializer.fromJson<String>(json['itemId']),
      brand: serializer.fromJson<String>(json['brand']),
      nicotineType: serializer.fromJson<NicotineType>(json['nicotineType']),
      nicotineStrength: serializer.fromJson<String>(json['nicotineStrength']),
      flavorCategory: serializer.fromJson<FlavorCategory?>(
        json['flavorCategory'],
      ),
      flavorDescription: serializer.fromJson<String?>(
        json['flavorDescription'],
      ),
      sweetness: serializer.fromJson<int?>(json['sweetness']),
      coolness: serializer.fromJson<int?>(json['coolness']),
      richness: serializer.fromJson<int?>(json['richness']),
      canRebuy: serializer.fromJson<bool>(json['canRebuy']),
      flavorFades: serializer.fromJson<bool>(json['flavorFades']),
      damagesHardware: serializer.fromJson<bool>(json['damagesHardware']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'brand': serializer.toJson<String>(brand),
      'nicotineType': serializer.toJson<NicotineType>(nicotineType),
      'nicotineStrength': serializer.toJson<String>(nicotineStrength),
      'flavorCategory': serializer.toJson<FlavorCategory?>(flavorCategory),
      'flavorDescription': serializer.toJson<String?>(flavorDescription),
      'sweetness': serializer.toJson<int?>(sweetness),
      'coolness': serializer.toJson<int?>(coolness),
      'richness': serializer.toJson<int?>(richness),
      'canRebuy': serializer.toJson<bool>(canRebuy),
      'flavorFades': serializer.toJson<bool>(flavorFades),
      'damagesHardware': serializer.toJson<bool>(damagesHardware),
    };
  }

  VapeItem copyWith({
    String? itemId,
    String? brand,
    NicotineType? nicotineType,
    String? nicotineStrength,
    Value<FlavorCategory?> flavorCategory = const Value.absent(),
    Value<String?> flavorDescription = const Value.absent(),
    Value<int?> sweetness = const Value.absent(),
    Value<int?> coolness = const Value.absent(),
    Value<int?> richness = const Value.absent(),
    bool? canRebuy,
    bool? flavorFades,
    bool? damagesHardware,
  }) => VapeItem(
    itemId: itemId ?? this.itemId,
    brand: brand ?? this.brand,
    nicotineType: nicotineType ?? this.nicotineType,
    nicotineStrength: nicotineStrength ?? this.nicotineStrength,
    flavorCategory: flavorCategory.present
        ? flavorCategory.value
        : this.flavorCategory,
    flavorDescription: flavorDescription.present
        ? flavorDescription.value
        : this.flavorDescription,
    sweetness: sweetness.present ? sweetness.value : this.sweetness,
    coolness: coolness.present ? coolness.value : this.coolness,
    richness: richness.present ? richness.value : this.richness,
    canRebuy: canRebuy ?? this.canRebuy,
    flavorFades: flavorFades ?? this.flavorFades,
    damagesHardware: damagesHardware ?? this.damagesHardware,
  );
  VapeItem copyWithCompanion(VapeItemsCompanion data) {
    return VapeItem(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      brand: data.brand.present ? data.brand.value : this.brand,
      nicotineType: data.nicotineType.present
          ? data.nicotineType.value
          : this.nicotineType,
      nicotineStrength: data.nicotineStrength.present
          ? data.nicotineStrength.value
          : this.nicotineStrength,
      flavorCategory: data.flavorCategory.present
          ? data.flavorCategory.value
          : this.flavorCategory,
      flavorDescription: data.flavorDescription.present
          ? data.flavorDescription.value
          : this.flavorDescription,
      sweetness: data.sweetness.present ? data.sweetness.value : this.sweetness,
      coolness: data.coolness.present ? data.coolness.value : this.coolness,
      richness: data.richness.present ? data.richness.value : this.richness,
      canRebuy: data.canRebuy.present ? data.canRebuy.value : this.canRebuy,
      flavorFades: data.flavorFades.present
          ? data.flavorFades.value
          : this.flavorFades,
      damagesHardware: data.damagesHardware.present
          ? data.damagesHardware.value
          : this.damagesHardware,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VapeItem(')
          ..write('itemId: $itemId, ')
          ..write('brand: $brand, ')
          ..write('nicotineType: $nicotineType, ')
          ..write('nicotineStrength: $nicotineStrength, ')
          ..write('flavorCategory: $flavorCategory, ')
          ..write('flavorDescription: $flavorDescription, ')
          ..write('sweetness: $sweetness, ')
          ..write('coolness: $coolness, ')
          ..write('richness: $richness, ')
          ..write('canRebuy: $canRebuy, ')
          ..write('flavorFades: $flavorFades, ')
          ..write('damagesHardware: $damagesHardware')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    itemId,
    brand,
    nicotineType,
    nicotineStrength,
    flavorCategory,
    flavorDescription,
    sweetness,
    coolness,
    richness,
    canRebuy,
    flavorFades,
    damagesHardware,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VapeItem &&
          other.itemId == this.itemId &&
          other.brand == this.brand &&
          other.nicotineType == this.nicotineType &&
          other.nicotineStrength == this.nicotineStrength &&
          other.flavorCategory == this.flavorCategory &&
          other.flavorDescription == this.flavorDescription &&
          other.sweetness == this.sweetness &&
          other.coolness == this.coolness &&
          other.richness == this.richness &&
          other.canRebuy == this.canRebuy &&
          other.flavorFades == this.flavorFades &&
          other.damagesHardware == this.damagesHardware);
}

class VapeItemsCompanion extends UpdateCompanion<VapeItem> {
  final Value<String> itemId;
  final Value<String> brand;
  final Value<NicotineType> nicotineType;
  final Value<String> nicotineStrength;
  final Value<FlavorCategory?> flavorCategory;
  final Value<String?> flavorDescription;
  final Value<int?> sweetness;
  final Value<int?> coolness;
  final Value<int?> richness;
  final Value<bool> canRebuy;
  final Value<bool> flavorFades;
  final Value<bool> damagesHardware;
  final Value<int> rowid;
  const VapeItemsCompanion({
    this.itemId = const Value.absent(),
    this.brand = const Value.absent(),
    this.nicotineType = const Value.absent(),
    this.nicotineStrength = const Value.absent(),
    this.flavorCategory = const Value.absent(),
    this.flavorDescription = const Value.absent(),
    this.sweetness = const Value.absent(),
    this.coolness = const Value.absent(),
    this.richness = const Value.absent(),
    this.canRebuy = const Value.absent(),
    this.flavorFades = const Value.absent(),
    this.damagesHardware = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VapeItemsCompanion.insert({
    required String itemId,
    required String brand,
    required NicotineType nicotineType,
    required String nicotineStrength,
    this.flavorCategory = const Value.absent(),
    this.flavorDescription = const Value.absent(),
    this.sweetness = const Value.absent(),
    this.coolness = const Value.absent(),
    this.richness = const Value.absent(),
    this.canRebuy = const Value.absent(),
    this.flavorFades = const Value.absent(),
    this.damagesHardware = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       brand = Value(brand),
       nicotineType = Value(nicotineType),
       nicotineStrength = Value(nicotineStrength);
  static Insertable<VapeItem> custom({
    Expression<String>? itemId,
    Expression<String>? brand,
    Expression<String>? nicotineType,
    Expression<String>? nicotineStrength,
    Expression<String>? flavorCategory,
    Expression<String>? flavorDescription,
    Expression<int>? sweetness,
    Expression<int>? coolness,
    Expression<int>? richness,
    Expression<bool>? canRebuy,
    Expression<bool>? flavorFades,
    Expression<bool>? damagesHardware,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (brand != null) 'brand': brand,
      if (nicotineType != null) 'nicotine_type': nicotineType,
      if (nicotineStrength != null) 'nicotine_strength': nicotineStrength,
      if (flavorCategory != null) 'flavor_category': flavorCategory,
      if (flavorDescription != null) 'flavor_description': flavorDescription,
      if (sweetness != null) 'sweetness': sweetness,
      if (coolness != null) 'coolness': coolness,
      if (richness != null) 'richness': richness,
      if (canRebuy != null) 'can_rebuy': canRebuy,
      if (flavorFades != null) 'flavor_fades': flavorFades,
      if (damagesHardware != null) 'damages_hardware': damagesHardware,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VapeItemsCompanion copyWith({
    Value<String>? itemId,
    Value<String>? brand,
    Value<NicotineType>? nicotineType,
    Value<String>? nicotineStrength,
    Value<FlavorCategory?>? flavorCategory,
    Value<String?>? flavorDescription,
    Value<int?>? sweetness,
    Value<int?>? coolness,
    Value<int?>? richness,
    Value<bool>? canRebuy,
    Value<bool>? flavorFades,
    Value<bool>? damagesHardware,
    Value<int>? rowid,
  }) {
    return VapeItemsCompanion(
      itemId: itemId ?? this.itemId,
      brand: brand ?? this.brand,
      nicotineType: nicotineType ?? this.nicotineType,
      nicotineStrength: nicotineStrength ?? this.nicotineStrength,
      flavorCategory: flavorCategory ?? this.flavorCategory,
      flavorDescription: flavorDescription ?? this.flavorDescription,
      sweetness: sweetness ?? this.sweetness,
      coolness: coolness ?? this.coolness,
      richness: richness ?? this.richness,
      canRebuy: canRebuy ?? this.canRebuy,
      flavorFades: flavorFades ?? this.flavorFades,
      damagesHardware: damagesHardware ?? this.damagesHardware,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (nicotineType.present) {
      map['nicotine_type'] = Variable<String>(
        $VapeItemsTable.$converternicotineType.toSql(nicotineType.value),
      );
    }
    if (nicotineStrength.present) {
      map['nicotine_strength'] = Variable<String>(nicotineStrength.value);
    }
    if (flavorCategory.present) {
      map['flavor_category'] = Variable<String>(
        $VapeItemsTable.$converterflavorCategoryn.toSql(flavorCategory.value),
      );
    }
    if (flavorDescription.present) {
      map['flavor_description'] = Variable<String>(flavorDescription.value);
    }
    if (sweetness.present) {
      map['sweetness'] = Variable<int>(sweetness.value);
    }
    if (coolness.present) {
      map['coolness'] = Variable<int>(coolness.value);
    }
    if (richness.present) {
      map['richness'] = Variable<int>(richness.value);
    }
    if (canRebuy.present) {
      map['can_rebuy'] = Variable<bool>(canRebuy.value);
    }
    if (flavorFades.present) {
      map['flavor_fades'] = Variable<bool>(flavorFades.value);
    }
    if (damagesHardware.present) {
      map['damages_hardware'] = Variable<bool>(damagesHardware.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VapeItemsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('brand: $brand, ')
          ..write('nicotineType: $nicotineType, ')
          ..write('nicotineStrength: $nicotineStrength, ')
          ..write('flavorCategory: $flavorCategory, ')
          ..write('flavorDescription: $flavorDescription, ')
          ..write('sweetness: $sweetness, ')
          ..write('coolness: $coolness, ')
          ..write('richness: $richness, ')
          ..write('canRebuy: $canRebuy, ')
          ..write('flavorFades: $flavorFades, ')
          ..write('damagesHardware: $damagesHardware, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImagesTable extends Images with TableInfo<$ImagesTable, ImageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ImagesTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, itemId, position, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'images';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImageRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImageRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      createdAt: $ImagesTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $ImagesTable createAlias(String alias) {
    return $ImagesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeMsConverter();
}

class ImageRow extends DataClass implements Insertable<ImageRow> {
  /// UUID картинки (имя файла).
  final String id;
  final String itemId;
  final int position;
  final DateTime createdAt;
  const ImageRow({
    required this.id,
    required this.itemId,
    required this.position,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['item_id'] = Variable<String>(itemId);
    map['position'] = Variable<int>(position);
    {
      map['created_at'] = Variable<int>(
        $ImagesTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  ImagesCompanion toCompanion(bool nullToAbsent) {
    return ImagesCompanion(
      id: Value(id),
      itemId: Value(itemId),
      position: Value(position),
      createdAt: Value(createdAt),
    );
  }

  factory ImageRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImageRow(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['itemId']),
      position: serializer.fromJson<int>(json['position']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'itemId': serializer.toJson<String>(itemId),
      'position': serializer.toJson<int>(position),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ImageRow copyWith({
    String? id,
    String? itemId,
    int? position,
    DateTime? createdAt,
  }) => ImageRow(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    position: position ?? this.position,
    createdAt: createdAt ?? this.createdAt,
  );
  ImageRow copyWithCompanion(ImagesCompanion data) {
    return ImageRow(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      position: data.position.present ? data.position.value : this.position,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImageRow(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, itemId, position, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImageRow &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.position == this.position &&
          other.createdAt == this.createdAt);
}

class ImagesCompanion extends UpdateCompanion<ImageRow> {
  final Value<String> id;
  final Value<String> itemId;
  final Value<int> position;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ImagesCompanion({
    this.id = const Value.absent(),
    this.itemId = const Value.absent(),
    this.position = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImagesCompanion.insert({
    required String id,
    required String itemId,
    this.position = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       itemId = Value(itemId),
       createdAt = Value(createdAt);
  static Insertable<ImageRow> custom({
    Expression<String>? id,
    Expression<String>? itemId,
    Expression<int>? position,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (position != null) 'position': position,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImagesCompanion copyWith({
    Value<String>? id,
    Value<String>? itemId,
    Value<int>? position,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ImagesCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      position: position ?? this.position,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ImagesTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImagesCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('position: $position, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 100,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameNormalizedMeta = const VerificationMeta(
    'nameNormalized',
  );
  @override
  late final GeneratedColumn<String> nameNormalized = GeneratedColumn<String>(
    'name_normalized',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($TagsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameNormalized,
    color,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_normalized')) {
      context.handle(
        _nameNormalizedMeta,
        nameNormalized.isAcceptableOrUnknown(
          data['name_normalized']!,
          _nameNormalizedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nameNormalizedMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {nameNormalized},
  ];
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameNormalized: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_normalized'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      createdAt: $TagsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeMsConverter();
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final String nameNormalized;
  final String? color;
  final DateTime createdAt;
  const TagRow({
    required this.id,
    required this.name,
    required this.nameNormalized,
    this.color,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['name_normalized'] = Variable<String>(nameNormalized);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    {
      map['created_at'] = Variable<int>(
        $TagsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      nameNormalized: Value(nameNormalized),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameNormalized: serializer.fromJson<String>(json['nameNormalized']),
      color: serializer.fromJson<String?>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'nameNormalized': serializer.toJson<String>(nameNormalized),
      'color': serializer.toJson<String?>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    String? nameNormalized,
    Value<String?> color = const Value.absent(),
    DateTime? createdAt,
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    nameNormalized: nameNormalized ?? this.nameNormalized,
    color: color.present ? color.value : this.color,
    createdAt: createdAt ?? this.createdAt,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameNormalized: data.nameNormalized.present
          ? data.nameNormalized.value
          : this.nameNormalized,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNormalized: $nameNormalized, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, nameNormalized, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameNormalized == this.nameNormalized &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> nameNormalized;
  final Value<String?> color;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameNormalized = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    required String nameNormalized,
    this.color = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       nameNormalized = Value(nameNormalized),
       createdAt = Value(createdAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? nameNormalized,
    Expression<String>? color,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameNormalized != null) 'name_normalized': nameNormalized,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? nameNormalized,
    Value<String?>? color,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameNormalized: nameNormalized ?? this.nameNormalized,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameNormalized.present) {
      map['name_normalized'] = Variable<String>(nameNormalized.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $TagsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameNormalized: $nameNormalized, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemTagsTable extends ItemTags with TableInfo<$ItemTagsTable, ItemTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES catalog_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [itemId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'item_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<ItemTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemId, tagId};
  @override
  ItemTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ItemTag(
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $ItemTagsTable createAlias(String alias) {
    return $ItemTagsTable(attachedDatabase, alias);
  }
}

class ItemTag extends DataClass implements Insertable<ItemTag> {
  final String itemId;
  final String tagId;
  const ItemTag({required this.itemId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_id'] = Variable<String>(itemId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  ItemTagsCompanion toCompanion(bool nullToAbsent) {
    return ItemTagsCompanion(itemId: Value(itemId), tagId: Value(tagId));
  }

  factory ItemTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ItemTag(
      itemId: serializer.fromJson<String>(json['itemId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemId': serializer.toJson<String>(itemId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  ItemTag copyWith({String? itemId, String? tagId}) =>
      ItemTag(itemId: itemId ?? this.itemId, tagId: tagId ?? this.tagId);
  ItemTag copyWithCompanion(ItemTagsCompanion data) {
    return ItemTag(
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ItemTag(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ItemTag &&
          other.itemId == this.itemId &&
          other.tagId == this.tagId);
}

class ItemTagsCompanion extends UpdateCompanion<ItemTag> {
  final Value<String> itemId;
  final Value<String> tagId;
  final Value<int> rowid;
  const ItemTagsCompanion({
    this.itemId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemTagsCompanion.insert({
    required String itemId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : itemId = Value(itemId),
       tagId = Value(tagId);
  static Insertable<ItemTag> custom({
    Expression<String>? itemId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemId != null) 'item_id': itemId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemTagsCompanion copyWith({
    Value<String>? itemId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return ItemTagsCompanion(
      itemId: itemId ?? this.itemId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemTagsCompanion(')
          ..write('itemId: $itemId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CatalogItemsTable catalogItems = $CatalogItemsTable(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $VapeItemsTable vapeItems = $VapeItemsTable(this);
  late final $ImagesTable images = $ImagesTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $ItemTagsTable itemTags = $ItemTagsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    catalogItems,
    mediaItems,
    vapeItems,
    images,
    tags,
    itemTags,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('media_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vape_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('images', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'catalog_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('item_tags', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CatalogItemsTableCreateCompanionBuilder =
    CatalogItemsCompanion Function({
      required String id,
      required CatalogDomain domain,
      required String title,
      Value<int?> rating,
      required WatchStatus status,
      Value<UnfinishedReason?> unfinishedReason,
      Value<String?> note,
      Value<bool> isFavorite,
      Value<int> eventCount,
      Value<DateTime?> startedAt,
      Value<DatePrecision?> startedAtPrec,
      Value<DateTime?> lastActivityAt,
      Value<DatePrecision?> lastActivityAtPrec,
      Value<DateTime?> finishedAt,
      Value<DatePrecision?> finishedAtPrec,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$CatalogItemsTableUpdateCompanionBuilder =
    CatalogItemsCompanion Function({
      Value<String> id,
      Value<CatalogDomain> domain,
      Value<String> title,
      Value<int?> rating,
      Value<WatchStatus> status,
      Value<UnfinishedReason?> unfinishedReason,
      Value<String?> note,
      Value<bool> isFavorite,
      Value<int> eventCount,
      Value<DateTime?> startedAt,
      Value<DatePrecision?> startedAtPrec,
      Value<DateTime?> lastActivityAt,
      Value<DatePrecision?> lastActivityAtPrec,
      Value<DateTime?> finishedAt,
      Value<DatePrecision?> finishedAtPrec,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$CatalogItemsTableReferences
    extends BaseReferences<_$AppDatabase, $CatalogItemsTable, CatalogItem> {
  $$CatalogItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MediaItemsTable, List<MediaItem>>
  _mediaItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mediaItems,
    aliasName: 'catalog_items__id__media_items__item_id',
  );

  $$MediaItemsTableProcessedTableManager get mediaItemsRefs {
    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mediaItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$VapeItemsTable, List<VapeItem>>
  _vapeItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.vapeItems,
    aliasName: 'catalog_items__id__vape_items__item_id',
  );

  $$VapeItemsTableProcessedTableManager get vapeItemsRefs {
    final manager = $$VapeItemsTableTableManager(
      $_db,
      $_db.vapeItems,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_vapeItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImagesTable, List<ImageRow>> _imagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.images,
    aliasName: 'catalog_items__id__images__item_id',
  );

  $$ImagesTableProcessedTableManager get imagesRefs {
    final manager = $$ImagesTableTableManager(
      $_db,
      $_db.images,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_imagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTag>> _itemTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.itemTags,
    aliasName: 'catalog_items__id__item_tags__item_id',
  );

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager(
      $_db,
      $_db.itemTags,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CatalogItemsTableFilterComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CatalogDomain, CatalogDomain, String>
  get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<WatchStatus, WatchStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<UnfinishedReason?, UnfinishedReason, String>
  get unfinishedReason => $composableBuilder(
    column: $table.unfinishedReason,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get startedAt =>
      $composableBuilder(
        column: $table.startedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DatePrecision?, DatePrecision, String>
  get startedAtPrec => $composableBuilder(
    column: $table.startedAtPrec,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastActivityAt =>
      $composableBuilder(
        column: $table.lastActivityAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DatePrecision?, DatePrecision, String>
  get lastActivityAtPrec => $composableBuilder(
    column: $table.lastActivityAtPrec,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get finishedAt =>
      $composableBuilder(
        column: $table.finishedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DatePrecision?, DatePrecision, String>
  get finishedAtPrec => $composableBuilder(
    column: $table.finishedAtPrec,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> mediaItemsRefs(
    Expression<bool> Function($$MediaItemsTableFilterComposer f) f,
  ) {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> vapeItemsRefs(
    Expression<bool> Function($$VapeItemsTableFilterComposer f) f,
  ) {
    final $$VapeItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vapeItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VapeItemsTableFilterComposer(
            $db: $db,
            $table: $db.vapeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> imagesRefs(
    Expression<bool> Function($$ImagesTableFilterComposer f) f,
  ) {
    final $$ImagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableFilterComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> itemTagsRefs(
    Expression<bool> Function($$ItemTagsTableFilterComposer f) f,
  ) {
    final $$ItemTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableFilterComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unfinishedReason => $composableBuilder(
    column: $table.unfinishedReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedAtPrec => $composableBuilder(
    column: $table.startedAtPrec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastActivityAtPrec => $composableBuilder(
    column: $table.lastActivityAtPrec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishedAtPrec => $composableBuilder(
    column: $table.finishedAtPrec,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CatalogItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CatalogItemsTable> {
  $$CatalogItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CatalogDomain, String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumnWithTypeConverter<WatchStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumnWithTypeConverter<UnfinishedReason?, String>
  get unfinishedReason => $composableBuilder(
    column: $table.unfinishedReason,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eventCount => $composableBuilder(
    column: $table.eventCount,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DatePrecision?, String> get startedAtPrec =>
      $composableBuilder(
        column: $table.startedAtPrec,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastActivityAt =>
      $composableBuilder(
        column: $table.lastActivityAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DatePrecision?, String>
  get lastActivityAtPrec => $composableBuilder(
    column: $table.lastActivityAtPrec,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime?, int> get finishedAt =>
      $composableBuilder(
        column: $table.finishedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DatePrecision?, String> get finishedAtPrec =>
      $composableBuilder(
        column: $table.finishedAtPrec,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> mediaItemsRefs<T extends Object>(
    Expression<T> Function($$MediaItemsTableAnnotationComposer a) f,
  ) {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> vapeItemsRefs<T extends Object>(
    Expression<T> Function($$VapeItemsTableAnnotationComposer a) f,
  ) {
    final $$VapeItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vapeItems,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VapeItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.vapeItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> imagesRefs<T extends Object>(
    Expression<T> Function($$ImagesTableAnnotationComposer a) f,
  ) {
    final $$ImagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.images,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImagesTableAnnotationComposer(
            $db: $db,
            $table: $db.images,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> itemTagsRefs<T extends Object>(
    Expression<T> Function($$ItemTagsTableAnnotationComposer a) f,
  ) {
    final $$ItemTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CatalogItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CatalogItemsTable,
          CatalogItem,
          $$CatalogItemsTableFilterComposer,
          $$CatalogItemsTableOrderingComposer,
          $$CatalogItemsTableAnnotationComposer,
          $$CatalogItemsTableCreateCompanionBuilder,
          $$CatalogItemsTableUpdateCompanionBuilder,
          (CatalogItem, $$CatalogItemsTableReferences),
          CatalogItem,
          PrefetchHooks Function({
            bool mediaItemsRefs,
            bool vapeItemsRefs,
            bool imagesRefs,
            bool itemTagsRefs,
          })
        > {
  $$CatalogItemsTableTableManager(_$AppDatabase db, $CatalogItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CatalogItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CatalogItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CatalogItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<CatalogDomain> domain = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<WatchStatus> status = const Value.absent(),
                Value<UnfinishedReason?> unfinishedReason =
                    const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> eventCount = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DatePrecision?> startedAtPrec = const Value.absent(),
                Value<DateTime?> lastActivityAt = const Value.absent(),
                Value<DatePrecision?> lastActivityAtPrec = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<DatePrecision?> finishedAtPrec = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion(
                id: id,
                domain: domain,
                title: title,
                rating: rating,
                status: status,
                unfinishedReason: unfinishedReason,
                note: note,
                isFavorite: isFavorite,
                eventCount: eventCount,
                startedAt: startedAt,
                startedAtPrec: startedAtPrec,
                lastActivityAt: lastActivityAt,
                lastActivityAtPrec: lastActivityAtPrec,
                finishedAt: finishedAt,
                finishedAtPrec: finishedAtPrec,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required CatalogDomain domain,
                required String title,
                Value<int?> rating = const Value.absent(),
                required WatchStatus status,
                Value<UnfinishedReason?> unfinishedReason =
                    const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<int> eventCount = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DatePrecision?> startedAtPrec = const Value.absent(),
                Value<DateTime?> lastActivityAt = const Value.absent(),
                Value<DatePrecision?> lastActivityAtPrec = const Value.absent(),
                Value<DateTime?> finishedAt = const Value.absent(),
                Value<DatePrecision?> finishedAtPrec = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CatalogItemsCompanion.insert(
                id: id,
                domain: domain,
                title: title,
                rating: rating,
                status: status,
                unfinishedReason: unfinishedReason,
                note: note,
                isFavorite: isFavorite,
                eventCount: eventCount,
                startedAt: startedAt,
                startedAtPrec: startedAtPrec,
                lastActivityAt: lastActivityAt,
                lastActivityAtPrec: lastActivityAtPrec,
                finishedAt: finishedAt,
                finishedAtPrec: finishedAtPrec,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CatalogItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mediaItemsRefs = false,
                vapeItemsRefs = false,
                imagesRefs = false,
                itemTagsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (mediaItemsRefs) db.mediaItems,
                    if (vapeItemsRefs) db.vapeItems,
                    if (imagesRefs) db.images,
                    if (itemTagsRefs) db.itemTags,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (mediaItemsRefs)
                        await $_getPrefetchedData<
                          CatalogItem,
                          $CatalogItemsTable,
                          MediaItem
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogItemsTableReferences
                              ._mediaItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).mediaItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (vapeItemsRefs)
                        await $_getPrefetchedData<
                          CatalogItem,
                          $CatalogItemsTable,
                          VapeItem
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogItemsTableReferences
                              ._vapeItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).vapeItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (imagesRefs)
                        await $_getPrefetchedData<
                          CatalogItem,
                          $CatalogItemsTable,
                          ImageRow
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogItemsTableReferences
                              ._imagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).imagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (itemTagsRefs)
                        await $_getPrefetchedData<
                          CatalogItem,
                          $CatalogItemsTable,
                          ItemTag
                        >(
                          currentTable: table,
                          referencedTable: $$CatalogItemsTableReferences
                              ._itemTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CatalogItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).itemTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CatalogItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CatalogItemsTable,
      CatalogItem,
      $$CatalogItemsTableFilterComposer,
      $$CatalogItemsTableOrderingComposer,
      $$CatalogItemsTableAnnotationComposer,
      $$CatalogItemsTableCreateCompanionBuilder,
      $$CatalogItemsTableUpdateCompanionBuilder,
      (CatalogItem, $$CatalogItemsTableReferences),
      CatalogItem,
      PrefetchHooks Function({
        bool mediaItemsRefs,
        bool vapeItemsRefs,
        bool imagesRefs,
        bool itemTagsRefs,
      })
    >;
typedef $$MediaItemsTableCreateCompanionBuilder =
    MediaItemsCompanion Function({
      required String itemId,
      required MediaType mediaType,
      required MediaFormat format,
      Value<String?> originalTitle,
      Value<int?> year,
      Value<String?> country,
      Value<int?> currentSeason,
      Value<int?> currentEpisode,
      Value<int?> totalSeasons,
      Value<int?> totalEpisodes,
      Value<int> rowid,
    });
typedef $$MediaItemsTableUpdateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<String> itemId,
      Value<MediaType> mediaType,
      Value<MediaFormat> format,
      Value<String?> originalTitle,
      Value<int?> year,
      Value<String?> country,
      Value<int?> currentSeason,
      Value<int?> currentEpisode,
      Value<int?> totalSeasons,
      Value<int?> totalEpisodes,
      Value<int> rowid,
    });

final class $$MediaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem> {
  $$MediaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _itemIdTable(_$AppDatabase db) =>
      db.catalogItems.createAlias('media_items__item_id__catalog_items__id');

  $$CatalogItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$CatalogItemsTableTableManager(
      $_db,
      $_db.catalogItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<MediaType, MediaType, String> get mediaType =>
      $composableBuilder(
        column: $table.mediaType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<MediaFormat, MediaFormat, String> get format =>
      $composableBuilder(
        column: $table.format,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentSeason => $composableBuilder(
    column: $table.currentSeason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentEpisode => $composableBuilder(
    column: $table.currentEpisode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSeasons => $composableBuilder(
    column: $table.totalSeasons,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
    builder: (column) => ColumnFilters(column),
  );

  $$CatalogItemsTableFilterComposer get itemId {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableFilterComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get country => $composableBuilder(
    column: $table.country,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentSeason => $composableBuilder(
    column: $table.currentSeason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentEpisode => $composableBuilder(
    column: $table.currentEpisode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSeasons => $composableBuilder(
    column: $table.totalSeasons,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogItemsTableOrderingComposer get itemId {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableOrderingComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<MediaType, String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaFormat, String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<String> get originalTitle => $composableBuilder(
    column: $table.originalTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get country =>
      $composableBuilder(column: $table.country, builder: (column) => column);

  GeneratedColumn<int> get currentSeason => $composableBuilder(
    column: $table.currentSeason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentEpisode => $composableBuilder(
    column: $table.currentEpisode,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalSeasons => $composableBuilder(
    column: $table.totalSeasons,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalEpisodes => $composableBuilder(
    column: $table.totalEpisodes,
    builder: (column) => column,
  );

  $$CatalogItemsTableAnnotationComposer get itemId {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (MediaItem, $$MediaItemsTableReferences),
          MediaItem,
          PrefetchHooks Function({bool itemId})
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<MediaType> mediaType = const Value.absent(),
                Value<MediaFormat> format = const Value.absent(),
                Value<String?> originalTitle = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<int?> currentSeason = const Value.absent(),
                Value<int?> currentEpisode = const Value.absent(),
                Value<int?> totalSeasons = const Value.absent(),
                Value<int?> totalEpisodes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion(
                itemId: itemId,
                mediaType: mediaType,
                format: format,
                originalTitle: originalTitle,
                year: year,
                country: country,
                currentSeason: currentSeason,
                currentEpisode: currentEpisode,
                totalSeasons: totalSeasons,
                totalEpisodes: totalEpisodes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required MediaType mediaType,
                required MediaFormat format,
                Value<String?> originalTitle = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> country = const Value.absent(),
                Value<int?> currentSeason = const Value.absent(),
                Value<int?> currentEpisode = const Value.absent(),
                Value<int?> totalSeasons = const Value.absent(),
                Value<int?> totalEpisodes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion.insert(
                itemId: itemId,
                mediaType: mediaType,
                format: format,
                originalTitle: originalTitle,
                year: year,
                country: country,
                currentSeason: currentSeason,
                currentEpisode: currentEpisode,
                totalSeasons: totalSeasons,
                totalEpisodes: totalEpisodes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$MediaItemsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$MediaItemsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, $$MediaItemsTableReferences),
      MediaItem,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$VapeItemsTableCreateCompanionBuilder =
    VapeItemsCompanion Function({
      required String itemId,
      required String brand,
      required NicotineType nicotineType,
      required String nicotineStrength,
      Value<FlavorCategory?> flavorCategory,
      Value<String?> flavorDescription,
      Value<int?> sweetness,
      Value<int?> coolness,
      Value<int?> richness,
      Value<bool> canRebuy,
      Value<bool> flavorFades,
      Value<bool> damagesHardware,
      Value<int> rowid,
    });
typedef $$VapeItemsTableUpdateCompanionBuilder =
    VapeItemsCompanion Function({
      Value<String> itemId,
      Value<String> brand,
      Value<NicotineType> nicotineType,
      Value<String> nicotineStrength,
      Value<FlavorCategory?> flavorCategory,
      Value<String?> flavorDescription,
      Value<int?> sweetness,
      Value<int?> coolness,
      Value<int?> richness,
      Value<bool> canRebuy,
      Value<bool> flavorFades,
      Value<bool> damagesHardware,
      Value<int> rowid,
    });

final class $$VapeItemsTableReferences
    extends BaseReferences<_$AppDatabase, $VapeItemsTable, VapeItem> {
  $$VapeItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _itemIdTable(_$AppDatabase db) =>
      db.catalogItems.createAlias('vape_items__item_id__catalog_items__id');

  $$CatalogItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$CatalogItemsTableTableManager(
      $_db,
      $_db.catalogItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$VapeItemsTableFilterComposer
    extends Composer<_$AppDatabase, $VapeItemsTable> {
  $$VapeItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<NicotineType, NicotineType, String>
  get nicotineType => $composableBuilder(
    column: $table.nicotineType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get nicotineStrength => $composableBuilder(
    column: $table.nicotineStrength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<FlavorCategory?, FlavorCategory, String>
  get flavorCategory => $composableBuilder(
    column: $table.flavorCategory,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get flavorDescription => $composableBuilder(
    column: $table.flavorDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sweetness => $composableBuilder(
    column: $table.sweetness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get coolness => $composableBuilder(
    column: $table.coolness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get richness => $composableBuilder(
    column: $table.richness,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get canRebuy => $composableBuilder(
    column: $table.canRebuy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get flavorFades => $composableBuilder(
    column: $table.flavorFades,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get damagesHardware => $composableBuilder(
    column: $table.damagesHardware,
    builder: (column) => ColumnFilters(column),
  );

  $$CatalogItemsTableFilterComposer get itemId {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableFilterComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VapeItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $VapeItemsTable> {
  $$VapeItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nicotineType => $composableBuilder(
    column: $table.nicotineType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nicotineStrength => $composableBuilder(
    column: $table.nicotineStrength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorCategory => $composableBuilder(
    column: $table.flavorCategory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get flavorDescription => $composableBuilder(
    column: $table.flavorDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sweetness => $composableBuilder(
    column: $table.sweetness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get coolness => $composableBuilder(
    column: $table.coolness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get richness => $composableBuilder(
    column: $table.richness,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get canRebuy => $composableBuilder(
    column: $table.canRebuy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get flavorFades => $composableBuilder(
    column: $table.flavorFades,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get damagesHardware => $composableBuilder(
    column: $table.damagesHardware,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogItemsTableOrderingComposer get itemId {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableOrderingComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VapeItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VapeItemsTable> {
  $$VapeItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumnWithTypeConverter<NicotineType, String> get nicotineType =>
      $composableBuilder(
        column: $table.nicotineType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get nicotineStrength => $composableBuilder(
    column: $table.nicotineStrength,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<FlavorCategory?, String>
  get flavorCategory => $composableBuilder(
    column: $table.flavorCategory,
    builder: (column) => column,
  );

  GeneratedColumn<String> get flavorDescription => $composableBuilder(
    column: $table.flavorDescription,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sweetness =>
      $composableBuilder(column: $table.sweetness, builder: (column) => column);

  GeneratedColumn<int> get coolness =>
      $composableBuilder(column: $table.coolness, builder: (column) => column);

  GeneratedColumn<int> get richness =>
      $composableBuilder(column: $table.richness, builder: (column) => column);

  GeneratedColumn<bool> get canRebuy =>
      $composableBuilder(column: $table.canRebuy, builder: (column) => column);

  GeneratedColumn<bool> get flavorFades => $composableBuilder(
    column: $table.flavorFades,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get damagesHardware => $composableBuilder(
    column: $table.damagesHardware,
    builder: (column) => column,
  );

  $$CatalogItemsTableAnnotationComposer get itemId {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VapeItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VapeItemsTable,
          VapeItem,
          $$VapeItemsTableFilterComposer,
          $$VapeItemsTableOrderingComposer,
          $$VapeItemsTableAnnotationComposer,
          $$VapeItemsTableCreateCompanionBuilder,
          $$VapeItemsTableUpdateCompanionBuilder,
          (VapeItem, $$VapeItemsTableReferences),
          VapeItem,
          PrefetchHooks Function({bool itemId})
        > {
  $$VapeItemsTableTableManager(_$AppDatabase db, $VapeItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VapeItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VapeItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VapeItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> brand = const Value.absent(),
                Value<NicotineType> nicotineType = const Value.absent(),
                Value<String> nicotineStrength = const Value.absent(),
                Value<FlavorCategory?> flavorCategory = const Value.absent(),
                Value<String?> flavorDescription = const Value.absent(),
                Value<int?> sweetness = const Value.absent(),
                Value<int?> coolness = const Value.absent(),
                Value<int?> richness = const Value.absent(),
                Value<bool> canRebuy = const Value.absent(),
                Value<bool> flavorFades = const Value.absent(),
                Value<bool> damagesHardware = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VapeItemsCompanion(
                itemId: itemId,
                brand: brand,
                nicotineType: nicotineType,
                nicotineStrength: nicotineStrength,
                flavorCategory: flavorCategory,
                flavorDescription: flavorDescription,
                sweetness: sweetness,
                coolness: coolness,
                richness: richness,
                canRebuy: canRebuy,
                flavorFades: flavorFades,
                damagesHardware: damagesHardware,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemId,
                required String brand,
                required NicotineType nicotineType,
                required String nicotineStrength,
                Value<FlavorCategory?> flavorCategory = const Value.absent(),
                Value<String?> flavorDescription = const Value.absent(),
                Value<int?> sweetness = const Value.absent(),
                Value<int?> coolness = const Value.absent(),
                Value<int?> richness = const Value.absent(),
                Value<bool> canRebuy = const Value.absent(),
                Value<bool> flavorFades = const Value.absent(),
                Value<bool> damagesHardware = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VapeItemsCompanion.insert(
                itemId: itemId,
                brand: brand,
                nicotineType: nicotineType,
                nicotineStrength: nicotineStrength,
                flavorCategory: flavorCategory,
                flavorDescription: flavorDescription,
                sweetness: sweetness,
                coolness: coolness,
                richness: richness,
                canRebuy: canRebuy,
                flavorFades: flavorFades,
                damagesHardware: damagesHardware,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VapeItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$VapeItemsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$VapeItemsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$VapeItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VapeItemsTable,
      VapeItem,
      $$VapeItemsTableFilterComposer,
      $$VapeItemsTableOrderingComposer,
      $$VapeItemsTableAnnotationComposer,
      $$VapeItemsTableCreateCompanionBuilder,
      $$VapeItemsTableUpdateCompanionBuilder,
      (VapeItem, $$VapeItemsTableReferences),
      VapeItem,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$ImagesTableCreateCompanionBuilder =
    ImagesCompanion Function({
      required String id,
      required String itemId,
      Value<int> position,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ImagesTableUpdateCompanionBuilder =
    ImagesCompanion Function({
      Value<String> id,
      Value<String> itemId,
      Value<int> position,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ImagesTableReferences
    extends BaseReferences<_$AppDatabase, $ImagesTable, ImageRow> {
  $$ImagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _itemIdTable(_$AppDatabase db) =>
      db.catalogItems.createAlias('images__item_id__catalog_items__id');

  $$CatalogItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$CatalogItemsTableTableManager(
      $_db,
      $_db.catalogItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImagesTableFilterComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$CatalogItemsTableFilterComposer get itemId {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableFilterComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CatalogItemsTableOrderingComposer get itemId {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableOrderingComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImagesTable> {
  $$ImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CatalogItemsTableAnnotationComposer get itemId {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImagesTable,
          ImageRow,
          $$ImagesTableFilterComposer,
          $$ImagesTableOrderingComposer,
          $$ImagesTableAnnotationComposer,
          $$ImagesTableCreateCompanionBuilder,
          $$ImagesTableUpdateCompanionBuilder,
          (ImageRow, $$ImagesTableReferences),
          ImageRow,
          PrefetchHooks Function({bool itemId})
        > {
  $$ImagesTableTableManager(_$AppDatabase db, $ImagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> itemId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion(
                id: id,
                itemId: itemId,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                Value<int> position = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ImagesCompanion.insert(
                id: id,
                itemId: itemId,
                position: position,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ImagesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$ImagesTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$ImagesTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ImagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImagesTable,
      ImageRow,
      $$ImagesTableFilterComposer,
      $$ImagesTableOrderingComposer,
      $$ImagesTableAnnotationComposer,
      $$ImagesTableCreateCompanionBuilder,
      $$ImagesTableUpdateCompanionBuilder,
      (ImageRow, $$ImagesTableReferences),
      ImageRow,
      PrefetchHooks Function({bool itemId})
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      required String nameNormalized,
      Value<String?> color,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> nameNormalized,
      Value<String?> color,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ItemTagsTable, List<ItemTag>> _itemTagsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.itemTags,
    aliasName: 'tags__id__item_tags__tag_id',
  );

  $$ItemTagsTableProcessedTableManager get itemTagsRefs {
    final manager = $$ItemTagsTableTableManager(
      $_db,
      $_db.itemTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_itemTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> itemTagsRefs(
    Expression<bool> Function($$ItemTagsTableFilterComposer f) f,
  ) {
    final $$ItemTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableFilterComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameNormalized => $composableBuilder(
    column: $table.nameNormalized,
    builder: (column) => column,
  );

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> itemTagsRefs<T extends Object>(
    Expression<T> Function($$ItemTagsTableAnnotationComposer a) f,
  ) {
    final $$ItemTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.itemTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ItemTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.itemTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool itemTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> nameNormalized = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                name: name,
                nameNormalized: nameNormalized,
                color: color,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String nameNormalized,
                Value<String?> color = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                nameNormalized: nameNormalized,
                color: color,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({itemTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (itemTagsRefs) db.itemTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (itemTagsRefs)
                    await $_getPrefetchedData<TagRow, $TagsTable, ItemTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._itemTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).itemTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool itemTagsRefs})
    >;
typedef $$ItemTagsTableCreateCompanionBuilder =
    ItemTagsCompanion Function({
      required String itemId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$ItemTagsTableUpdateCompanionBuilder =
    ItemTagsCompanion Function({
      Value<String> itemId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$ItemTagsTableReferences
    extends BaseReferences<_$AppDatabase, $ItemTagsTable, ItemTag> {
  $$ItemTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CatalogItemsTable _itemIdTable(_$AppDatabase db) =>
      db.catalogItems.createAlias('item_tags__item_id__catalog_items__id');

  $$CatalogItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = $$CatalogItemsTableTableManager(
      $_db,
      $_db.catalogItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('item_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ItemTagsTableFilterComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CatalogItemsTableFilterComposer get itemId {
    final $$CatalogItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableFilterComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CatalogItemsTableOrderingComposer get itemId {
    final $$CatalogItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableOrderingComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ItemTagsTable> {
  $$ItemTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CatalogItemsTableAnnotationComposer get itemId {
    final $$CatalogItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.catalogItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CatalogItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.catalogItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ItemTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ItemTagsTable,
          ItemTag,
          $$ItemTagsTableFilterComposer,
          $$ItemTagsTableOrderingComposer,
          $$ItemTagsTableAnnotationComposer,
          $$ItemTagsTableCreateCompanionBuilder,
          $$ItemTagsTableUpdateCompanionBuilder,
          (ItemTag, $$ItemTagsTableReferences),
          ItemTag,
          PrefetchHooks Function({bool itemId, bool tagId})
        > {
  $$ItemTagsTableTableManager(_$AppDatabase db, $ItemTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItemTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItemTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItemTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> itemId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  ItemTagsCompanion(itemId: itemId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required String itemId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => ItemTagsCompanion.insert(
                itemId: itemId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ItemTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: $$ItemTagsTableReferences
                                    ._itemIdTable(db),
                                referencedColumn: $$ItemTagsTableReferences
                                    ._itemIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$ItemTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$ItemTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ItemTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ItemTagsTable,
      ItemTag,
      $$ItemTagsTableFilterComposer,
      $$ItemTagsTableOrderingComposer,
      $$ItemTagsTableAnnotationComposer,
      $$ItemTagsTableCreateCompanionBuilder,
      $$ItemTagsTableUpdateCompanionBuilder,
      (ItemTag, $$ItemTagsTableReferences),
      ItemTag,
      PrefetchHooks Function({bool itemId, bool tagId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CatalogItemsTableTableManager get catalogItems =>
      $$CatalogItemsTableTableManager(_db, _db.catalogItems);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$VapeItemsTableTableManager get vapeItems =>
      $$VapeItemsTableTableManager(_db, _db.vapeItems);
  $$ImagesTableTableManager get images =>
      $$ImagesTableTableManager(_db, _db.images);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$ItemTagsTableTableManager get itemTags =>
      $$ItemTagsTableTableManager(_db, _db.itemTags);
}
