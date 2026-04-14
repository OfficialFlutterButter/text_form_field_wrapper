import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';

void main() {
  Container findBorderContainer(WidgetTester tester, Color color) {
    return tester.widgetList<Container>(find.byType(Container)).firstWhere((
      container,
    ) {
      final decoration = container.decoration;
      return decoration is BoxDecoration && decoration.color == color;
    });
  }

  testWidgets('updates border color when field gains focus', (
    WidgetTester tester,
  ) async {
    const unfocusedColor = Colors.red;
    const focusedColor = Colors.green;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFormFieldWrapper(
            borderColor: unfocusedColor,
            borderFocusedColor: focusedColor,
            formField: TextFormField(
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ),
    );

    expect(findBorderContainer(tester, unfocusedColor), isNotNull);

    await tester.tap(find.byType(TextFormField));
    await tester.pumpAndSettle();

    expect(findBorderContainer(tester, focusedColor), isNotNull);
  });

  testWidgets('applies corner radius based on topLeft position', (
    WidgetTester tester,
  ) async {
    const borderRadius = 14.0;
    const borderColor = Colors.orange;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TextFormFieldWrapper(
            borderRadius: borderRadius,
            borderColor: borderColor,
            position: TextFormFieldPosition.topLeft,
            formField: TextFormField(
              decoration: InputDecoration(border: InputBorder.none),
            ),
          ),
        ),
      ),
    );

    final borderContainer = findBorderContainer(tester, borderColor);
    final decoration = borderContainer.decoration! as BoxDecoration;
    final border = decoration.borderRadius! as BorderRadius;

    expect(border.topLeft, const Radius.circular(borderRadius));
    expect(border.topRight, Radius.zero);
    expect(border.bottomLeft, Radius.zero);
    expect(border.bottomRight, Radius.zero);
  });
}
