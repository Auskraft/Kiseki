import 'dart:io';

import 'package:path/path.dart' as p;

/// Единственное место, знающее раскладку файлов картинок (TECH_DESIGN §7.2).
/// В БД хранится только UUID; абсолютный путь собирается в рантайме из [root].
/// `full` и `thumb` носят одно имя `<id>.webp`, различаясь подкаталогом.
class MediaPaths {
  MediaPaths(this.root);

  /// Каталог приложения (getApplicationSupportDirectory), резолвится 1 раз.
  final Directory root;

  static const String ext = '.webp';

  String relFull(String id) => p.posix.join('media', 'full', '$id$ext');
  String relThumb(String id) => p.posix.join('media', 'thumb', '$id$ext');

  File absFull(String id) => File(p.join(root.path, 'media', 'full', '$id$ext'));
  File absThumb(String id) =>
      File(p.join(root.path, 'media', 'thumb', '$id$ext'));

  Directory get fullDir => Directory(p.join(root.path, 'media', 'full'));
  Directory get thumbDir => Directory(p.join(root.path, 'media', 'thumb'));
  Directory get tmpDir => Directory(p.join(root.path, 'media', '.tmp'));
}
