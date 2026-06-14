// Сырой SQL для FTS5 и триггеров синхронизации (Drift их не генерирует).
//
// Поиск ключуется по `item_id` (UUID), НЕ по rowid (ADR-10) — индекс
// переживает VACUUM/restore. Источник смешанный: title/note из
// `catalog_items`, original_title из `media_items` — поэтому триггеры
// на обеих таблицах. Корзина (deleted_at) НЕ вырезается из индекса —
// она отфильтровывается на этапе запроса (JOIN ... WHERE deleted_at IS NULL).

const List<String> ftsAndTriggerStatements = [
  '''
CREATE VIRTUAL TABLE catalog_fts USING fts5(
  item_id UNINDEXED,
  title,
  original_title,
  note,
  tokenize = "unicode61 remove_diacritics 2"
);
''',
  // Вставка карточки -> строка FTS (original_title подтянется из media, если есть).
  '''
CREATE TRIGGER trg_ci_ai AFTER INSERT ON catalog_items BEGIN
  INSERT INTO catalog_fts(item_id, title, original_title, note)
  VALUES (new.id, new.title,
          (SELECT original_title FROM media_items WHERE item_id = new.id),
          new.note);
END;
''',
  // Обновление ядра -> пересобрать строку FTS (title/note + текущий original_title).
  '''
CREATE TRIGGER trg_ci_au AFTER UPDATE ON catalog_items BEGIN
  DELETE FROM catalog_fts WHERE item_id = old.id;
  INSERT INTO catalog_fts(item_id, title, original_title, note)
  VALUES (new.id, new.title,
          (SELECT original_title FROM media_items WHERE item_id = new.id),
          new.note);
END;
''',
  // Физическое удаление карточки -> убрать из FTS.
  '''
CREATE TRIGGER trg_ci_ad AFTER DELETE ON catalog_items BEGIN
  DELETE FROM catalog_fts WHERE item_id = old.id;
END;
''',
  // Вставка media -> проставить original_title в строке FTS карточки.
  '''
CREATE TRIGGER trg_mi_ai AFTER INSERT ON media_items BEGIN
  UPDATE catalog_fts SET original_title = new.original_title
  WHERE item_id = new.item_id;
END;
''',
  // Смена original_title -> обновить FTS.
  '''
CREATE TRIGGER trg_mi_au AFTER UPDATE OF original_title ON media_items BEGIN
  UPDATE catalog_fts SET original_title = new.original_title
  WHERE item_id = new.item_id;
END;
''',
];

/// Частичные/составные индексы под горячие пути (TECH_DESIGN §4.3).
const List<String> extraIndexStatements = [
  'CREATE INDEX ix_ci_domain_status ON catalog_items(domain, status) WHERE deleted_at IS NULL;',
  'CREATE INDEX ix_ci_domain_deleted ON catalog_items(domain, deleted_at);',
  'CREATE INDEX ix_mi_format ON media_items(format);',
  'CREATE INDEX ix_images_item ON images(item_id, position);',
  'CREATE INDEX ix_item_tags_tag ON item_tags(tag_id);',
];

/// Полная пересборка FTS из базовых таблиц (после restore/миграции схемы FTS).
const String ftsRebuildClear = 'DELETE FROM catalog_fts;';
const String ftsRebuildFill = '''
INSERT INTO catalog_fts(item_id, title, original_title, note)
SELECT c.id, c.title, m.original_title, c.note
FROM catalog_items c
LEFT JOIN media_items m ON m.item_id = c.id;
''';
