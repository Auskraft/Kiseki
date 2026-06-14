import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kiseki/core/ui/restart_widget.dart';

/// Регресс на находку аудита: при сбое swap() приложение раньше зависало на
/// вечном спиннере (reloadWith не снимал _busy). Теперь finally всегда
/// перемонтирует дерево, а исключение пробрасывается вызывающему.
void main() {
  testWidgets('reloadWith снимает спиннер и пробрасывает при сбое swap',
      (tester) async {
    late RestartController controller;
    await tester.pumpWidget(
      RestartWidget(
        child: Builder(
          builder: (ctx) {
            controller = RestartWidget.of(ctx);
            return const MaterialApp(
              home: Scaffold(body: Text('home')),
            );
          },
        ),
      ),
    );
    expect(find.text('home'), findsOneWidget);

    final future = controller.reloadWith(() async {
      throw StateError('boom');
    });
    // Вешаем ожидание СРАЗУ (до pump): иначе отклонение future между pump'ами
    // считается unhandled и валит тест в полном прогоне.
    final expectation = expectLater(future, throwsStateError);
    // Прокрутить 60ms-кадр демонтажа + сам сбой + ремоунт.
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    // Исключение swap должно дойти до вызывающего (не проглочено).
    await expectation;
    // И дерево вернулось (а не застряло на CircularProgressIndicator).
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('reloadWith перемонтирует дерево после успешного swap',
      (tester) async {
    late RestartController controller;
    var swapped = false;
    await tester.pumpWidget(
      RestartWidget(
        child: Builder(
          builder: (ctx) {
            controller = RestartWidget.of(ctx);
            return const MaterialApp(home: Scaffold(body: Text('home')));
          },
        ),
      ),
    );

    final future = controller.reloadWith(() async {
      swapped = true;
    });
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    await future;

    expect(swapped, isTrue);
    expect(find.text('home'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
