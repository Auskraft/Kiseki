# Kiseki — Технический дизайн (итерация 1)

> Опорный документ. Источник правды по архитектуре и схеме данных. Цель — **минимизировать будущие переделки**: всё, что дорого менять задним числом (схема БД, имена полей/enum, формат бэкапа, граница «ядро/домен»), зафиксировано здесь. Перед реализацией или спором о решении — сверяйся с этим файлом.
>
> Документ собран из 6 проектных проработок и сведён 3 независимыми ревью к одной непротиворечивой версии. Спорные места разрешены и помечены в [§3 Журнал решений](#3-журнал-ключевых-решений-adr).
>
> Сопутствующий план — [ROADMAP.md](ROADMAP.md).

---

## 1. Обзор и принципы

**Kiseki** — персональная offline-first картотека на **Flutter + flutter_bloc**. Без своего бэкенда. Локальная БД + резервное копирование в облако (Яндекс.Диск).

**Мультидоменность.** Со временем будет несколько доменов картотеки: итерация 1 — **медиа** (фильмы/сериалы/дорамы/аниме); дальше — еда, рестораны, жидкость для вейпа и т.д. Общее **ядро** (оценка, статус, даты, картинки, теги, заметка, избранное, мягкое удаление) пишется один раз; новый домен добавляется почти бесплатно — отдельной таблицей и папкой, не трогая ядро.

Ключевые принципы:

1. **Ядро + домен-плагины.** Общие поля — в одной таблице-ядре `catalog_items`; специфика домена — в связанной таблице 1:1. Любой кросс-доменный сценарий (глобальный поиск, общая корзина, обход для бэкапа) работает по ядру.
2. **Offline-first.** Локальная БД всегда первична и мгновенна. Сеть нужна только для бэкапа/восстановления; её отсутствие не ломает работу.
3. **Реактивность.** UI строится на Drift `.watch()` → bloc. Изменение данных автоматически перерисовывает списки.
4. **Зависимость строго внутрь.** `presentation → domain → data`. `domain` не знает про Drift/Flutter. Drift-модели не протекают в bloc/UI — между ними маппер.
5. **Стабильная идентичность.** Все id — UUID (не автоинкремент), ради безопасного бэкапа/мёржа между устройствами.
6. **Целостность — в БД, где можно.** FK + `ON DELETE CASCADE`, `CHECK`-инварианты, `UNIQUE`. Меньше ручных проверок в коде.

Стек (зафиксирован): Flutter / Dart, `flutter_bloc`, **Drift поверх SQLite**, **get_it** (DI), **go_router** (навигация). Целевые платформы итерации 1 — **Android + iOS** (web/desktop осознанно вне области, см. [§9](#9-сквозные-требования)).

---

## 2. Канонический реестр идентификаторов

> **Это самый важный раздел против рассинхрона.** Все имена таблиц, колонок, enum-кодов берутся ОТСЮДА — и в Drift-классах, и в SQL, и в JSON-экспорте, и в UI. Если имя нужно изменить — меняется здесь, потом везде. Не заводи синонимы.

### Таблицы

| Таблица | Назначение | PK |
|---|---|---|
| `catalog_items` | Ядро картотеки (общие поля всех доменов) | `id` TEXT (UUID) |
| `media_items` | Домен «медиа» (1:1 к ядру) | `item_id` TEXT = FK → `catalog_items.id` |
| `images` | Картинки записи (**1:N**, общие для всех доменов) | `id` TEXT (UUID) |
| `tags` | Справочник тегов (общий) | `id` TEXT (UUID) |
| `item_tags` | Связь M:N карточка↔тег | составной (`item_id`,`tag_id`) |
| `catalog_fts` | Виртуальная FTS5-таблица поиска | — (ключ `item_id`) |

### Enum-коды (хранимые строки — стабильны навсегда)

| Поле | Код в БД | Значения |
|---|---|---|
| `domain` | TEXT | `media` (далее `food`, `restaurant`, `vape`) |
| `media_type` | TEXT | `movie` · `anime` · `drama` · `cartoon` · `documentary` · `concert` · `tv_show` · `ova` · `ona` · `tv_play` (вид-категория; подпись зависит от `format` — ADR-21) |
| `format` | TEXT | `single` · `episodic` |
| `status` | TEXT | `plan` · `watching` · `completed` · `paused` · `dropped` |
| `unfinished_reason` | TEXT | `waiting_episodes` · `lost_quality` · `not_for_me` · `no_time` · `other` |
| `country` | TEXT | ISO 3166-1 alpha-2 (`KR`, `JP`, `CN`, `TH`, `US`…), nullable |
| `date_precision` | TEXT | `day` · `month` · `year` — точность каждой пользовательской даты |

### Имена полей, которые легко перепутать (зафиксированы)

| Понятие | Каноническое имя | НЕ использовать |
|---|---|---|
| Оценка 0–100 | `rating` | ~~score~~ |
| Статус «просмотрено» | `completed` | ~~done~~ |
| Причина «скатился» | `lost_quality` | ~~lost_interest~~, ~~declined~~ |
| «Последний просмотр / остановился» | `last_activity_at` | ~~last_watched_at~~ |
| «Фильм vs сериал» (дискриминатор серий) | `format` (`single`/`episodic`) | ~~вывод из media_type~~ |
| Счётчик пересмотров/визитов | `event_count` (на ядре) | ~~rewatch_count в media~~ |
| Картинка карточки | строка в таблице `images` | ~~image_full_path/image_thumb_path~~, ~~image_id на ядре~~ |

---

## 3. Журнал ключевых решений (ADR)

Краткие записи «что и почему», чтобы не перерешивать. Помечены решения, где черновики противоречили друг другу и были сведены к одному варианту.

- **ADR-01. БД — Drift поверх SQLite.** Самый обкатанный встраиваемый движок; Drift активно поддерживается, даёт типобезопасные реактивные запросы (`.watch()` → bloc), миграции первого класса, FTS5. Один файл БД = тривиальный бэкап. Альтернатива Isar отвергнута из-за рисков поддержки.
- **ADR-02. Паттерн схемы — ядро + домен 1:1** (`catalog_items` + `media_items`, PK домена = FK на ядро). Отвергнуты: single-table (лавина nullable-полей, ALTER на каждый домен) и EAV (теряется типобезопасность/FK). *[Сведение: архитектурный черновик предлагал «таблица-на-домен с mixin общих колонок без общей таблицы» — отвергнуто, ломает глобальный поиск/корзину/бэкап и требует полиморфных тегов без FK.]*
- **ADR-03. ID — UUID v4 как TEXT.** Генерирует приложение до вставки (нужно для путей картинок и оптимистичных правок). TEXT, не BLOB — читаемо в дампах, незначимая разница по объёму.
- **ADR-04. Время — INTEGER, Unix-**мс** UTC.** Через единый `TypeConverter<DateTime,int>` (millisecondsSinceEpoch), `storeDateTimeAsText: false`. **Без** `currentDateAndTime` в DEFAULT: `created_at`/`updated_at` ставит приложение в той же транзакции, что и правку. *[Сведение: черновики одновременно предписывали мс-INTEGER, секунды-INTEGER (дефолт Drift) и ISO-TEXT. Канон — мс-INTEGER; ISO-8601 только как формат экспорта на границе.]* Причина мс: LWW-мёрж близких по времени правок требует субсекундной точности.
- **ADR-05. Тай-брейк LWW.** При равных `updated_at` — детерминированно по большему `id` (UUID). Закладываем сразу (копейки, убирает класс багов при clock skew).
- **ADR-06. Инвариант времени.** **Любая** мутация записи (включая правку только доменного поля в `media_items`) обязана двигать `catalog_items.updated_at` в той же транзакции. Иначе мёрж потеряет свежую доменную правку.
- **ADR-07. `format` (`single`/`episodic`) — отдельное обязательное поле**, а не вывод из `media_type`. Причина: аниме бывает фильмом, веб-дорама — одиночкой. `format` гейтит блок серий и `CHECK`. Формат выбирается явно и **первым** (Одиночный/Серийный) — он задаёт список видов и их подписи (ADR-21). *[Сведение: модель данных не имела `format` и вешала CHECK на `media_type='movie'` — исправлено.]*
- **ADR-08. Причина «не досмотрел» — на ядре**, поле `unfinished_reason` (enum). Отдельного `*_note` нет — детали идут в общий `note` (убирает лишнее поле и баг «текст причины молча теряется при возврате к просмотру»). `waiting_episodes` («жду серии») — это `status='paused'`, **не** `dropped`. *[Сведение: имя поля и значение `lost_quality` vs `lost_interest` разъезжались — канон `unfinished_reason` / `lost_quality`.]*
- **ADR-09. Картинки — таблица `images` 1:N**, ключ — UUID картинки, файлы `<uuid>.webp`. *[Решение тех-дира, заменяет 3 расходящихся черновика: «две path-колонки на ядре», «одно `image_id` на ядре», «отдельная таблица».]* Причина: будущие домены (рестораны — «фото места/блюд») требуют нескольких фото; миграция 1:1→1:N после боевых данных и бэкапов дорогая. Конвейер картинок (UUID-имена, `.tmp`+rename, sweeper, инвалидация кеша новым UUID) при этом **не меняется** — он оперирует файлами по UUID независимо от того, где лежит ссылка. Медиа в итерации 1 — как правило одна картинка (обложка), но допускается несколько (обычно до 3 — это исключение, не норма); обложка = `MIN(position)`.
- **ADR-10. FTS5 — по UUID, не по rowid.** Виртуальная таблица `catalog_fts(item_id, title, original_title, note)`; поиск джойнится по `item_id` (UUID). Не завязываемся на `rowid` (он не переживает VACUUM/restore). После восстановления индекс перестраивается из базовых таблиц. Теги в FTS **не** кладём — фильтр по тегам реляционный. Корзина исключается на этапе запроса (`WHERE deleted_at IS NULL`), а не мутацией индекса.
- **ADR-11. Бэкап итерации 1 — snapshot, не JSON.** Архив `.kiseki` = `VACUUM INTO snapshot.sqlite` + папка картинок + `manifest.json`. Восстановление через бинарный снимок: Drift штатно прогонит `onUpgrade`. *[Сведение: JSON-дамп заявлялся «переносимым источником истины», но Drift мигрирует БД, а не JSON — отдельного JSON-мигратора нет. Поэтому JSON-экспорт и попольный merge отложены; снимок + Drift-миграции закрывают реальные сценарии.]*
- **ADR-12. Восстановление итерации 1 — только Replace-all** (переустановка / новый телефон / повреждение). Merge-LWW отложен до синхронизации устройств. Но `id`/`updated_at`/`deleted_at` уже в схеме — мёрж добавится без смены формата.
- **ADR-13. DI — get_it с ручным `configureDependencies()`.** `injectable` (кодоген) отложен до тех пор, пока список регистраций не начнёт мешать (добавление позже — механический рефакторинг, без лок-ина).
- **ADR-14. Generic-абстракции откладываем.** `CatalogRepositoryBase<T>`, плагин-реестр `DomainModule` строим при появлении 2-го домена, из двух реальных примеров. В итерации 1 — конкретный медиа-репозиторий за чистым интерфейсом + явно общие куски (`ImageStorage`, `Rating` value-object). **Дорогой core/domain split на уровне таблиц сохраняется** — переписывание Dart-слоя потом дёшево, схемы — нет.
- **ADR-15. i18n — инфраструктура сразу, переводы на бете.** Все пользовательские строки идут через ключи локализации (`flutter gen-l10n` + `.arb`), не хардкодом. В итерации 1 заполняем только русские ключи; другие языки добавляются позже (на бете) без правок кода. UI рассчитан на строки разной длины (переводы бывают длиннее).
- **ADR-16. Без внешней телеметрии.** Приложение персональное и приватное; никакого Firebase/Sentry. Только локальное логирование ошибок в debug.
- **ADR-17. Темизация — токенная система под десятки тем.** Закладываемся на **несколько десятков тем** (у каждой — режим light/dark). Никакого хардкода цветов/типографики/отступов/радиусов/теней — всё через токены. `ThemeData` собирается из дескриптора темы; темы лежат в реестре и переключаются в рантайме. Виджеты берут значения только из `Theme.of(context)` / расширений темы (`ThemeExtension`). *Реализовано:* `KisekiTokens` (`lib/core/theme/`), 5 тем × light/dark, `ThemeCubit` (персист).
- **ADR-18. Типографика и масштаб.** Тело/интерфейс — **Onest** (через `google_fonts`, рантайм; бандл `.ttf` — доработка перед бетой). Заголовки — **Unbounded** (variable-weight, забандлен в `assets/fonts/`, офлайн; кириллица проверена). Дизайн-хэндофф предлагал Lora для заголовков — заменён на Unbounded по решению владельца (2026-06-14). Общий масштаб интерфейса уменьшается единым коэффициентом `uiScale` (`lib/core/theme/app_dimens.dart`, сейчас `0.88`) — нативный размер дизайна ощущался крупным. Заголовки разделов (полки, «Все карточки») тоже на Unbounded (`titleMedium`).
- **ADR-19. Бэкап итерации 1 — фактическая реализация (упрощения).** Вместо Authorization Code + PKCE выбран **OAuth 2.0 Implicit Flow** (`response_type=token`, токен из URL-фрагмента через deep link `com.auskraft.kiseki://oauth`, `app_links`) — следуя обкатанному рабочему образцу (`rotating_shift`) и потому что Яндекс-«Веб-сервисы» принимает custom-схему как Redirect URI. Токен — в `shared_preferences` (НЕ Keychain/Keystore — TODO harden перед бетой). Одна копия с перезаписью (`app:/kiseki_backup.kiseki`), без `*.partial`/ротации/авто-refresh. Restore-teardown — через `RestartWidget` (`lib/core/ui/`): демонтаж дерева (Drift-подписки уходят до close БД) → close → подмена файла БД + картинок → `getIt.reset()`+reconfigure → пересборка с чистого корня. БД открывается **явным путём** `<AppSupport>/kiseki.sqlite` (`NativeDatabase`, не `drift_flutter`) — нужно для подмены файла; снимок сохраняет `user_version` (VACUUM мог сбросить). **Подтверждено на реальном устройстве (Android).** Формат `.kiseki` (ADR-11) и фундамент мёржа — без изменений; PKCE/Keychain/ротация/refresh добавляются позже без смены формата.
- **ADR-20. Навигация — go_router, плоские маршруты, OS deep-linking выключен (A4).** `MaterialApp.router` + единый реестр путей `AppRoute` (`lib/app/router/app_router.dart`). Маршруты **плоские** (`/`, `/item/:id`, `/settings`, `/settings/tags`, `/settings/trash` + пикеры визуала) — каждый путь = ровно одна страница, поэтому `context.push`/`context.pop` дают предсказуемый стек; карточка адресуется по UUID (`/item/<id>` — выполняет «deep-link на карточку» из DoD A4, передача аргументов через path-параметр). Роутер создаётся **один раз на монтирование дерева** (поле `State` в `KisekiApp`): переживает пересборку темы и сбрасывается на старт при Replace-all (RestartWidget перемонтирует дерево → новый роутер → после восстановления приложение открывается на главной). Прикладные блоки (`ThemeCubit`, `MediaListCubit`) живут выше `MaterialApp.router` → доступны всем маршрутам и переживают навигацию. **OS-level deep-linking отключён** (`flutter_deeplinking_enabled=false` в AndroidManifest, `FlutterDeepLinkingEnabled=false` в Info.plist): при переходе на Router API редирект OAuth `com.auskraft.kiseki://oauth` иначе попал бы и в go_router (спорная навигация / экран ошибки поверх рабочего OAuth). Редирект ловит `app_links` своим нативным каналом независимо (ADR-19); приложению OS-deep-link в карточки не нужен (личное офлайн-приложение). Модальные `showDialog`/`showModalBottomSheet` по-прежнему закрываются через `Navigator.pop(context, result)` — это оверлеи, а не маршруты go_router. `.route()`-фабрики на страницах удалены — путь к экрану теперь только через `AppRoute`. Редактор карточки вынесен из роутера в **модальный боттом-шит** (`openMediaEditor`/`showModalBottomSheet`, ADR-22): маршруты `/editor` и `/item/:id/edit` удалены.
- **ADR-21. Вид медиа (`media_type`) — таксономия «категория + формат», подпись производная.** В форме карточки сначала выбирается **формат** (Одиночный/Серийный = `format`), затем **вид** из 10 категорий (`movie`/`anime`/`drama`/`cartoon`/`documentary`/`concert`/`tv_show`/`ova`/`ona`/`tv_play`). Пользовательская подпись = функция (категория, формат): `movie`+single → «Фильм», `movie`+episodic → «Сериал», `anime`+single → «Полнометражное аниме», `anime`+episodic → «Аниме-сериал» и т.д. (`MediaType.labelFor`; формат-независимая нейтральная подпись для фильтра — `MediaType.label`). Формат остаётся **независимым** полем (ADR-07): он гейтит блок серий и CHECK, а вид и формат не дублируют друг друга. Прежний код `media_type='series'` свёрнут в `movie`+`format='episodic'` (та же категория «Фильм/Сериал») миграцией **schemaVersion 1→2** (data-only `UPDATE`, структура схемы не менялась; host-тест в `app_database_test`, проверка на устройстве — за владельцем). *Отвергнуто: 20 плоских кодов «вид-с-форматом» — дублируют `format`, ломают фильтр-по-категории, удваивают вечные enum-коды.*
- **ADR-22. Редактор карточки — модальный боттом-шит с прогрессивным раскрытием.** Создание/редактирование (экран 03) открывается `openMediaEditor` через `showModalBottomSheet(isScrollControlled, прозрачный фон)`, а НЕ go_router-роутом (маршруты `/editor`, `/item/:id/edit` удалены — согласуется с ADR-20: модалки живут на `Navigator`, не в реестре путей). Причина: воспроизводит дизайн-референс (`blood_pressure_diary`), а закрытие свайпом вниз / тапом по затемнению заменяет крестик (важно на iOS, где нет системной кнопки «назад»). Шапка минимальна: заголовок + **иконка-галочка** сохранения (крестика нет). Форма раскрывается прогрессивно: **Формат** → **Тип** → **Название** → сворачиваемый блок **«Дополнительные параметры»** (статус, оригинал, год, страна, обложка, оценка, теги, прогресс серий, причина, даты, заметка). Для этого `format`/`mediaType` в стейте редактора **nullable** (null = ещё не выбрано); `canSave` требует формат + вид + непустое название. Несохранённый ввод при закрытии — подтверждение через `PopScope` (как и системный «назад»). *Проверка свайпа-закрытия и клавиатуры на устройстве — за владельцем.*
- **ADR-23. Жанры — словарь подсказок для тегов, не отдельная таблица.** Теги остаются общим **свободным** справочником ядра (`tags`, M:N). В редакторе: чипы тегов = только **популярные у пользователя** (по числу живых карточек, `watchAllWithCounts`) + уже выбранные; поле ввода даёт инлайн-подсказки из существующих тегов (переиспользование без дублей) **и** курированного словаря жанров (`kMediaGenres` — справочный const, как `kCountries`). Выбранный жанр становится обычным тегом. *Отвергнуто (на итерацию 1): нормализованная схема `genres`/`genre_media_type` из внешнего черновика — дублирует свободные теги ядра; структурные жанры с фильтром по типу можно добавить позже доменной фичей, не трогая модель тегов. Типы медиа при этом — `MediaType` enum (ADR-21), не таблица БД.*

---

## 4. Модель данных

### 4.1. Состав и связи

```
catalog_items (ЯДРО) 1───1 media_items (домен)        PK media_items.item_id = FK → catalog_items.id, CASCADE
catalog_items        1───N images                      images.item_id → catalog_items.id, CASCADE
catalog_items        M───N tags  (через item_tags)     обе стороны CASCADE
catalog_fts (FTS5)   ←── триггеры по item_id (UUID)
```

Будущий домен (еда/ресторан/вейп) = новая таблица `<domain>_items` с `PK=item_id=FK→catalog_items.id`. Ядро, `images`, `tags`, `item_tags`, FTS — переиспользуются как есть.

### 4.2. SQL DDL (каноническое описание)

> Примечание: в Drift таблицы и индексы описываются Dart-классами и кодогенерятся; FTS5 и триггеры — сырым SQL через `customStatement` в `onCreate`/миграциях (Drift их не генерирует). Время — INTEGER мс UTC через общий конвертер (ADR-04). `PRAGMA foreign_keys = ON` включается в `beforeOpen` (в SQLite по умолчанию выкл!).

```sql
-- ЯДРО картотеки
CREATE TABLE catalog_items (
  id                TEXT    NOT NULL PRIMARY KEY,        -- UUID v4 (генерит приложение)
  domain            TEXT    NOT NULL,                    -- 'media' | future
  title             TEXT    NOT NULL CHECK (length(title) BETWEEN 1 AND 500),
  rating            INTEGER          CHECK (rating IS NULL OR rating BETWEEN 0 AND 100),
  status            TEXT    NOT NULL DEFAULT 'plan',     -- plan|watching|completed|paused|dropped
  unfinished_reason TEXT,                                -- см. enum; осмыслен при paused/dropped
  note              TEXT             CHECK (note IS NULL OR length(note) <= 10000),
  is_favorite       INTEGER NOT NULL DEFAULT 0 CHECK (is_favorite IN (0,1)),
  event_count       INTEGER NOT NULL DEFAULT 0 CHECK (event_count >= 0),  -- пересмотры/визиты
  started_at           INTEGER,                          -- Unix ms UTC, nullable
  started_at_prec      TEXT,                             -- day|month|year (точность; NULL если даты нет)
  last_activity_at     INTEGER,                          -- остановился / последний контакт
  last_activity_at_prec TEXT,
  finished_at          INTEGER,                          -- досмотрел/завершил
  finished_at_prec     TEXT,
  created_at        INTEGER NOT NULL,                    -- Unix ms UTC
  updated_at        INTEGER NOT NULL,                    -- водораздел LWW (ADR-04..06)
  deleted_at        INTEGER                              -- NULL => живая; иначе tombstone (корзина)
);

-- ДОМЕН: МЕДИА (1:1 к ядру)
CREATE TABLE media_items (
  item_id         TEXT    NOT NULL PRIMARY KEY
                    REFERENCES catalog_items(id) ON DELETE CASCADE,
  media_type      TEXT    NOT NULL,                      -- вид-категория (ADR-21); подпись зависит от format
  format          TEXT    NOT NULL,                      -- single|episodic (ADR-07)
  original_title  TEXT,                                  -- в FTS
  year            INTEGER          CHECK (year IS NULL OR year BETWEEN 1888 AND 2100),
  country         TEXT             CHECK (country IS NULL OR length(country) = 2),  -- ISO alpha-2
  current_season  INTEGER,
  current_episode INTEGER,
  total_seasons   INTEGER,
  total_episodes  INTEGER,
  -- сезонные поля существуют только у episodic:
  CHECK (format = 'episodic' OR
         (current_season IS NULL AND current_episode IS NULL
          AND total_seasons IS NULL AND total_episodes IS NULL)),
  -- серия требует сезон (для одно-сезонных UI пишет season=1, см. §6.5):
  CHECK (current_episode IS NULL OR current_season IS NOT NULL)
);

-- КАРТИНКИ (1:N, общие для всех доменов)
CREATE TABLE images (
  id         TEXT    NOT NULL PRIMARY KEY,               -- UUID; файлы media/full|thumb/<id>.webp
  item_id    TEXT    NOT NULL REFERENCES catalog_items(id) ON DELETE CASCADE,
  position   INTEGER NOT NULL DEFAULT 0,                 -- порядок; обложка = MIN(position)
  created_at INTEGER NOT NULL
);
CREATE INDEX ix_images_item ON images(item_id, position);

-- ТЕГИ (общий справочник) + связь
CREATE TABLE tags (
  id              TEXT NOT NULL PRIMARY KEY,             -- UUID
  name            TEXT NOT NULL CHECK (length(name) BETWEEN 1 AND 100),
  name_normalized TEXT NOT NULL,                         -- NFC -> lower -> trim (§9)
  color           TEXT,                                  -- напр. '#FFAA00'
  created_at      INTEGER NOT NULL
);
CREATE UNIQUE INDEX ux_tags_name_norm ON tags(name_normalized);

CREATE TABLE item_tags (
  item_id TEXT NOT NULL REFERENCES catalog_items(id) ON DELETE CASCADE,
  tag_id  TEXT NOT NULL REFERENCES tags(id)          ON DELETE CASCADE,
  PRIMARY KEY (item_id, tag_id)
);
CREATE INDEX ix_item_tags_tag ON item_tags(tag_id);     -- «все карточки с тегом X»
```

### 4.3. Индексы — минимальный набор, остальное по факту

Заводим только горячие пути; прочие сортировочные индексы добавляем по `EXPLAIN`-замерам (индекс — безболезненная аддитивная правка):

```sql
CREATE INDEX ix_ci_domain_status  ON catalog_items(domain, status) WHERE deleted_at IS NULL;
CREATE INDEX ix_ci_domain_deleted ON catalog_items(domain, deleted_at);   -- списки/корзина по домену
CREATE INDEX ix_mi_format         ON media_items(format);
-- ix_images_item, ix_item_tags_tag, ux_tags_name_norm — выше.
```

### 4.4. FTS5 (поиск)

```sql
CREATE VIRTUAL TABLE catalog_fts USING fts5(
  item_id UNINDEXED,        -- UUID карточки (ключ связи; в матчинге не участвует)
  title,
  original_title,           -- источник из media_items
  note,
  tokenize = "unicode61 remove_diacritics 2"
);
```

- Наполнение — триггерами по `item_id`: `AFTER INSERT/UPDATE/DELETE` на `catalog_items` (title, note) и `AFTER INSERT/UPDATE OF original_title` на `media_items`. Порядок вставки — **ядро → домен в одной транзакции** (триггер домена дописывает `original_title`).
- Поиск (живые записи):
  ```sql
  SELECT c.* FROM catalog_fts f
    JOIN catalog_items c ON c.id = f.item_id
   WHERE catalog_fts MATCH :q AND c.deleted_at IS NULL
   ORDER BY rank;
  ```
- После любого импорта/восстановления — полный rebuild: `DELETE FROM catalog_fts; INSERT INTO catalog_fts(item_id,title,original_title,note) SELECT c.id, c.title, m.original_title, c.note FROM catalog_items c LEFT JOIN media_items m ON m.item_id = c.id;`

### 4.5. Транзакционные инварианты (обязательны)

1. Создание карточки = `INSERT catalog_items` → `INSERT media_items` (→ при наличии картинки `INSERT images`) — **в одной транзакции**, порядок ядро→домен.
2. Любая правка (в т.ч. только доменного поля) двигает `catalog_items.updated_at` в той же транзакции (ADR-06).
3. Файлы картинок: **пишутся на диск ДО** коммита БД (add); **удаляются ПОСЛЕ** коммита (delete/purge). Снимок БД никогда не ссылается на отсутствующий файл.
4. Смена `media_type` фильм↔сериал: репозиторий сам зануляет/проставляет сезонные поля и `format`, иначе `UPDATE` упадёт на `CHECK`.
5. `name_normalized` тега считается в одном месте (репозиторий тегов), всегда `NFC → lower → trim`.

### 4.6. Миграции

- `schemaVersion = 2` (на старте был `1`; v2 — сворачивание `media_type='series'`→`movie`, ADR-21, data-only); инкремент на каждое изменение схемы.
- `onCreate`: `m.createAll()` + сырой SQL для FTS5 и триггеров + доп. индексы.
- `onUpgrade`: пошагово `if (from < N)`, **строго аддитивно** (`addColumn` nullable/с DEFAULT, `createTable`). Сложные ALTER (rename/тип) — через временную колонку → backfill → переключение, внутри транзакции миграции.
- `beforeOpen`: `PRAGMA foreign_keys = ON`.
- **Новый домен** = (1) код в enum `domain`; (2) `createTable(<domain>_items)` с PK=FK→ядро; (3) при необходимости расширить FTS/триггеры. Ядро и существующие домены не мигрируют.
- Тест миграции `vN→vN+1` на реальном дампе — обязательный шаг перед релизом.
- **Сезоны (`seasons`) — НЕ создаём в итерации 1.** Денормализованные `current_*`/`total_*` числа закрывают прогресс. Пер-сезонная разбивка — отдельной аддитивной миграцией при реальной потребности (не в `@DriftDatabase` сейчас).

---

## 5. Архитектура

### 5.1. Дерево папок (feature-first: ядро + домены-плагины)

```
lib/
├── main.dart                       # bootstrap: binding, DI, runApp
├── app/
│   ├── app.dart                    # MaterialApp.router + темы + (позже) локали
│   ├── router/app_router.dart      # go_router: маршруты
│   ├── di/injector.dart            # get_it: configureDependencies() (ручной, ADR-13)
│   └── l10n/                        # .arb + сгенерированные ключи (i18n, ADR-15)
│
├── core/                            # переиспользуемо всеми доменами; НЕ зависит от features
│   ├── database/
│   │   ├── app_database.dart        # @DriftDatabase, schemaVersion, MigrationStrategy
│   │   ├── tables/                  # catalog_items, media (см. прим.), images, tags, item_tags
│   │   ├── converters/              # datetime (ms!), enum-конвертеры, uuid
│   │   ├── fts/                     # сырой SQL: FTS5 + триггеры + rebuild
│   │   └── dao/                     # search_dao, tags_dao
│   ├── catalog/                     # обобщённое ядро (value-objects, контракты)
│   │   ├── rating.dart              # int 0–100 -> asTenScale/asStars
│   │   ├── watch_status.dart        # enum (canonical codes)
│   │   ├── unfinished_reason.dart
│   │   └── catalog_query.dart       # фильтр/сортировка (общий)
│   ├── images/
│   │   ├── image_storage.dart       # save→относит.путь, delete, runtime-резолв, sweeper
│   │   └── image_processor.dart     # ресайз 512/150, WebP (flutter_image_compress)
│   ├── backup/                      # .kiseki (snapshot+картинки+manifest), Я.Диск (позже)
│   ├── error/failures.dart          # типизированная иерархия Failure (§9)
│   └── theme/                       # токенная тема + реестр десятков тем (ADR-17)
│
└── features/
    └── media/                       # ДОМЕН 1
        ├── domain/                  # MediaEntry, MediaType, SeriesProgress; интерфейс репозитория
        ├── data/                    # media_table.dart, media_dao.dart, mapper, repository_impl
        └── presentation/
            ├── bloc/                # media_list / media_detail / media_editor
            ├── pages/               # list / detail / editor / trash
            └── widgets/             # media_card, series_progress_field, rating_input
# Будущие домены — рядом: features/food, features/restaurant, features/vape
```

> Примечание по таблицам: в итерации 1 допустимо держать `media`-таблицу в `features/media/data/tables/`, но она перечисляется в общем `@DriftDatabase(tables: [...])` (Drift статичен — это единственная вынужденная вторая точка касания ядра при добавлении домена; задокументировано в чек-листе роадмапа).

### 5.2. Слои и поток данных

```
Drift table → DAO (.watch / .watchSingle) → Repository (Row→Entity маппинг) → Bloc (подписка)
```

- **DAO** инкапсулирует SQL; фильтр/сортировка/FTS — через query-builder Drift, не в Dart над полным списком.
- **Repository** принимает `CatalogQuery` из domain, отдаёт `Stream<List<MediaEntry>>` (domain-типы, без следов Drift). Реализует CRUD + soft-delete/restore/purge + линковку тегов + работу с картинками транзакционно.
- **Bloc** держит только интерфейс репозитория (никогда не импортирует `app_database.dart`). Подписка через `emit.forEach` (сама закрывается в `close()`); пере-подписка при смене фильтра через `restartable()` (`bloc_concurrency`), иначе двойные `.watch()` и утечки.
- **Скоуп.** `AppDatabase`, `ImageStorage`, репозитории — `lazySingleton` (одна БД на приложение — критично для инвалидации стримов). Bloc/cubit — **factory** (через `BlocProvider(create: ...)`), иначе общий стейт и утечки.

### 5.3. Зависимости (pubspec)

| Пакет | Зачем |
|---|---|
| `flutter_bloc` | состояние (уже есть) |
| `bloc_concurrency` | `restartable()` — пере-подписка на Drift-стримы без гонок |
| `equatable` | value-equality для state/entity |
| `drift`, `sqlite3_flutter_libs` | БД (Drift) + нативный SQLite с FTS5 (`drift_flutter` убран — не использовался, см. ADR-19) |
| `flutter_image_compress` | ресайз 512/150 + WebP нативно |
| `image_picker` | выбор картинки из галереи/камеры |
| `path_provider`, `path` | каталог приложения; склейка относительных путей |
| `uuid` | UUID id записей/картинок/тегов |
| `get_it` | DI-контейнер (без BuildContext) |
| `go_router` | декларативная навигация |
| `flutter_localizations` (sdk) + `intl` | i18n: `gen-l10n`, `.arb`, форматирование дат/чисел по локали (ADR-15) |
| `collection` | утилиты фильтров/сортировок |
| `google_fonts` | шрифт Onest (тело); заголовки — бандл Unbounded (ADR-18) |
| `shared_preferences` | персист темы/режима (ThemeCubit) + OAuth-токен Я.Диска (ADR-19) |
| `http`, `url_launcher`, `app_links` | бэкап (ADR-19): Disk REST, открытие OAuth-браузера, deep-link возврата |
| `archive`, `crypto` | архив `.kiseki` (ZIP) + sha256-целостность манифеста |
| dev: `build_runner`, `drift_dev` | кодоген Drift |
| dev: `bloc_test`, `mocktail` | тесты bloc на моках репозитория |

Отложено (вводим позже без лок-ина): `injectable`/`injectable_generator` (ADR-13). Переводы на другие языки — на бете (инфраструктура ключей уже стоит, ADR-15).

> **Факт (отклонения от плана):** `bloc_concurrency` НЕ используется — пере-подписка на стрим сделана вручную (`MediaListCubit._resubscribe`). `go_router` добавлен (A4 сделан): `MaterialApp.router` + `lib/app/router/app_router.dart`, плоские маршруты, навигация через `context.push`/`context.pop` (ADR-20). `drift_flutter` **убран** (был неиспользуемым — БД открывается через `NativeDatabase` напрямую, ADR-19); вместе с ним ушёл транзитивный `sqlcipher_flutter_libs` (SQLCipher не нужен). Бэкап-пакеты добавлены и проверены на устройстве.

### 5.4. Стратегия тестирования

| Слой | Тест | На чём |
|---|---|---|
| domain value-objects | чистый unit | `Rating.asTenScale/asStars`, логика статус-переходов |
| repository / DAO | integration на **in-memory Drift** (`NativeDatabase.memory()`) | реальный SQL: фильтры, FTS, soft-delete, бамп `updated_at`, что `.watch()` пере-эмитит |
| миграции | отдельный тест | открыть схему vN → прогнать до vN+1 → данные целы (обязательно) |
| image lifecycle | unit + временный каталог | attach/replace/purge, sweeper, «в БД только относительный путь» |
| bloc | `bloc_test` + мок репозитория | переходы состояний, закрытие подписки |
| widgets | точечно | `RatingDisplay`, плейсхолдер картинки при отсутствии файла |

---

## 6. Домен «Медиа» — функциональная спецификация

### 6.1. Типы и формат

`media_type` (обязательно): 10 видов-категорий — `movie` · `anime` · `drama` · `cartoon` · `documentary` · `concert` · `tv_show` · `ova` · `ona` · `tv_play` (подпись зависит от формата, ADR-21).
`format` (обязательно, ADR-07): `single` (нет эпизодов — фильм, аниме-фильм, OVA) · `episodic` (есть серии). Выбирается **первым** и задаёт список/подписи видов.

Блок «сезон/серия» и причина `waiting_episodes` доступны **только при `format=episodic`**.

### 6.2. Поля карточки

**Ядро (`[Я]`)** и **медиа (`[М]`)**:

| Поле | Тип | Обяз. | Слой | Примечание |
|---|---|---|---|---|
| `id` | UUID | системное | Я | не редактируется |
| `title` | string(1..500) | **да** | Я | единственное обязательное пользовательское; в FTS |
| `rating` | int 0–100 \| null | нет | Я | `null` ≠ 0; представление отвязано (§6.4) |
| `status` | enum | да (дефолт `plan`) | Я | §6.3 |
| `unfinished_reason` | enum \| null | при `paused`/`dropped` | Я | §6.3 |
| `note` | text(≤10000) | нет | Я | личный отзыв; в FTS |
| `is_favorite` | bool | нет (дефолт false) | Я | |
| `event_count` | int ≥0 | нет (дефолт 0) | Я | «пересмотры» (для медиа) |
| `started_at` / `last_activity_at` / `finished_at` (+ `*_prec`) | date(+точность) \| null | нет | Я | приблизит. ок, §6.6 |
| `created_at`/`updated_at`/`deleted_at` | datetime | системное | Я | |
| `media_type` | enum | **да** | М | |
| `format` | enum | да (дефолт от типа) | М | |
| `original_title` | string \| null | нет | М | в FTS |
| `year` | int(1888..2100) \| null | нет | М | |
| `country` | ISO alpha-2 \| null | нет | М | рекомендуется для дорам |
| `total_seasons`/`total_episodes`/`current_season`/`current_episode` | int \| null | нет | М | только `episodic` |
| картинки | таблица `images` | нет | Я | 1:N; медиа использует одну (обложку) |
| теги | `item_tags` | нет | Я | M:N |

Валидации (мягкие предупреждения, не блок): `current_episode ≤ total_episodes`, `current_season ≤ total_seasons`, `started_at ≤ last_activity_at ≤ finished_at`.

### 6.3. Статусы и переходы

| Код | UI | Смысл |
|---|---|---|
| `plan` | В планах | хочу посмотреть |
| `watching` | Смотрю | в процессе |
| `completed` | Просмотрено | досмотрел |
| `paused` | На паузе | прервал, **вернусь** (в т.ч. «жду серии») |
| `dropped` | Заброшено | прервал, **не вернусь** |

Граф (рёбра):
```
plan      → watching | completed | dropped
watching  → paused | dropped | completed
paused    → watching | dropped | completed     (→watching сбрасывает unfinished_reason)
dropped   → watching | plan                     (сбрасывает unfinished_reason)
completed → watching | plan                     (→watching = пересмотр)
```
Ограничения — на уровне UX-подсказок, **не** жёсткой блокировки в движке (иначе сломается импорт/восстановление, где статус приходит любым).

**Обязательность:** сверх ядра жёстко обязателен только `unfinished_reason` при `paused`/`dropped`. Остальное — мягкие подсказки (картотека должна заполняться быстро).

**Причина «не досмотрел» (`unfinished_reason`):**

| Код | UI | Тяготеет к |
|---|---|---|
| `waiting_episodes` | Жду новые серии | **только `paused`** |
| `lost_quality` | Скатился | `dropped` (можно `paused`) |
| `not_for_me` | Не зашло | `dropped` |
| `no_time` | Нет времени | оба |
| `other` | Другое | оба |

**Правило «жду серии = пауза».** `waiting_episodes` доступно только при `paused` и только для `episodic`. Попытка `dropped` + «жду серии» → UX переключает на `paused`. Детали — в общий `note` (отдельного поля под причину нет, ADR-08).

**Полка «Жду новые серии»** — виртуальная секция (сохранённый пресет, не отдельный статус): `deleted_at IS NULL AND status='paused' AND unfinished_reason='waiting_episodes'`, сортировка по `last_activity_at DESC`. Пустую полку скрываем.

### 6.4. Оценка 0–100 (100-балльная)

Хранение и представление — **`int 0–100`** (100-балльная шкала). Ввод: **слайдер-спектр** (red→green, 10 градаций, дробная шкала /10, тактильный отклик, плавная смена цвета). Показ: дробная /10 (8.4) в форме, цветной бейдж в списке/карточке; цвет — `scoreColor` (10 градаций red→green, плохо→хорошо). Хранение отвязано от представления (при желании когда-нибудь можно показать как /10 или звёзды — это правка только UI, без миграции). `null` = «не оценено» (плейсхолдер «—», не «0»); при сортировке неоценённые всегда в хвосте: `ORDER BY rating IS NULL ASC, rating DESC`. Фильтр имеет опцию «Без оценки».

### 6.5. Сезоны/серии и прогресс (`episodic`)

- «Остановился на» = `current_season` + `current_episode`. Для одно-сезонных UI может скрывать поле сезона, но **в хранение всегда пишет `current_season=1`** при заданной серии (держит `CHECK`).
- Индикатор: если задан `total_episodes` и это одно-сезонный (`total_seasons` ≤ 1 или null) — «12 / 24» + полоса. Для **многосезонных абсолютную полосу не показываем** (нет пер-сезонных длин — она врала бы), показываем метку «S2 · E5». Полноценная пер-сезонная разбивка — будущая `seasons`-таблица.
- Быстрые действия «+1 / −1 серия» двигают `current_episode`, ставят `last_activity_at=сегодня`, авто-переводят `plan→watching`. При достижении `total_episodes` — мягко предлагаем `completed`.

### 6.6. Даты (нельзя смешивать!)

| Поле | Смысл | Когда |
|---|---|---|
| `created_at` | карточка заведена в приложении | авто |
| `started_at` | **начал смотреть** | вручную или при `plan→watching` |
| `last_activity_at` | остановился / последний просмотр | при паузе/инкременте серии/активности |
| `finished_at` | досмотрел | при `→completed` |

`started_at ≠ created_at` принципиально (карточку можно завести «в планах» сегодня, а смотреть начать через месяц; или внести постфактум). Пользовательские даты nullable.

**Приблизительные даты.** У каждой из трёх пользовательских дат есть точность (`*_prec`: `day`/`month`/`year`). Пользователь может задать ориентировочную дату — UI показывает «12.03.2024» / «март 2024» / «2024» соответственно. Сортировка идёт по нормализованной дате (для `year` — 1 января, для `month` — 1-е число), так что приблизительные даты не теряют сортируемости. В редакторе даты выбираются **барабаном месяц+год** (точность «месяц») в секции **«Даты просмотров»** (3 блока: Начало/Окончание/Завершение) рядом со **счётчиком пересмотров** (`event_count`, цветовая маркировка). `CatalogDate` хранит любую точность; ввод дня в UI пока не используется. Полноценный «дневник пересмотров» (даты каждого захода отдельной таблицей) — отложен; `event_count` закрывает «сколько раз». **Пользовательские даты строятся в UTC** (`normalizeCatalogDate` → `DateTime.utc`): время в БД — Unix-мс UTC (ADR-04: конвертер `toUtc()`, чтение `isUtc:true`), поэтому конструировать дату из локального `DateTime` нельзя — в часовом поясе +TZ это сдвигало бы месяц-точность на месяц назад при round-trip.

### 6.7. Экраны

- **Главный (список/грид).** Переключатель грид↔список. Сверху горизонтальные полки: «Жду новые серии», «Смотрю сейчас» (+ опц. «Избранное»). FAB-speed-dial «Добавить просмотр». Корзина — в меню ⋮ шапки. В гриде — обложка-thumbnail, `title`, бейдж оценки, иконка статуса, мини-прогресс серий, флаг избранного.
- **Вкладки-оболочка (4 таба):** Главная · **Календарь** · **Картотека** · Настройки (ленивый `IndexedStack` + свайп). **Календарь** — помесячный таймлайн просмотров (цвет = статус) + переключатель на **Гант** (полоса периода `started_at`…`finished_at` по месяцам, «что за чем»). **Картотека** — плоский список карточек + горизонтальные чипы-фильтры по статусу. Обе вкладки — с выпадашкой домена **Просмотр** / **Чтение** (Чтение — будущий домен, заглушка); общий стрим всех живых карточек `LiveCardsCubit`.
- **Поиск** — FTS5 по `title`/`original_title`/`note` (теги — реляционным фильтром), реактивно, дебаунс ~250–300 мс.
- **Фильтры:** `status`, `media_type`, `format`, `country`, теги (И/ИЛИ), `rating` (диапазон + «без оценки»), `is_favorite`, `unfinished_reason`.
- **Сортировки:** `updated_at` (дефолт), `created_at`, `rating` (null в хвост), `title`, `year`, `last_activity_at`, `finished_at` — возр./убыв.
- **Пресеты:** Жду серии · Смотрю · В планах · Просмотрено · Заброшено · Топ оценки · Без оценки · Избранное.
- **Детальная карточка** — обложка, названия, год·страна·тип; чип статуса + быстрые переходы (инлайн `unfinished_reason` при паузе/забросе); оценка; блок серий (для `episodic`); три даты; теги; `note`; `event_count` (+1); избранное; действия (редактировать, в корзину).
- **Форма создания/редактирования** (модальный боттом-шит, ADR-22) — прогрессивное раскрытие: **Формат** (Одиночный/Серийный) → **Тип** (вид, подписи по формату) → **Название** → сворачиваемые **«Дополнительные параметры»** (статус, обложка-миниатюра + оригинал/год/страна, оценка-спектр /10, теги, прогресс `episodic`, причина при паузе/забросе, «Даты просмотров» + счётчик пересмотров, заметка ≤256). Год — барабан, страна — поиск+флаги, дата — барабан месяц/год. Сохранение — иконкой-галочкой; крестика нет (закрытие свайпом). Поля серий/причины — реактивно от `format`/`status`; хаптик на чипах/барабанах/слайдере.
- **Пустые/ошибки:** пустая картотека (иллюстрация + «+»), пустой поиск («Сбросить фильтры»), пустая полка — скрыть, загрузка — скелетоны (не спиннер), повреждение БД — экран ошибки + восстановление из бэкапа, потерянный файл картинки — плейсхолдер (карточка рабочая).
- **Недостающие экраны (учесть в роадмапе):** управление тегами (переименование/слияние дублей/удаление/цвет), флоу бэкапа с прогрессом, подтверждение деструктива + safety-snapshot перед Replace-all, первый запуск с опцией «восстановить из бэкапа».

---

## 7. Конвейер изображений

### 7.1. Параметры (максимум 512×512)

| Вариант | Длинная сторона | Формат | Quality | Назначение | Вес |
|---|---|---|---|---|---|
| `full` | **512 px** | WebP lossy | 80 | детальная карточка | ~25–45 KB |
| `thumb` | **150 px** | WebP lossy | 75 | списки/грид | ~5–9 KB |

`flutter_image_compress`: `minWidth/minHeight` = bounding box (пропорции 2:3 не искажаются, без апскейла), `keepExif: false`, `autoCorrectionAngle: true` (EXIF-ориентация запекается в пиксели). `thumb` генерируется из ОРИГИНАЛА, не из `full` (без двойного кодирования). WebP — на 25–35% легче JPEG при равном качестве и сохраняет альфу (прозрачные обложки).

### 7.2. Хранение

Каталог — `getApplicationSupportDirectory()` (приватнее на iOS, не виден в Files; туда же `kiseki.sqlite` — удобно для целостного бэкапа).
```
<AppSupport>/
  kiseki.sqlite
  media/
    full/   <imageId>.webp     (≤512, q80)
    thumb/  <imageId>.webp     (150, q75)
    .tmp/                       (промежуточное сжатие → атомарный rename)
```
**В БД — только UUID картинки** (строка `images`); абсолютный путь собирается в рантайме (`root + media/full|thumb/<id>.webp`). Абсолютный путь **никогда** не персистится (на iOS UUID контейнера меняется после обновления — путь протухает). `full`/`thumb` носят одинаковое имя, различаясь подкаталогом → O(1) переход.

### 7.3. Жизненный цикл

- **Attach:** pick → валидация → `newId=uuid` → сжать в `.tmp` (оба размера) → атомарный `rename` в `full|thumb` → транзакция БД (`INSERT images`, бамп `updated_at`). Файлы пишутся ДО коммита.
- **Replace:** новый `imageId` (не перезапись по тому же пути — иначе `ImageCache` отдаст старый кадр) → коммит → удалить старые файлы ПОСЛЕ коммита + `imageCache.evict(...)`.
- **Detach/удаление карточки:** soft-delete — файлы НЕ трогаем (восстановление из корзины). Hard-delete (purge корзины) — удаляем файлы в той же транзакции с удалением строки.
- **Orphan sweeper:** на холодном старте (дебаунс раз в N запусков) + кнопка «Очистить хранилище» + всегда после импорта. Сверяет множество `imageId` из БД с файлами в `media/full|thumb`, удаляет файлы без ссылки и чистит `.tmp`. Идемпотентен; в изоляте (`compute`), чтобы не блокировать UI.

### 7.4. Производительность и объём

В списках грузится только `thumb` (~7 KB); `Image.file(cacheWidth: 150*dpr)` декодирует в нужный размер; списки виртуализированы (`SliverGrid`). Сжатие/чистка — в изоляте → скролл 60/120 fps.

Объём (доказательство масштабируемости): 1 картинка ≈ 42 KB (с запасом 50). 1000 карточек ≈ 55 MB; 5000 ≈ 280 MB. Жёсткий потолок 512 px гарантирует, что случайная 12-Мп фотография (была бы ~3–5 MB) не раздует картотеку.

### 7.5. Граничные случаи

Отмена выбора → no-op. Файл > 25 MB → `Failure.fileTooLarge`. Битый/не-изображение → `Failure.decodeFailed` (никогда не пишем полуфайл — спасает `.tmp`+rename). Прозрачность — WebP lossy сохраняет альфу. Нет картинки → плейсхолдер по типу. Файл пропал → `errorBuilder` рисует плейсхолдер (не краш), sweeper позже занулит висячую ссылку.

---

## 8. Бэкап и восстановление (Яндекс.Диск)

> Итерация 1 — это **резервное копирование, не синхронизация**. Один источник правды (устройство) → пассивное облако. Формат закладывает фундамент под будущий sync без своей смены.

### 8.1. Что и как (итерация 1)

- Архив `.kiseki` (ZIP): `VACUUM INTO snapshot.sqlite` (транзакционно-консистентный снимок, корректно учитывает WAL) + папка `images/` + обязательный `manifest.json`.
- `manifest.json`: `format_version`, `schema_version` (= `schemaVersion` Drift), `app_version`, `created_at` (UTC), `domains`, `counts`, `integrity` (sha256 по файлам). Правила чтения: `format_version` новее → отказ с понятным сообщением; `schema_version` старее → восстановление + штатный Drift `onUpgrade`; новее → отказ.
- **Восстановление — Replace-all** (ADR-12), отдельным модальным флоу: подтверждение + локальный safety-snapshot текущей БД → распаковка во временную папку → проверка манифеста/контрольных сумм → **корректный teardown live-БД** (закрыть все bloc, dispose синглтона `AppDatabase`, атомарно заменить файл БД и папку картинок, пересоздать синглтон, ре-навигация с чистого корня), Drift при открытии прогонит миграции. Прерванный restore не оставляет полу-замену.
- Транспорт — **REST API Яндекс.Диска + OAuth 2.0 (Authorization Code + PKCE, без client secret в приложении)**, redirect через deep link; токен в Keychain/Keystore (никогда в БД/бэкапе); scope — папка приложения (`cloud_api:disk.app_folder`); авто-refresh по 401; обработка 429/таймаута с возобновляемой загрузкой больших архивов.
- Заливка атомарна: `*.partial` → rename после полного успеха; ротация (N последних) — только после подтверждения нового. Ручной бэкап + полу-авто (при сети/при выходе, если есть несохранённые изменения). UI показывает дату последнего **успешного** бэкапа и статус (актуально / есть изменения / ошибка).

> **Реализовано (итерация 1, ADR-19, проверено на устройстве):** этот раздел — целевой план. Фактически: OAuth **Implicit Flow** (не PKCE), токен в `shared_preferences`, **одна копия с перезаписью** (без `*.partial`/ротации/авто-refresh), restore через `RestartWidget`. Манифест содержит `format_version`/`schema_version`/`app_version`/`created_at`/`counts`/`integrity` (поле `domains` пока не пишется). Остальное (PKCE, Keychain, ротация, refresh, авто-бэкап) — отложено без смены формата `.kiseki`.

### 8.2. Осознанно отложено (формат уже поддерживает)

JSON-переносимый экспорт и его forward-миграция; Merge-LWW по `updated_at` (попадёт вместе с синхронизацией — `id`/`updated_at`/`deleted_at`/tombstones уже в схеме, мёрж добавится без смены формата); инкрементальный бэкап; фоновый бэкап с гарантиями ОС; GC tombstones; клиентское шифрование; другие провайдеры (формат транспортно-нейтрален).

---

## 9. Сквозные требования

- **Производительность.** Keyset-пагинация (`WHERE ... LIMIT N`) поверх `.watch()` с ограниченным окном; теги в основном списке подгружать отдельным батч-запросом, а не тяжёлым JOIN на каждую строку; FTS-дебаунс ~250–300 мс; в списках только `thumb`.
- **Текст / Unicode.** Нормализация **NFC** перед `lower/trim` для `name_normalized` и перед записью `title`/`original_title` (иначе визуально одинаковые теги обходят `UNIQUE`). `note` ≤ 10000 (CHECK). В UI длинные названия — `maxLines` + ellipsis (+ tooltip). Тесты на эмодзи/CJK/комбинирующие символы.
- **Обработка ошибок.** Типизированная иерархия `Failure`: `StorageFull`, `DbCorrupted`, `FsError`, `NetworkError`, `AuthExpired`, `BackupCorrupted`, `DecodeFailed`, `FileTooLarge` — каждый маппится на действие в UI (повторить / освободить место / переподключить Диск / восстановить из бэкапа). Проверка свободного места перед `VACUUM`/распаковкой/сжатием. Детекция повреждения БД (`PRAGMA integrity_check` на старте или перехват исключения) + recovery-флоу.
  > *Реализовано (G):* `Failure` доходят до UI — картинка (причина), Я.Диск (`NetworkFailure`/`AuthExpiredFailure`), нет места. Проверка места — **реактивная** (ENOSPC errno 28 при VACUUM/распаковке → `StorageFullFailure`), а не проактивная: проактивный пре-чек требует нативного плагина (отложен на бету); восстановление безопасно, т.к. подмена идёт ПОСЛЕ успешной распаковки в temp. Повреждение БД ловит `PRAGMA quick_check` в `AppBootstrap` → `DbRecoveryScreen` (restore из бэкапа / «начать заново»).
- **Доступность (a11y).** `Semantics`-метки на иконочные действия; оценка озвучивается текстом, не только цветом (бейдж по диапазону — не единственный носитель смысла); зоны нажатия ≥ 48 dp (слайдер оценки, ±1 серия); проверка вёрстки при `textScale` 1.3–2.0.
  > *Реализовано (G):* `Semantics`/`tooltip` на иконочные контролы (навигация, действия), оценка всегда текстом. ≥48 dp тач-зоны и `textScale` 1.3–2.0 — за владельцем (меняет компактный `uiScale`-визуал).
- **Целевые платформы.** Android + iOS. Web/desktop **вне области** итерации 1 (ФС-модель картинок и нативный компрессор там не работают как описано) — соответствующие runners отключить/не поддерживать, чтобы сборка не создавала ложного впечатления.
- **Темизация (ADR-17).** Токенная система, рассчитанная на десятки тем (у каждой light/dark). Никакого хардкода — цвета/типографика/отступы/радиусы/тени только из токенов темы (`ThemeExtension`). Смена темы — в рантайме, выбор сохраняется.
- **i18n (ADR-15).** Весь текст — через ключи локализации; в итерации 1 только русские значения. Вёрстка переживает строки разной длины (будущие переводы).

---

## 10. Подтверждённые решения (бывшие открытые вопросы)

Зафиксировано пользователем 2026-06-14:

1. **Картинки — `images` 1:N** (ADR-09). Подтверждено: обычно одна, изредка до 3.
2. **Приблизительные даты — включены** (§6.6): точность день/месяц/год, пользователь задаёт ориентировочно.
3. **Оценка — 100-балльная** (§6.4): ввод и показ 0–100.
4. **Бэкап картинок** — по умолчанию полный; «лёгкий» (только `thumb`+БД, ~50 MB на 5k) доступен опцией для экономии трафика.
5. **i18n** — инфраструктура ключей сразу, переводы на бете (ADR-15).
6. **Темизация** — десятки тем, токены, без хардкода (ADR-17).

---

*Изменения в этом документе — через явную правку соответствующего ADR/раздела и обновление [§2 Реестра](#2-канонический-реестр-идентификаторов), чтобы имена никогда не разъезжались снова.*
