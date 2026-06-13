import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiseki/main.dart';

void main() {
  testWidgets('Счётчик увеличивается по тапу', (tester) async {
    await tester.pumpWidget(const KisekiApp());

    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
  });
}
