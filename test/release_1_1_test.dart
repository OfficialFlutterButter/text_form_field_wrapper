import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';

void main() {
  testWidgets('default borders meet 3:1 in light and dark Material 3', (
    WidgetTester tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      ThemeData.light(useMaterial3: true),
      ThemeData.dark(useMaterial3: true),
    ]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(body: TextFormFieldWrapper(formField: _field())),
        ),
      );
      _expectBorderContrast(tester);

      await tester.tap(find.byType(TextFormField));
      await tester.pump();
      _expectBorderContrast(tester);
    }
  });

  testWidgets('explicit colors win over the theme and the extension', (
    WidgetTester tester,
  ) async {
    const Color border = Colors.red;
    const Color focused = Colors.green;
    const Color fill = Colors.yellow;
    const Color shadow = Colors.blue;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: const <ThemeExtension<dynamic>>[
            TextFormFieldWrapperTheme(
              borderColor: Colors.purple,
              borderFocusedColor: Colors.orange,
              fillColor: Colors.pink,
              shadowColor: Colors.teal,
            ),
          ],
        ),
        home: Scaffold(
          body: TextFormFieldWrapper(
            borderColor: border,
            borderFocusedColor: focused,
            fillColor: fill,
            shadowColor: shadow,
            formField: _field(),
          ),
        ),
      ),
    );

    final Finder wrapper = find.byType(TextFormFieldWrapper);
    expect(_border(tester, wrapper), border);
    expect(_fill(tester, wrapper), fill);
    expect(_shadow(tester, wrapper).color, shadow.withValues(alpha: 0.5));

    await tester.tap(find.byType(TextFormField));
    await tester.pump();
    expect(_border(tester, wrapper), focused);
  });

  testWidgets('TextFormFieldWrapperTheme supplies colors and radius', (
    WidgetTester tester,
  ) async {
    const Color fill = Color(0xFF112233);
    const Color border = Color(0xFFABCDEF);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          extensions: const <ThemeExtension<dynamic>>[
            TextFormFieldWrapperTheme(
              fillColor: fill,
              borderColor: border,
              borderRadius: 4,
            ),
          ],
        ),
        home: Scaffold(body: TextFormFieldWrapper(formField: _field())),
      ),
    );

    final Finder wrapper = find.byType(TextFormFieldWrapper);
    expect(_fill(tester, wrapper), fill);
    expect(_border(tester, wrapper), border);
    final BorderRadius radius =
        _outer(tester, wrapper).borderRadius! as BorderRadius;
    expect(radius.topLeft, const Radius.circular(4));
  });

  testWidgets('hasError paints the error border', (WidgetTester tester) async {
    const Color error = Colors.red;
    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          hasError: true,
          errorBorderColor: error,
          formField: _field(),
        ),
      ),
    );
    expect(_border(tester, find.byType(TextFormFieldWrapper)), error);
  });

  testWidgets('errorText sits below a box that does not grow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_app(TextFormFieldWrapper(formField: _field())));
    final double quiet = tester
        .getSize(find.byType(TextFormFieldWrapper))
        .height;

    await tester.pumpWidget(
      _app(TextFormFieldWrapper(errorText: 'Required', formField: _field())),
    );

    final Finder box = find
        .descendant(
          of: find.byType(TextFormFieldWrapper),
          matching: find.byType(Container),
        )
        .first;
    expect(tester.getSize(box).height, quiet);
    expect(
      tester.getRect(find.text('Required')).top,
      greaterThanOrEqualTo(tester.getRect(box).bottom),
    );

    final SemanticsHandle handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.text('Required')).label,
      contains('Required'),
    );
    handle.dispose();
  });

  testWidgets('builder validator paints an error border and outside text', (
    WidgetTester tester,
  ) async {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: TextFormFieldWrapper.builder(
              validator: (String? value) => 'Required',
              fieldBuilder: (FormFieldState<String> state) {
                return TextField(
                  onChanged: state.didChange,
                  decoration: const InputDecoration(border: InputBorder.none),
                );
              },
            ),
          ),
        ),
      ),
    );

    final Finder wrapper = find.byType(TextFormFieldWrapper);
    final Color before = _border(tester, wrapper);
    final double boxHeight = tester
        .getSize(
          find.descendant(of: wrapper, matching: find.byType(Container)).first,
        )
        .height;

    formKey.currentState!.validate();
    await tester.pump();

    expect(_border(tester, wrapper), isNot(before));
    expect(
      tester
          .getSize(
            find
                .descendant(of: wrapper, matching: find.byType(Container))
                .first,
          )
          .height,
      boxHeight,
    );
    expect(
      tester.getRect(find.text('Required')).top,
      greaterThanOrEqualTo(
        tester
            .getRect(
              find
                  .descendant(of: wrapper, matching: find.byType(Container))
                  .first,
            )
            .bottom,
      ),
    );
  });

  testWidgets('bottomLeft rounds the outer edge in RTL', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: SizedBox(
              width: 800,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormFieldWrapper(
                      key: const Key('A'),
                      position: TextFormFieldPosition.bottomLeft,
                      borderRadius: 12,
                      shadowSize: 0,
                      formField: _field(),
                    ),
                  ),
                  Expanded(
                    child: TextFormFieldWrapper(
                      position: TextFormFieldPosition.bottomRight,
                      borderRadius: 12,
                      shadowSize: 0,
                      formField: _field(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final Finder leading = find.byKey(const Key('A'));
    expect(tester.getRect(leading).center.dx, greaterThan(400));
    final BorderRadius radius =
        _outer(tester, leading).borderRadius! as BorderRadius;
    expect(radius.bottomRight, const Radius.circular(12));
    expect(radius.bottomLeft, Radius.zero);
    expect(radius.topLeft, Radius.zero);
    expect(radius.topRight, Radius.zero);
  });

  testWidgets('prefix and suffix padding follow text direction', (
    WidgetTester tester,
  ) async {
    Future<void> pump(TextDirection direction) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Directionality(
              textDirection: direction,
              child: TextFormFieldWrapper(
                prefix: const SizedBox(
                  key: Key('prefix'),
                  width: 10,
                  height: 10,
                ),
                suffix: const SizedBox(
                  key: Key('suffix'),
                  width: 10,
                  height: 10,
                ),
                formField: _field(),
              ),
            ),
          ),
        ),
      );
    }

    await pump(TextDirection.ltr);
    expect(
      _paddingAround(tester, const Key('prefix')).resolve(TextDirection.ltr),
      const EdgeInsets.only(right: 8),
    );
    expect(
      _paddingAround(tester, const Key('suffix')).resolve(TextDirection.ltr),
      const EdgeInsets.only(left: 8),
    );

    await pump(TextDirection.rtl);
    expect(
      _paddingAround(tester, const Key('prefix')).resolve(TextDirection.rtl),
      const EdgeInsets.only(left: 8),
    );
    expect(
      _paddingAround(tester, const Key('suffix')).resolve(TextDirection.rtl),
      const EdgeInsets.only(right: 8),
    );
  });

  testWidgets('column follows text direction', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Directionality(
            textDirection: TextDirection.rtl,
            child: ColumnOfWrappedTextFields(
              columnFormFieldItems: [
                ColumnFormFieldItem(
                  formField: _field(),
                  prefix: const Text('Start'),
                ),
                ColumnFormFieldItem(formField: _field()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(TextFormFieldWrapper), findsNWidgets(2));
    final BorderRadius radius =
        _outer(tester, find.byType(TextFormFieldWrapper).first).borderRadius!
            as BorderRadius;
    expect(radius.topLeft.x, greaterThan(0));
    expect(radius.topRight.x, greaterThan(0));
  });
}

void _expectBorderContrast(WidgetTester tester) {
  final Finder wrapper = find.byType(TextFormFieldWrapper);
  final Color border = _border(tester, wrapper);
  final Color fill = _fill(tester, wrapper);
  final Color scaffold = Theme.of(
    tester.element(find.byType(Scaffold)),
  ).scaffoldBackgroundColor;
  expect(
    _ratio(border, fill),
    greaterThanOrEqualTo(3),
    reason: 'border=$border fill=$fill scaffold=$scaffold',
  );
  expect(
    _ratio(border, scaffold),
    greaterThanOrEqualTo(3),
    reason: 'border=$border fill=$fill scaffold=$scaffold',
  );
}

Widget _app(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

TextFormField _field() {
  return TextFormField(
    decoration: const InputDecoration(border: InputBorder.none),
  );
}

List<Container> _containers(WidgetTester tester, Finder wrapper) {
  final Element element = tester.element(wrapper);
  final List<Container> containers = <Container>[];
  void walk(Element child) {
    final Widget widget = child.widget;
    if (widget is TextFormField || widget is TextField) {
      return;
    }
    if (widget is Container) {
      containers.add(widget);
    }
    child.visitChildren(walk);
  }

  element.visitChildren(walk);
  return containers;
}

BoxDecoration _outer(WidgetTester tester, Finder wrapper) {
  return _containers(tester, wrapper).first.decoration! as BoxDecoration;
}

Color _border(WidgetTester tester, Finder wrapper) =>
    _outer(tester, wrapper).color!;

Color _fill(WidgetTester tester, Finder wrapper) {
  return (_containers(tester, wrapper).last.decoration! as BoxDecoration)
      .color!;
}

BoxShadow _shadow(WidgetTester tester, Finder wrapper) {
  return _outer(tester, wrapper).boxShadow!.single;
}

EdgeInsetsGeometry _paddingAround(WidgetTester tester, Key key) {
  final Padding padding = tester.widget<Padding>(
    find.ancestor(of: find.byKey(key), matching: find.byType(Padding)).first,
  );
  return padding.padding;
}

double _ratio(Color a, Color b) {
  final double lighter = math.max(a.computeLuminance(), b.computeLuminance());
  final double darker = math.min(a.computeLuminance(), b.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}
