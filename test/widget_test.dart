import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:word_mobile/core/widgets/app_button.dart';

void main() {
  testWidgets('AppButton renders label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppButton(label: 'Нажми')),
      ),
    );

    expect(find.text('Нажми'), findsOneWidget);
  });
}
