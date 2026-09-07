import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:avesso_x_go/core/widgets/avesso_button.dart';
import 'package:avesso_x_go/core/widgets/avesso_text_field.dart';

void main() {
  group('AvessoButton', () {
    testWidgets('calls onPressed when tapped', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AvessoButton(
                label: 'Entrar',
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Entrar'));
      expect(tapped, isTrue);
    });

    testWidgets('ignores taps when disabled', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AvessoButton(
                label: 'Salvar',
                disabled: true,
                onPressed: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Salvar'));
      expect(tapped, isFalse);
    });

    testWidgets('shows loading spinner and hides label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AvessoButton(
                label: 'Entrar',
                loading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });
  });

  group('AvessoTextField', () {
    testWidgets('supports multiline input', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvessoTextField(
              multiline: true,
              hint: 'Descreva o evento',
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, greaterThan(1));
      expect(textField.keyboardType, TextInputType.multiline);

      await tester.enterText(
        find.byType(TextField),
        'Primeira linha\nSegunda linha',
      );
      expect(find.text('Primeira linha\nSegunda linha'), findsOneWidget);
    });

    testWidgets('defaults to single line', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvessoTextField(hint: 'Nome'),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLines, 1);
    });
  });
}