// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Kiseki';

  @override
  String get navLibrary => 'Картотека';

  @override
  String get navTrash => 'Корзина';

  @override
  String get emptyCatalog => 'Пока пусто. Добавьте первый фильм или сериал.';

  @override
  String get actionAdd => 'Добавить';
}
