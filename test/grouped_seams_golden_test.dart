import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';

void main() {
  testWidgets('grouped top bottomLeft and bottomRight fields share one seam', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 400));
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topCenter,
            child: RepaintBoundary(
              key: const Key('grouped-seams'),
              child: ColoredBox(
                color: const Color(0xFFFFFFFF),
                child: SizedBox(
                  width: 240,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormFieldWrapper(
                        position: TextFormFieldPosition.top,
                        shadowSize: 0,
                        formField: TextFormField(
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormFieldWrapper(
                              position: TextFormFieldPosition.bottomLeft,
                              shadowSize: 0,
                              formField: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextFormFieldWrapper(
                              position: TextFormFieldPosition.bottomRight,
                              shadowSize: 0,
                              formField: TextFormField(
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await expectLater(
      find.byKey(const Key('grouped-seams')),
      matchesGoldenFile('goldens/grouped_field_seams.png'),
    );
  }, tags: const ['golden']);
}
