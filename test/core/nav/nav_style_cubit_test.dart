import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/nav/nav_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('дефолты: капсула, стекло вкл, уровень 2, градиент вкл', () async {
    final c = NavStyleCubit(await SharedPreferences.getInstance());
    expect(c.state.style, NavBarStyle.capsule);
    expect(c.state.glass, isTrue);
    expect(c.state.glassLevel, 2);
    expect(c.state.gradient, isTrue);
  });

  test('setStyle сохраняет и перечитывается новым кубитом', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = NavStyleCubit(prefs);
    c.setStyle(NavBarStyle.floating);
    expect(c.state.style, NavBarStyle.floating);
    expect(prefs.getString('nav_bar_style'), 'floating');
    expect(NavStyleCubit(prefs).state.style, NavBarStyle.floating);
  });

  test('стекло/градиент сохраняются; уровень клампится 0..max', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = NavStyleCubit(prefs);
    c.setGlass(false);
    c.setGradient(false);
    c.setGlassLevel(99);
    expect(c.state.glass, isFalse);
    expect(c.state.gradient, isFalse);
    expect(c.state.glassLevel, NavStyleCubit.maxGlassLevel);
    c.setGlassLevel(-3);
    expect(c.state.glassLevel, 0);

    final reread = NavStyleCubit(prefs);
    expect(reread.state.glass, isFalse);
    expect(reread.state.gradient, isFalse);
    expect(reread.state.glassLevel, 0);
  });

  test('fromId: неизвестное/null → капсула (фолбэк)', () {
    expect(NavBarStyle.fromId('bogus'), NavBarStyle.capsule);
    expect(NavBarStyle.fromId(null), NavBarStyle.capsule);
    expect(NavBarStyle.fromId('floating'), NavBarStyle.floating);
    expect(NavBarStyle.fromId('classic'), NavBarStyle.classic);
  });
}
