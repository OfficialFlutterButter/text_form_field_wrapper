import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';

void main() {
  for (final Brightness brightness in Brightness.values) {
    final String tone = brightness.name;
    testWidgets('every position $tone unfocused and focused', (
      WidgetTester tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      for (final TextFormFieldPosition position
          in TextFormFieldPosition.values) {
        for (final bool focused in <bool>[false, true]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(brightness: brightness, useMaterial3: true),
              home: Scaffold(
                body: Center(
                  child: RepaintBoundary(
                    key: const Key('frame'),
                    child: SizedBox(
                      width: 160,
                      child: TextFormFieldWrapper(
                        position: position,
                        shadowSize: 0,
                        borderRadius: 8,
                        formField: TextFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
          if (focused) {
            await tester.tap(find.byType(TextFormField));
            await tester.pump();
          }
          await expectLater(
            find.byKey(const Key('frame')),
            matchesGoldenFile(
              'goldens/position_${position.name}_${tone}_${focused ? 'focused' : 'unfocused'}.png',
            ),
          );
        }
      }
    }, tags: const ['golden']);
  }
}
