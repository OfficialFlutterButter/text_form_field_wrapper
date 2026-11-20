import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';

void main() {
  setUp(() {
    TextFormFieldWrapper.debugFocusNotificationCount = 0;
  });

  testWidgets('updates the border color when the field gains focus', (
    WidgetTester tester,
  ) async {
    const Color unfocusedColor = Colors.red;
    const Color focusedColor = Colors.green;

    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          borderColor: unfocusedColor,
          borderFocusedColor: focusedColor,
          formField: _field(),
        ),
      ),
    );

    expect(_borderColor(tester, find.byType(TextFormFieldWrapper)),
        unfocusedColor);

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    expect(
        _borderColor(tester, find.byType(TextFormFieldWrapper)), focusedColor);
  });

  testWidgets('rounds only the outer corners for topLeft', (
    WidgetTester tester,
  ) async {
    const double borderRadius = 14;

    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          borderRadius: borderRadius,
          position: TextFormFieldPosition.topLeft,
          formField: _field(),
        ),
      ),
    );

    final BorderRadius radius =
        _outerDecoration(tester, find.byType(TextFormFieldWrapper))
            .borderRadius! as BorderRadius;
    expect(radius.topLeft, const Radius.circular(borderRadius));
    expect(radius.topRight, Radius.zero);
    expect(radius.bottomLeft, Radius.zero);
    expect(radius.bottomRight, Radius.zero);
  });

  testWidgets('registers the focus listener once across rebuilds', (
    WidgetTester tester,
  ) async {
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: _RebuildHost())));
    final _RebuildHostState host = tester.state(find.byType(_RebuildHost));

    for (int i = 0; i < 100; i++) {
      host.bump();
      await tester.pump();
    }

    TextFormFieldWrapper.debugFocusNotificationCount = 0;
    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    expect(TextFormFieldWrapper.debugFocusNotificationCount, 1);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(TextFormFieldWrapper.debugFocusNotificationCount, 2);
  });

  testWidgets('disposes its focus node with the wrapper',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(TextFormFieldWrapper(formField: _field())));
    final FocusNode node =
        _wrapperFocusNode(tester, find.byType(TextFormFieldWrapper));

    await tester.pumpWidget(const SizedBox.shrink());

    expect(() => node.addListener(() {}), throwsFlutterError);
  });

  testWidgets('keeps light-mode colors from 1.0.0',
      (WidgetTester tester) async {
    await tester.pumpWidget(_app(TextFormFieldWrapper(formField: _field())));
    final Finder wrapper = find.byType(TextFormFieldWrapper);

    expect(_fillColor(tester, wrapper), Colors.grey.shade50);
    expect(_borderColor(tester, wrapper), Colors.grey.shade300);
    final BoxShadow shadow =
        _outerDecoration(tester, wrapper).boxShadow!.single;
    expect(shadow.color, Colors.grey.withValues(alpha: 0.5));

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    expect(_borderColor(tester, wrapper), Colors.lightBlue.shade300);
    expect(_fillColor(tester, wrapper), Colors.grey.shade50);
  });

  testWidgets('dark-mode text contrast against the fill is at least 4.5:1', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          formField: TextFormField(
            initialValue: 'hello',
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
        theme: ThemeData.dark(useMaterial3: true),
      ),
    );

    final Finder wrapper = find.byType(TextFormFieldWrapper);
    final Color fill = _fillColor(tester, wrapper);
    final Color text =
        tester.widget<EditableText>(find.byType(EditableText)).style.color!;
    final double ratio = _contrastRatio(fill, text);

    expect(fill, isNot(Colors.grey.shade50));
    expect(
      ratio,
      greaterThanOrEqualTo(4.5),
      reason: 'fill=${fill.toARGB32().toRadixString(16)} '
          'text=${text.toARGB32().toRadixString(16)} ratio=$ratio',
    );
  });

  testWidgets('uses InputDecorationTheme.fillColor in dark mode', (
    WidgetTester tester,
  ) async {
    const Color themeFill = Color(0xFF123456);
    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(formField: _field()),
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          inputDecorationTheme:
              const InputDecorationTheme(fillColor: themeFill),
        ),
      ),
    );

    expect(_fillColor(tester, find.byType(TextFormFieldWrapper)), themeFill);
  });

  testWidgets('fillColor and disabledFillColor override the defaults', (
    WidgetTester tester,
  ) async {
    const Color enabledFill = Colors.pink;
    const Color disabledFill = Colors.teal;

    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          fillColor: enabledFill,
          disabledFillColor: disabledFill,
          formField: _field(),
        ),
      ),
    );
    expect(_fillColor(tester, find.byType(TextFormFieldWrapper)), enabledFill);

    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          fillColor: enabledFill,
          disabledFillColor: disabledFill,
          formField: _field(enabled: false),
        ),
        theme: ThemeData.dark(useMaterial3: true),
      ),
    );
    expect(_fillColor(tester, find.byType(TextFormFieldWrapper)), disabledFill);
  });

  testWidgets('disabled field uses the disabled fill unless overridden', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _app(TextFormFieldWrapper(formField: _field(enabled: false))),
    );
    expect(_fillColor(tester, find.byType(TextFormFieldWrapper)),
        Colors.grey.shade100);

    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          isEnabled: true,
          formField: _field(enabled: false),
        ),
      ),
    );
    expect(_fillColor(tester, find.byType(TextFormFieldWrapper)),
        Colors.grey.shade50);

    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          isEnabled: false,
          formField: _field(),
        ),
      ),
    );
    expect(_fillColor(tester, find.byType(TextFormFieldWrapper)),
        Colors.grey.shade100);
  });

  testWidgets('column follows each field enabled flag',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(
        ColumnOfWrappedTextFields(
          columnFormFieldItems: [
            ColumnFormFieldItem(formField: _field()),
            ColumnFormFieldItem(formField: _field(enabled: false)),
          ],
        ),
      ),
    );

    final Finder wrappers = find.byType(TextFormFieldWrapper);
    expect(_fillColor(tester, wrappers.at(0)), Colors.grey.shade50);
    expect(_fillColor(tester, wrappers.at(1)), Colors.grey.shade100);
  });

  testWidgets('focus does not move or resize a bottom field',
      (WidgetTester tester) async {
    const Key bottomKey = Key('bottom-field');
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            TextFormFieldWrapper(
              position: TextFormFieldPosition.top,
              formField: _field(),
            ),
            TextFormFieldWrapper(
              position: TextFormFieldPosition.bottom,
              formField: _field(key: bottomKey),
            ),
          ],
        ),
      ),
    );

    final Finder bottom = find.byKey(bottomKey);
    final Finder bottomWrapper = find.ancestor(
      of: bottom,
      matching: find.byType(TextFormFieldWrapper),
    );
    final Size wrapperSize = tester.getSize(bottomWrapper);
    final Rect fieldRect = tester.getRect(bottom);
    final Rect topRect =
        tester.getRect(find.byType(TextFormFieldWrapper).first);

    await tester.tap(bottom);
    await tester.pump();

    expect(tester.getSize(bottomWrapper), wrapperSize);
    expect(tester.getRect(bottom), fieldRect);
    expect(tester.getRect(find.byType(TextFormFieldWrapper).first), topRect);

    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();

    expect(tester.getSize(bottomWrapper), wrapperSize);
    expect(tester.getRect(bottom), fieldRect);
  });

  testWidgets('focus does not move or resize a bottomLeft field', (
    WidgetTester tester,
  ) async {
    const Key fieldKey = Key('bottom-left-field');
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            TextFormFieldWrapper(
              position: TextFormFieldPosition.top,
              formField: _field(),
            ),
            TextFormFieldWrapper(
              position: TextFormFieldPosition.bottomLeft,
              formField: _field(key: fieldKey),
            ),
          ],
        ),
      ),
    );

    final Finder field = find.byKey(fieldKey);
    final Finder wrapper = find.ancestor(
      of: field,
      matching: find.byType(TextFormFieldWrapper),
    );
    final Size wrapperSize = tester.getSize(wrapper);
    final Rect fieldRect = tester.getRect(field);

    await tester.tap(field);
    await tester.pump();

    expect(tester.getSize(wrapper), wrapperSize);
    expect(tester.getRect(field), fieldRect);
  });

  testWidgets('grouped fields keep a single shared seam', (
    WidgetTester tester,
  ) async {
    const Color border = Color(0xFF000000);
    const Color fill = Color(0xFFFFFFFF);
    await tester.pumpWidget(
      _app(
        SizedBox(
          width: 240,
          child: Column(
            children: [
              TextFormFieldWrapper(
                key: const Key('top'),
                position: TextFormFieldPosition.top,
                borderRadius: 0,
                shadowSize: 0,
                borderThickness: 6,
                borderFocusedThickness: 6,
                borderColor: border,
                borderFocusedColor: border,
                fillColor: fill,
                formField: _field(),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormFieldWrapper(
                      key: const Key('left'),
                      position: TextFormFieldPosition.bottomLeft,
                      borderRadius: 0,
                      shadowSize: 0,
                      borderThickness: 6,
                      borderFocusedThickness: 6,
                      borderColor: border,
                      borderFocusedColor: border,
                      fillColor: fill,
                      formField: _field(key: const Key('left-field')),
                    ),
                  ),
                  Expanded(
                    child: TextFormFieldWrapper(
                      key: const Key('right'),
                      position: TextFormFieldPosition.bottomRight,
                      borderRadius: 0,
                      shadowSize: 0,
                      borderThickness: 6,
                      borderFocusedThickness: 6,
                      borderColor: border,
                      borderFocusedColor: border,
                      fillColor: fill,
                      formField: _field(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    void expectSingleSeam() {
      final Finder top = find.byKey(const Key('top'));
      final Finder left = find.byKey(const Key('left'));
      final Finder right = find.byKey(const Key('right'));
      expect(tester.getRect(top).bottom, tester.getRect(left).top);
      expect(tester.getRect(left).right, tester.getRect(right).left);
      // The top field owns the horizontal seam. Neighbors below do not paint
      // a second border there, including after one of them takes focus.
      expect(_outerPadding(tester, top).bottom, 6);
      expect(_outerPadding(tester, left).top, 0);
      expect(_outerPadding(tester, right).top, 0);
      // The left field owns the vertical seam.
      expect(_outerPadding(tester, left).right, 6);
      expect(_outerPadding(tester, right).left, 0);
    }

    expectSingleSeam();
    await tester.tap(find.byKey(const Key('left-field')));
    await tester.pump();
    expectSingleSeam();
  });

  testWidgets('inner corner radius is never negative',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(
        TextFormFieldWrapper(
          borderRadius: 2,
          borderThickness: 1,
          borderFocusedThickness: 3,
          formField: _field(),
        ),
      ),
    );
    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    final BorderRadius radius =
        _innerDecoration(tester, find.byType(TextFormFieldWrapper))
            .borderRadius! as BorderRadius;
    expect(radius.topLeft.x, greaterThanOrEqualTo(0));
    expect(radius.topRight.x, greaterThanOrEqualTo(0));
    expect(radius.bottomLeft.x, greaterThanOrEqualTo(0));
    expect(radius.bottomRight.x, greaterThanOrEqualTo(0));
    expect(radius.topLeft, Radius.zero);
  });

  test('constructor rejects a negative radius or thickness', () {
    expect(
      () => TextFormFieldWrapper(borderRadius: -1, formField: _field()),
      throwsAssertionError,
    );
    expect(
      () => TextFormFieldWrapper(borderThickness: -1, formField: _field()),
      throwsAssertionError,
    );
    expect(
      () => TextFormFieldWrapper(
        borderFocusedThickness: -1,
        formField: _field(),
      ),
      throwsAssertionError,
    );
  });

  testWidgets('tab moves from one wrapped field to the next',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _app(
        Column(
          children: [
            TextFormFieldWrapper(formField: _field()),
            TextFormFieldWrapper(formField: _field()),
          ],
        ),
      ),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_primaryEditableIndex(tester), 0);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(_primaryEditableIndex(tester), 1);
  });

  testWidgets('wrapper adds no extra focusable semantics node', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await tester.pumpWidget(_app(_field()));
    final int bare = _focusableSemanticsCount(tester);

    await tester.pumpWidget(_app(TextFormFieldWrapper(formField: _field())));
    final int wrapped = _focusableSemanticsCount(tester);
    handle.dispose();

    expect(bare, greaterThan(0));
    expect(wrapped, bare);
  });
}

class _RebuildHost extends StatefulWidget {
  const _RebuildHost();

  @override
  State<_RebuildHost> createState() => _RebuildHostState();
}

class _RebuildHostState extends State<_RebuildHost> {
  int _ticks = 0;

  void bump() => setState(() => _ticks++);

  @override
  Widget build(BuildContext context) {
    return TextFormFieldWrapper(
      formField: TextFormField(
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: '$_ticks',
        ),
      ),
    );
  }
}

Widget _app(Widget child, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: child),
  );
}

TextFormField _field({Key? key, bool enabled = true}) {
  return TextFormField(
    key: key,
    enabled: enabled,
    decoration: const InputDecoration(border: InputBorder.none),
  );
}

List<Container> _wrapperContainers(WidgetTester tester, Finder wrapper) {
  final Element element = tester.element(wrapper);
  final List<Container> containers = <Container>[];
  void walk(Element child) {
    final Widget widget = child.widget;
    if (widget is FormField) {
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

BoxDecoration _outerDecoration(WidgetTester tester, Finder wrapper) {
  return _wrapperContainers(tester, wrapper).first.decoration! as BoxDecoration;
}

BoxDecoration _innerDecoration(WidgetTester tester, Finder wrapper) {
  return _wrapperContainers(tester, wrapper).last.decoration! as BoxDecoration;
}

Color _borderColor(WidgetTester tester, Finder wrapper) {
  return _outerDecoration(tester, wrapper).color!;
}

Color _fillColor(WidgetTester tester, Finder wrapper) {
  return _innerDecoration(tester, wrapper).color!;
}

EdgeInsets _outerPadding(WidgetTester tester, Finder wrapper) {
  return _wrapperContainers(tester, wrapper).first.padding! as EdgeInsets;
}

FocusNode _wrapperFocusNode(WidgetTester tester, Finder wrapper) {
  final Element element = tester.element(wrapper);
  FocusNode? node;
  void walk(Element child) {
    final Widget widget = child.widget;
    if (widget is Focus && widget.focusNode != null) {
      node = widget.focusNode;
      return;
    }
    if (widget is FormField) {
      return;
    }
    child.visitChildren(walk);
  }

  element.visitChildren(walk);
  return node!;
}

int _primaryEditableIndex(WidgetTester tester) {
  final List<EditableText> editors =
      tester.widgetList<EditableText>(find.byType(EditableText)).toList();
  return editors
      .indexWhere((EditableText editor) => editor.focusNode.hasPrimaryFocus);
}

int _focusableSemanticsCount(WidgetTester tester) {
  int count = 0;
  bool walk(SemanticsNode node) {
    if (node.flagsCollection.isFocused != ui.Tristate.none) {
      count++;
    }
    node.visitChildren(walk);
    return true;
  }

  for (final RenderView view in tester.binding.renderViews) {
    final SemanticsNode? root = view.owner?.semanticsOwner?.rootSemanticsNode;
    if (root != null) {
      walk(root);
    }
  }
  return count;
}

double _contrastRatio(Color a, Color b) {
  final double lighter = math.max(a.computeLuminance(), b.computeLuminance());
  final double darker = math.min(a.computeLuminance(), b.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}
