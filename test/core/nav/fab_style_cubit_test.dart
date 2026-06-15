import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/nav/fab_style.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('дефолты: с подписью, без стекла, градиент вкл, уровень 2', () async {
    final c = FabStyleCubit(await SharedPreferences.getInstance());
    expect(c.state.style, FabStyle.labeled);
    expect(c.state.glass, isFalse);
    expect(c.state.gradient, isTrue);
    expect(c.state.glassLevel, 2);
  });

  test('setStyle/setGlass/setGradient сохраняются и перечитываются', () async {
    final prefs = await SharedPreferences.getInstance();
    final c = FabStyleCubit(prefs);
    c.setStyle(FabStyle.plain);
    c.setGlass(true);
    c.setGradient(false);
    expect(c.state.style, FabStyle.plain);
    expect(c.state.glass, isTrue);
    expect(c.state.gradient, isFalse);

    final reread = FabStyleCubit(prefs);
    expect(reread.state.style, FabStyle.plain);
    expect(reread.state.glass, isTrue);
    expect(reread.state.gradient, isFalse);
  });

  test('уровень стекла клампится 0..max', () async {
    final c = FabStyleCubit(await SharedPreferences.getInstance());
    c.setGlassLevel(99);
    expect(c.state.glassLevel, FabStyleCubit.maxGlassLevel);
    c.setGlassLevel(-5);
    expect(c.state.glassLevel, 0);
  });

  test('fromId: неизвестное/null → labeled', () {
    expect(FabStyle.fromId('bogus'), FabStyle.labeled);
    expect(FabStyle.fromId(null), FabStyle.labeled);
    expect(FabStyle.fromId('plain'), FabStyle.plain);
  });
}
