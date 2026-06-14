import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/nav/nav_style_picker_page.dart';
import '../../core/theme/theme_context.dart';
import '../../features/media/presentation/pages/main_screen.dart';
import '../../features/media/presentation/pages/media_detail_page.dart';
import '../../features/media/presentation/pages/media_editor_page.dart';
import '../../features/media/presentation/pages/media_trash_page.dart';
import '../../features/media/presentation/pages/settings_page.dart';
import '../../features/media/presentation/pages/tags_page.dart';

/// Канонические пути навигации (A4) — единственный источник правды по
/// маршрутам. Карточка адресуется по UUID (`/item/<id>`), значит пути менять
/// задним числом нельзя — на них завязан deep-link.
abstract final class AppRoute {
  static const home = '/';
  static const editor = '/editor';
  static const settings = '/settings';
  static const tags = '/settings/tags';
  static const trash = '/settings/trash';
  static const navStyle = '/settings/nav-style';

  /// Карточка по UUID (deep-link).
  static String detail(String id) => '/item/$id';

  /// Редактирование существующей карточки по UUID.
  static String edit(String id) => '/item/$id/edit';
}

/// Собирает go_router приложения. Создаётся один раз на монтирование дерева
/// (поле `State` в `KisekiApp`): переживает пересборку темы и сбрасывается на
/// старт при Replace-all восстановлении (RestartWidget перемонтирует дерево).
///
/// OS-level deep-linking отключён (`flutter_deeplinking_enabled=false` в
/// манифестах): OAuth Я.Диска (`com.auskraft.kiseki://oauth`) ловит `app_links`
/// своим нативным каналом, а go_router отвечает только за навигацию внутри
/// приложения — иначе редирект OAuth попал бы в роутер (ADR-19).
///
/// Маршруты плоские: каждый путь = ровно одна страница, поэтому
/// `context.push`/`context.pop` дают предсказуемый стек.
GoRouter createAppRouter() => GoRouter(
      initialLocation: AppRoute.home,
      routes: [
        GoRoute(
          path: AppRoute.home,
          builder: (context, state) => const MainScreen(),
        ),
        GoRoute(
          path: AppRoute.editor,
          builder: (context, state) => const MediaEditorPage(),
        ),
        GoRoute(
          path: '/item/:id',
          builder: (context, state) =>
              MediaDetailPage(entryId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/item/:id/edit',
          builder: (context, state) =>
              MediaEditorPage(entryId: state.pathParameters['id']),
        ),
        GoRoute(
          path: AppRoute.settings,
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: AppRoute.tags,
          builder: (context, state) => const TagsPage(),
        ),
        GoRoute(
          path: AppRoute.trash,
          builder: (context, state) => const MediaTrashPage(),
        ),
        GoRoute(
          path: AppRoute.navStyle,
          builder: (context, state) => const NavStylePickerPage(),
        ),
      ],
      errorBuilder: (context, state) => const _RouteNotFound(),
    );

/// Подстраховка на случай неизвестного пути (в норме внутри приложения не
/// случается — навигация только по [AppRoute]).
class _RouteNotFound extends StatelessWidget {
  const _RouteNotFound();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 40, color: context.tokens.onFaint),
            const SizedBox(height: 12),
            Text('Страница не найдена',
                style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go(AppRoute.home),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    );
  }
}
