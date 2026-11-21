/// Draws connected borders around form fields so grouped fields share one seam.
library;

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:material_ui/material_ui.dart';

/// Where a [TextFormFieldWrapper] sits relative to the wrappers beside it.
///
/// Shared edges are omitted so two neighbors paint one line, not two.
/// `left` and `right` follow the ambient [TextDirection]: left is the start
/// edge and right is the end edge. In left-to-right text that is the physical
/// left and right. In right-to-left text they swap.
enum TextFormFieldPosition {
  /// No edge touches another wrapper.
  alone,

  /// Only the bottom edge touches another wrapper.
  ///
  /// This field sits above another field, with no neighbor on either side.
  top,

  /// The bottom and end edges touch neighboring wrappers.
  ///
  /// This field is the leading cell of the top row.
  topLeft,

  /// The bottom and start edges touch neighboring wrappers.
  ///
  /// This field is the trailing cell of the top row.
  topRight,

  /// Only the top edge touches another wrapper.
  ///
  /// This field sits below another field, with no neighbor on either side.
  bottom,

  /// The top and end edges touch neighboring wrappers.
  ///
  /// This field is the leading cell of the bottom row.
  bottomLeft,

  /// The top and start edges touch neighboring wrappers.
  ///
  /// This field is the trailing cell of the bottom row.
  bottomRight,

  /// Only the end edge touches another wrapper.
  ///
  /// This field is the leading cell of a horizontal pair.
  left,

  /// Only the start edge touches another wrapper.
  ///
  /// This field is the trailing cell of a horizontal pair.
  right,

  /// All four edges touch neighboring wrappers.
  center,

  /// Same geometry as [topLeft]. The leading cell of the top row.
  topStart,

  /// Same geometry as [topRight]. The trailing cell of the top row.
  topEnd,

  /// Same geometry as [bottomLeft]. The leading cell of the bottom row.
  bottomStart,

  /// Same geometry as [bottomRight]. The trailing cell of the bottom row.
  bottomEnd,
}

/// Colors and metrics for every [TextFormFieldWrapper] under a [Theme].
///
/// A null field falls through to the wrapper's own value, then to the
/// [ColorScheme]. A wrapper value that differs from the package default
/// overrides the theme. The package defaults are
/// [TextFormFieldWrapper.defaultBorderRadius],
/// [TextFormFieldWrapper.defaultBorderThickness],
/// [TextFormFieldWrapper.defaultBorderFocusedThickness], and
/// [TextFormFieldWrapper.defaultShadowSize].
class TextFormFieldWrapperTheme
    extends ThemeExtension<TextFormFieldWrapperTheme> {
  /// Creates a theme for wrapped fields.
  const TextFormFieldWrapperTheme({
    this.fillColor,
    this.disabledFillColor,
    this.borderColor,
    this.borderFocusedColor,
    this.errorBorderColor,
    this.shadowColor,
    this.borderRadius,
    this.borderThickness,
    this.borderFocusedThickness,
    this.shadowSize,
  });

  /// The theme installed on [context], if any.
  static TextFormFieldWrapperTheme? of(BuildContext context) {
    return Theme.of(context).extension<TextFormFieldWrapperTheme>();
  }

  /// Enabled fill color.
  final Color? fillColor;

  /// Disabled fill color.
  final Color? disabledFillColor;

  /// Border color while the field is not focused and has no error.
  final Color? borderColor;

  /// Border color while the field is focused and has no error.
  final Color? borderFocusedColor;

  /// Border color while the field has a validation error.
  final Color? errorBorderColor;

  /// Shadow color.
  final Color? shadowColor;

  /// Corner radius for the corners [TextFormFieldPosition] rounds.
  final double? borderRadius;

  /// Border thickness while the field is not focused.
  final double? borderThickness;

  /// Border thickness while the field is focused.
  final double? borderFocusedThickness;

  /// Blur radius and offset of the shadow.
  final double? shadowSize;

  @override
  TextFormFieldWrapperTheme copyWith({
    Color? fillColor,
    Color? disabledFillColor,
    Color? borderColor,
    Color? borderFocusedColor,
    Color? errorBorderColor,
    Color? shadowColor,
    double? borderRadius,
    double? borderThickness,
    double? borderFocusedThickness,
    double? shadowSize,
  }) {
    return TextFormFieldWrapperTheme(
      fillColor: fillColor ?? this.fillColor,
      disabledFillColor: disabledFillColor ?? this.disabledFillColor,
      borderColor: borderColor ?? this.borderColor,
      borderFocusedColor: borderFocusedColor ?? this.borderFocusedColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      shadowColor: shadowColor ?? this.shadowColor,
      borderRadius: borderRadius ?? this.borderRadius,
      borderThickness: borderThickness ?? this.borderThickness,
      borderFocusedThickness:
          borderFocusedThickness ?? this.borderFocusedThickness,
      shadowSize: shadowSize ?? this.shadowSize,
    );
  }

  @override
  TextFormFieldWrapperTheme lerp(
    ThemeExtension<TextFormFieldWrapperTheme>? other,
    double t,
  ) {
    if (other is! TextFormFieldWrapperTheme) {
      return this;
    }
    return TextFormFieldWrapperTheme(
      fillColor: Color.lerp(fillColor, other.fillColor, t),
      disabledFillColor: Color.lerp(
        disabledFillColor,
        other.disabledFillColor,
        t,
      ),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      borderFocusedColor: Color.lerp(
        borderFocusedColor,
        other.borderFocusedColor,
        t,
      ),
      errorBorderColor: Color.lerp(errorBorderColor, other.errorBorderColor, t),
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t),
      borderRadius: lerpDouble(borderRadius, other.borderRadius, t),
      borderThickness: lerpDouble(borderThickness, other.borderThickness, t),
      borderFocusedThickness: lerpDouble(
        borderFocusedThickness,
        other.borderFocusedThickness,
        t,
      ),
      shadowSize: lerpDouble(shadowSize, other.shadowSize, t),
    );
  }
}

/// Decorates a form field with a border and corner radii that follow [position].
///
/// Set the wrapped field's `InputDecoration.border` to [InputBorder.none].
/// Focusing the field changes the border color and thickness without moving
/// the field or resizing the wrapper. Edges that already meet a neighbor stay
/// a single seam.
///
/// [TextFormFieldWrapper.builder] reports validation from a [FormField] and
/// paints [errorText] below the border so the box itself does not grow.
class TextFormFieldWrapper extends StatefulWidget {
  /// Creates a wrapper around [formField].
  const TextFormFieldWrapper({
    super.key,
    required this.formField,
    this.position = TextFormFieldPosition.alone,
    this.suffix,
    this.prefix,
    this.shadowColor,
    this.shadowSize = defaultShadowSize,
    this.borderRadius = defaultBorderRadius,
    this.borderThickness = defaultBorderThickness,
    this.borderColor,
    this.borderFocusedThickness = defaultBorderFocusedThickness,
    this.borderFocusedColor,
    this.errorBorderColor,
    this.fillColor,
    this.disabledFillColor,
    this.isEnabled,
    this.hasError,
    this.errorText,
  }) : fieldBuilder = null,
       validator = null,
       initialValue = null,
       autovalidateMode = AutovalidateMode.disabled,
       assert(borderRadius >= 0, 'borderRadius must be >= 0'),
       assert(borderThickness >= 0, 'borderThickness must be >= 0'),
       assert(
         borderFocusedThickness >= 0,
         'borderFocusedThickness must be >= 0',
       ),
       assert(shadowSize >= 0, 'shadowSize must be >= 0');

  /// Creates a wrapper whose child is built from a [FormFieldState].
  ///
  /// [fieldBuilder] should return the input, usually a [TextField] with
  /// `InputBorder.none`. The wrapper owns validation. Pass
  /// [FormFieldState.didChange] from the builder when the value changes.
  /// [errorText] is drawn under the border. The inner field should hide its
  /// own error line (`errorStyle: TextStyle(height: 0, fontSize: 0)`) when it
  /// is a [TextFormField].
  const TextFormFieldWrapper.builder({
    super.key,
    required this.fieldBuilder,
    this.validator,
    this.initialValue,
    this.autovalidateMode = AutovalidateMode.disabled,
    this.position = TextFormFieldPosition.alone,
    this.suffix,
    this.prefix,
    this.shadowColor,
    this.shadowSize = defaultShadowSize,
    this.borderRadius = defaultBorderRadius,
    this.borderThickness = defaultBorderThickness,
    this.borderColor,
    this.borderFocusedThickness = defaultBorderFocusedThickness,
    this.borderFocusedColor,
    this.errorBorderColor,
    this.fillColor,
    this.disabledFillColor,
    this.isEnabled,
    this.hasError,
    this.errorText,
  }) : formField = null,
       assert(borderRadius >= 0, 'borderRadius must be >= 0'),
       assert(borderThickness >= 0, 'borderThickness must be >= 0'),
       assert(
         borderFocusedThickness >= 0,
         'borderFocusedThickness must be >= 0',
       ),
       assert(shadowSize >= 0, 'shadowSize must be >= 0');

  /// Package default for [borderRadius] when no theme overrides it.
  static const double defaultBorderRadius = 12;

  /// Package default for [borderThickness] when no theme overrides it.
  static const double defaultBorderThickness = 1;

  /// Package default for [borderFocusedThickness] when no theme overrides it.
  static const double defaultBorderFocusedThickness = 3;

  /// Package default for [shadowSize] when no theme overrides it.
  static const double defaultShadowSize = 0.5;

  /// The form field to wrap.
  ///
  /// Null when this wrapper was created with [TextFormFieldWrapper.builder].
  /// Set the wrapped field's `InputDecoration.border` to [InputBorder.none].
  final FormField<dynamic>? formField;

  /// Builds the input for [TextFormFieldWrapper.builder].
  final Widget Function(FormFieldState<String> state)? fieldBuilder;

  /// Validator used by [TextFormFieldWrapper.builder].
  final FormFieldValidator<String>? validator;

  /// Initial value used by [TextFormFieldWrapper.builder].
  final String? initialValue;

  /// When [TextFormFieldWrapper.builder] runs [validator].
  final AutovalidateMode autovalidateMode;

  /// Where this wrapper sits relative to its neighbors.
  ///
  /// The position chooses which corners are rounded and which edges are shared.
  /// Horizontal edges follow [TextDirection].
  final TextFormFieldPosition position;

  /// Widget shown before the form field, at the start edge.
  ///
  /// To keep several fields aligned, use a [SizedBox] or another widget with a
  /// fixed width.
  final Widget? prefix;

  /// Widget shown after the form field, at the end edge.
  ///
  /// To keep several fields aligned, use a [SizedBox] or another widget with a
  /// fixed width.
  final Widget? suffix;

  /// Shadow color. Defaults to [ColorScheme.shadow].
  final Color? shadowColor;

  /// Blur radius and offset of the shadow.
  final double shadowSize;

  /// Corner radius, in logical pixels, of the corners that [position] rounds.
  final double borderRadius;

  /// Border thickness while the field is not focused.
  final double borderThickness;

  /// Border color while the field is not focused and has no error.
  ///
  /// Defaults to a [ColorScheme.outline] that meets 3:1 contrast against the
  /// fill and the scaffold.
  final Color? borderColor;

  /// Border thickness while the wrapped field has focus.
  final double borderFocusedThickness;

  /// Border color while the wrapped field has focus and has no error.
  ///
  /// Defaults to a [ColorScheme.primary] that meets 3:1 contrast against the
  /// fill and the scaffold.
  final Color? borderFocusedColor;

  /// Border color while the field has a validation error.
  ///
  /// Defaults to [ColorScheme.error].
  final Color? errorBorderColor;

  /// Fill color used while the wrapper is enabled.
  ///
  /// When null, uses [InputDecorationTheme.fillColor] or
  /// [ColorScheme.surfaceContainerHighest].
  final Color? fillColor;

  /// Fill color used while the wrapper is disabled.
  ///
  /// When null, uses a tint of [ColorScheme.onSurface] over [ColorScheme.surface].
  final Color? disabledFillColor;

  /// Whether the wrapper paints the enabled or the disabled fill.
  ///
  /// When null, the wrapper follows [FormField.enabled] on [formField]. Pass
  /// true or false to override the wrapped field. A builder defaults to enabled
  /// when this is null.
  final bool? isEnabled;

  /// Whether the border uses [errorBorderColor].
  ///
  /// When null, a builder follows [FormFieldState.hasError]. A plain wrapper
  /// follows [errorText]: a non-null [errorText] is an error.
  final bool? hasError;

  /// Error message drawn below the border, outside the filled box.
  final String? errorText;

  /// How many times the internal focus listener has been notified.
  ///
  /// Tests use this to prove the listener is registered once. Production code
  /// should not read or write it.
  @visibleForTesting
  static int debugFocusNotificationCount = 0;

  @override
  State<TextFormFieldWrapper> createState() => _TextFormFieldWrapperState();
}

class _TextFormFieldWrapperState extends State<TextFormFieldWrapper> {
  bool _hasFocus = false;

  final FocusNode _focusNode = FocusNode(
    canRequestFocus: false,
    skipTraversal: true,
    debugLabel: 'TextFormFieldWrapper',
  );

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    TextFormFieldWrapper.debugFocusNotificationCount++;
    if (_focusNode.hasFocus == _hasFocus) {
      return;
    }
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasTopStartRadius =>
      _positionsWithTopStartRadius.contains(widget.position);

  bool get _hasTopEndRadius =>
      _positionsWithTopEndRadius.contains(widget.position);

  bool get _hasBottomStartRadius =>
      _positionsWithBottomStartRadius.contains(widget.position);

  bool get _hasBottomEndRadius =>
      _positionsWithBottomEndRadius.contains(widget.position);

  /// Edges that meet a neighbor are omitted so the neighbor's border is the
  /// only line on that seam. Focus does not add those edges back.
  bool get _restsOnTop => _positionsWithTopBorder.contains(widget.position);

  bool get _restsOnStart => _positionsWithStartBorder.contains(widget.position);

  bool get _enabled => widget.isEnabled ?? widget.formField?.enabled ?? true;

  BorderRadius _radii(double radius, TextDirection direction) {
    final Radius corner = Radius.circular(radius);
    return BorderRadiusDirectional.only(
      topStart: _hasTopStartRadius ? corner : Radius.zero,
      topEnd: _hasTopEndRadius ? corner : Radius.zero,
      bottomStart: _hasBottomStartRadius ? corner : Radius.zero,
      bottomEnd: _hasBottomEndRadius ? corner : Radius.zero,
    ).resolve(direction);
  }

  EdgeInsets _edgeInsets(double width, TextDirection direction) {
    return EdgeInsetsDirectional.fromSTEB(
      _restsOnStart ? width : 0,
      _restsOnTop ? width : 0,
      width,
      width,
    ).resolve(direction);
  }

  bool _showError(FormFieldState<String>? state) {
    if (widget.hasError != null) {
      return widget.hasError!;
    }
    if (widget.errorText != null) {
      return true;
    }
    return state?.hasError ?? false;
  }

  String? _message(FormFieldState<String>? state, bool showError) {
    if (widget.errorText != null) {
      return widget.errorText;
    }
    if (showError) {
      return state?.errorText;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Widget Function(FormFieldState<String> state)? fieldBuilder =
        widget.fieldBuilder;
    if (fieldBuilder != null) {
      return FormField<String>(
        validator: widget.validator,
        initialValue: widget.initialValue,
        autovalidateMode: widget.autovalidateMode,
        builder: (FormFieldState<String> state) {
          return _frame(context, field: fieldBuilder(state), state: state);
        },
      );
    }
    return _frame(context, field: widget.formField!, state: null);
  }

  Widget _frame(
    BuildContext context, {
    required Widget field,
    required FormFieldState<String>? state,
  }) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final TextFormFieldWrapperTheme? extension = TextFormFieldWrapperTheme.of(
      context,
    );
    final TextDirection direction = Directionality.of(context);
    final bool showError = _showError(state);
    final String? message = _message(state, showError);

    final double borderRadius = _metric(
      widget.borderRadius,
      TextFormFieldWrapper.defaultBorderRadius,
      extension?.borderRadius,
    );
    final double borderThickness = _metric(
      widget.borderThickness,
      TextFormFieldWrapper.defaultBorderThickness,
      extension?.borderThickness,
    );
    final double borderFocusedThickness = _metric(
      widget.borderFocusedThickness,
      TextFormFieldWrapper.defaultBorderFocusedThickness,
      extension?.borderFocusedThickness,
    );
    final double shadowSize = _metric(
      widget.shadowSize,
      TextFormFieldWrapper.defaultShadowSize,
      extension?.shadowSize,
    );

    final Color fillColor = _fillColor(theme, extension, enabled: _enabled);
    final Color scaffold = theme.scaffoldBackgroundColor;
    final List<Color> backgrounds = <Color>[fillColor, scaffold];
    final Color shadowColor =
        widget.shadowColor ?? extension?.shadowColor ?? scheme.shadow;
    final Color unfocused = _color(
      explicit: widget.borderColor,
      themed: extension?.borderColor,
      fallback: scheme.outline,
      strengthen: scheme.onSurface,
      backgrounds: backgrounds,
    );
    final Color focused = _color(
      explicit: widget.borderFocusedColor,
      themed: extension?.borderFocusedColor,
      fallback: scheme.primary,
      strengthen: scheme.onSurface,
      backgrounds: backgrounds,
    );
    final Color error =
        widget.errorBorderColor ?? extension?.errorBorderColor ?? scheme.error;
    final Color borderPaint = showError
        ? error
        : (_hasFocus ? focused : unfocused);

    // Reserve the thicker border up front and only paint [visible] of it, so
    // focus can thicken the stroke without moving the field. The leftover
    // inset is filled, not left as a second border.
    final double visible = _hasFocus ? borderFocusedThickness : borderThickness;
    final double reserved = math.max(borderThickness, borderFocusedThickness);
    final double cushion = reserved - visible;
    final double innerRadius = math.max(0, borderRadius - visible);

    final Widget box = Focus(
      focusNode: _focusNode,
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      child: Container(
        padding: _edgeInsets(visible, direction),
        width: double.infinity,
        decoration: BoxDecoration(
          color: borderPaint,
          borderRadius: _radii(borderRadius, direction),
          boxShadow: [
            if (shadowSize != 0)
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.5),
                blurRadius: shadowSize,
                offset: Offset(shadowSize, shadowSize),
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: _radii(innerRadius, direction),
          ),
          padding:
              _edgeInsets(cushion, direction) +
              const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (widget.prefix != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 8)
                      .resolve(direction),
                  child: widget.prefix,
                ),
              Expanded(child: field),
              if (widget.suffix != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(start: 8)
                      .resolve(direction),
                  child: widget.suffix,
                ),
            ],
          ),
        ),
      ),
    );

    if (message == null) {
      return box;
    }

    final TextStyle errorStyle =
        theme.inputDecorationTheme.errorStyle ??
        theme.textTheme.bodySmall?.copyWith(color: scheme.error) ??
        TextStyle(color: scheme.error);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        Padding(
          padding: EdgeInsetsDirectional.only(
            top: 4,
            start: 12,
          ).resolve(direction),
          child: Semantics(
            liveRegion: true,
            child: Text(message, style: errorStyle),
          ),
        ),
      ],
    );
  }

  Color _fillColor(
    ThemeData theme,
    TextFormFieldWrapperTheme? extension, {
    required bool enabled,
  }) {
    if (enabled && widget.fillColor != null) {
      return widget.fillColor!;
    }
    if (!enabled && widget.disabledFillColor != null) {
      return widget.disabledFillColor!;
    }
    if (enabled && extension?.fillColor != null) {
      return extension!.fillColor!;
    }
    if (!enabled && extension?.disabledFillColor != null) {
      return extension!.disabledFillColor!;
    }
    final ColorScheme scheme = theme.colorScheme;
    if (enabled) {
      return theme.inputDecorationTheme.fillColor ??
          scheme.surfaceContainerHighest;
    }
    return Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.04),
      scheme.surface,
    );
  }
}

double _metric(double value, double fallback, double? themed) {
  if (themed == null || value != fallback) {
    return value;
  }
  return themed;
}

Color _color({
  required Color? explicit,
  required Color? themed,
  required Color fallback,
  required Color strengthen,
  required List<Color> backgrounds,
}) {
  if (explicit != null) {
    return explicit;
  }
  if (themed != null) {
    return themed;
  }
  return _withContrast(fallback, strengthen, backgrounds);
}

Color _withContrast(Color color, Color strengthen, List<Color> backgrounds) {
  if (_meetsContrast(color, backgrounds)) {
    return color;
  }
  double low = 0;
  double high = 1;
  for (int i = 0; i < 24; i++) {
    final double mid = (low + high) / 2;
    final Color mixed = Color.lerp(color, strengthen, mid)!;
    if (_meetsContrast(mixed, backgrounds)) {
      high = mid;
    } else {
      low = mid;
    }
  }
  return Color.lerp(color, strengthen, high)!;
}

bool _meetsContrast(Color color, List<Color> backgrounds) {
  return backgrounds.every(
    (Color background) => _contrastRatio(color, background) >= 3,
  );
}

double _contrastRatio(Color a, Color b) {
  final double lighter = math.max(a.computeLuminance(), b.computeLuminance());
  final double darker = math.min(a.computeLuminance(), b.computeLuminance());
  return (lighter + 0.05) / (darker + 0.05);
}

const Set<TextFormFieldPosition> _positionsWithTopStartRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.topLeft,
  TextFormFieldPosition.topStart,
  TextFormFieldPosition.left,
};

const Set<TextFormFieldPosition> _positionsWithTopEndRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.topRight,
  TextFormFieldPosition.topEnd,
  TextFormFieldPosition.right,
};

const Set<TextFormFieldPosition> _positionsWithBottomStartRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.bottom,
  TextFormFieldPosition.bottomLeft,
  TextFormFieldPosition.bottomStart,
  TextFormFieldPosition.left,
};

const Set<TextFormFieldPosition> _positionsWithBottomEndRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.bottom,
  TextFormFieldPosition.bottomRight,
  TextFormFieldPosition.bottomEnd,
  TextFormFieldPosition.right,
};

const Set<TextFormFieldPosition> _positionsWithTopBorder = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.topLeft,
  TextFormFieldPosition.topStart,
  TextFormFieldPosition.topRight,
  TextFormFieldPosition.topEnd,
  TextFormFieldPosition.left,
  TextFormFieldPosition.right,
};

const Set<TextFormFieldPosition> _positionsWithStartBorder = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.bottom,
  TextFormFieldPosition.topLeft,
  TextFormFieldPosition.topStart,
  TextFormFieldPosition.left,
  TextFormFieldPosition.center,
  TextFormFieldPosition.bottomLeft,
  TextFormFieldPosition.bottomStart,
};

/// One configured field for [ColumnOfWrappedTextFields].
///
/// This is a data holder. [ColumnOfWrappedTextFields] reads [formField],
/// [prefix], and [suffix] and builds the wrappers itself.
class ColumnFormFieldItem {
  /// Creates configuration for a single stacked field.
  const ColumnFormFieldItem({
    required this.formField,
    this.prefix,
    this.suffix,
  });

  /// The form field placed in the column.
  ///
  /// Set its `InputDecoration.border` to [InputBorder.none].
  final FormField<dynamic> formField;

  /// Widget shown before [formField].
  final Widget? prefix;

  /// Widget shown after [formField].
  final Widget? suffix;
}

/// A vertical stack of [TextFormFieldWrapper]s with shared borders.
class ColumnOfWrappedTextFields extends StatelessWidget {
  /// Creates a stack of wrapped fields from [columnFormFieldItems].
  const ColumnOfWrappedTextFields({
    super.key,
    required this.columnFormFieldItems,
    this.shadowColor,
    this.shadowSize = TextFormFieldWrapper.defaultShadowSize,
    this.borderRadius = TextFormFieldWrapper.defaultBorderRadius,
    this.borderThickness = TextFormFieldWrapper.defaultBorderThickness,
    this.borderColor,
    this.borderFocusedThickness =
        TextFormFieldWrapper.defaultBorderFocusedThickness,
    this.borderFocusedColor,
    this.errorBorderColor,
    this.fillColor,
    this.disabledFillColor,
  }) : assert(borderRadius >= 0, 'borderRadius must be >= 0'),
       assert(borderThickness >= 0, 'borderThickness must be >= 0'),
       assert(
         borderFocusedThickness >= 0,
         'borderFocusedThickness must be >= 0',
       ),
       assert(shadowSize >= 0, 'shadowSize must be >= 0');

  /// Fields to stack from top to bottom.
  ///
  /// Set each field's `InputDecoration.border` to [InputBorder.none].
  final List<ColumnFormFieldItem> columnFormFieldItems;

  /// Shadow color forwarded to each wrapper.
  final Color? shadowColor;

  /// Shadow size forwarded to each wrapper.
  final double shadowSize;

  /// Corner radius forwarded to each wrapper.
  final double borderRadius;

  /// Unfocused border thickness forwarded to each wrapper.
  final double borderThickness;

  /// Unfocused border color forwarded to each wrapper.
  final Color? borderColor;

  /// Focused border thickness forwarded to each wrapper.
  final double borderFocusedThickness;

  /// Focused border color forwarded to each wrapper.
  final Color? borderFocusedColor;

  /// Error border color forwarded to each wrapper.
  final Color? errorBorderColor;

  /// Enabled fill forwarded to each wrapper.
  final Color? fillColor;

  /// Disabled fill forwarded to each wrapper.
  final Color? disabledFillColor;

  @override
  Widget build(BuildContext context) {
    final List<Widget> wrappers = <Widget>[];

    for (int i = 0; i < columnFormFieldItems.length; i++) {
      TextFormFieldPosition position = TextFormFieldPosition.center;
      if (i == 0) {
        position = TextFormFieldPosition.top;
      }
      if (i == columnFormFieldItems.length - 1) {
        position = TextFormFieldPosition.bottom;
      }
      if (columnFormFieldItems.length == 1) {
        position = TextFormFieldPosition.alone;
      }

      final ColumnFormFieldItem item = columnFormFieldItems[i];
      wrappers.add(
        TextFormFieldWrapper(
          formField: item.formField,
          prefix: item.prefix,
          suffix: item.suffix,
          shadowColor: shadowColor,
          shadowSize: shadowSize,
          borderColor: borderColor,
          borderFocusedColor: borderFocusedColor,
          errorBorderColor: errorBorderColor,
          borderFocusedThickness: borderFocusedThickness,
          borderRadius: borderRadius,
          borderThickness: borderThickness,
          fillColor: fillColor,
          disabledFillColor: disabledFillColor,
          isEnabled: item.formField.enabled,
          position: position,
        ),
      );
    }

    return Column(children: wrappers);
  }
}
