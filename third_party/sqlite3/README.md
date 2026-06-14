# Вендоренный SQLite (прекомпилированные бинарники)

Здесь лежат **подлинные** прекомпилированные библиотеки SQLite из GitHub-релиза
[`sqlite3-3.3.3`](https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.3.3)
пакета `package:sqlite3`.

## Зачем

`drift` тянет `sqlite3`, чей native-assets build-hook по умолчанию **скачивает**
`libsqlite3` с GitHub на каждой сборке (`sqlite3_flutter_libs` — теперь `0.6.0+eol`
и сам ничего не бандлит, доставку делегирует хуку). Из РФ загрузка с
`github.com/.../releases/download/...` регулярно падает по таймауту в Dart-овом
`HttpClient` (`SocketException ... errno = 121`), хотя GitHub доступен (PowerShell
`Invoke-WebRequest` качает тот же файл за пару секунд) — это известная болячка
Dart на Windows (IPv6 / системный прокси).

Чтобы сборка не зависела от сети, хук переключён на локальный источник в
`pubspec.yaml`:

```yaml
hooks:
  user_defines:
    sqlite3:
      source: test-sqlite3        # читает готовые бинарники из directory, sha256 сверяется
      directory: third_party/sqlite3/   # трейлинг-слеш обязателен (basePath.resolve)
```

`source: test-sqlite3` (`PrecompiledForTesting` в `lib/src/hook/description.dart`)
читает файл `<directory>/<имя-как-в-релизе>`, проверяет его sha256 против
`asset_hashes.dart` и кладёт в сборку. **Это те же байты, что и при скачивании** —
поведение приложения не меняется, FTS5 на месте (флаги сборки пакета те же).

## Что лежит (ABI)

`user_defines` глобальны — под каждую целевую платформу/ABI нужен свой файл,
названный **точно как ассет релиза** (`lib<base>.<arch>.<os>.<ext>`):

| Файл | Назначение |
|---|---|
| `libsqlite3.arm64.android.so` | Android arm64-v8a (реальные устройства, релиз) |
| `libsqlite3.arm.android.so`   | Android armeabi-v7a (старые устройства, релиз) |
| `libsqlite3.x64.android.so`   | Android x86_64 (эмулятор, релиз) |
| `sqlite3.x64.windows.dll`     | Windows x64 (`flutter test` на хосте) |

iOS (`libsqlite3.arm64.ios.dylib`, `libsqlite3.*.ios_sim.dylib`) **не вендорены** —
добавить при первой сборке на macOS, иначе хук упадёт «file not found».

## Android (бандлит сам native-asset; при сбое — flutter clean)

На android хук из `source: test-sqlite3` **пакует библиотеку сам**: при сборке
кладёт её в `build/native_assets/android/jniLibs/lib/<abi>/libsqlite3.so`, и
Flutter мёржит это в APK → `dlopen('libsqlite3.so')` её находит. **Своих копий в
`android/app/src/main/jniLibs/` добавлять НЕЛЬЗЯ** — будет
`mergeJniLibFolders: Duplicate resources` (две одинаковые либы).

Если на устройстве `dlopen('libsqlite3.so') not found` (приложение застряло на
экране восстановления БД — это ложный след, БД цела), значит
`build/native_assets/android` устарел/пуст: его сносили вместе со всем
`build/native_assets` (обход флака хост-тестов сносит и android). Лечение —
**`flutter clean` + пересборка**: native-asset перегенерится и попадёт в APK.
Поэтому в обходе флака удаляй только `build/native_assets/windows`, не всё.

## Обновление (при апгрейде версии sqlite3)

Хеши и имя тега пиннятся к версии пакета. После `flutter pub upgrade`, меняющего
`sqlite3`, посмотри новый тег в `…/pub.dev/sqlite3-<ver>/lib/src/hook/asset_hashes.dart`
(`releaseTag`) и перекачай файлы (PowerShell):

```powershell
$dir  = 'third_party/sqlite3'
$base = 'https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.3.3'  # ← новый тег
foreach ($f in 'libsqlite3.arm64.android.so','libsqlite3.arm.android.so','libsqlite3.x64.android.so','sqlite3.x64.windows.dll') {
  Invoke-WebRequest "$base/$f" -OutFile (Join-Path $dir $f) -TimeoutSec 90
  '{0}  {1}' -f (Get-FileHash (Join-Path $dir $f) -Algorithm SHA256).Hash.ToLower(), $f
}
```

Сверь распечатанные sha256 с `asset_hashes.dart` соответствующей версии. Если хук
ругается на хеш — значит версия пакета и файлы разъехались.

## Ожидаемые sha256 (релиз `sqlite3-3.3.3`)

```
9c4b75c2f7798d9aa6306811b3b412d1a0e54bd41f2304780daa4748b27a971e  libsqlite3.arm64.android.so
807999cfe7e0ccf811e7c820d6b11d31c6bb2388c6659fbc6829cd18dae4f61e  libsqlite3.arm.android.so
52c7183d99b1d85df5d09d9cf11613213f92121756df2562e7319fbe6b2a00b3  libsqlite3.x64.android.so
563a01a5fbb929844df1a9f6a84f73f7a53b9b183ebda8cb8399d69567adff09  sqlite3.x64.windows.dll
```
