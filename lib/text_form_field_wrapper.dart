/// Draws connected borders around form fields so grouped fields share one seam.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Where a [TextFormFieldWrapper] sits relative to the wrappers beside it.
///
/// Shared edges are omitted so two neighbors paint one line, not two.
enum TextFormFieldPosition {
  /// No edge touches another wrapper.
  alone,

  /// Only the bottom edge touches another wrapper.
  ///
  /// This field sits above another field, with no neighbor on either side.
  top,

  /// The bottom and right edges touch neighboring wrappers.
  ///
  /// This field sits above and to the left of those neighbors.
  topLeft,

  /// The bottom and left edges touch neighboring wrappers.
  ///
  /// This field sits above and to the right of those neighbors.
  topRight,

  /// Only the top edge touches another wrapper.
  ///
  /// This field sits below another field, with no neighbor on either side.
  bottom,

  /// The top and right edges touch neighboring wrappers.
  ///
  /// This field sits below and to the left of those neighbors.
  bottomLeft,

  /// The top and left edges touch neighboring wrappers.
  ///
  /// This field sits below and to the right of those neighbors.
  bottomRight,

  /// Only the right edge touches another wrapper.
  ///
  /// This field sits to the left of another field, with nothing above or below.
  left,

  /// Only the left edge touches another wrapper.
  ///
  /// This field sits to the right of another field, with nothing above or below.
  right,

  /// All four edges touch neighboring wrappers.
  center,
}

/// Decorates a form field with a border and corner radii that follow [position].
///
/// Set the wrapped field's `InputDecoration.border` to [InputBorder.none].
/// Focusing the field changes the border color and thickness without moving
/// the field or resizing the wrapper. Edges that already meet a neighbor stay
/// a single seam.
class TextFormFieldWrapper extends StatefulWidget {
  /// Creates a wrapper around [formField].
  const TextFormFieldWrapper({
    super.key,
    required this.formField,
    this.position = TextFormFieldPosition.alone,
    this.suffix,
    this.prefix,
    this.shadowColor,
    this.shadowSize = 0.5,
    this.borderRadius = 12.0,
    this.borderThickness = 1.0,
    this.borderColor,
    this.borderFocusedThickness = 3.0,
    this.borderFocusedColor,
    this.fillColor,
    this.disabledFillColor,
    this.isEnabled,
  })  : assert(borderRadius >= 0, 'borderRadius must be >= 0'),
        assert(borderThickness >= 0, 'borderThickness must be >= 0'),
        assert(
          borderFocusedThickness >= 0,
          'borderFocusedThickness must be >= 0',
        );

  /// The form field to wrap.
  ///
  /// Set the wrapped field's `InputDecoration.border` to [InputBorder.none].
  final FormField<dynamic> formField;

  /// Where this wrapper sits relative to its neighbors.
  ///
  /// The position chooses which corners are rounded and which edges are shared.
  final TextFormFieldPosition position;

  /// Widget shown before the form field.
  ///
  /// To keep several fields aligned, use a [SizedBox] or another widget with a
  /// fixed width.
  final Widget? prefix;

  /// Widget shown after the form field.
  ///
  /// To keep several fields aligned, use a [SizedBox] or another widget with a
  /// fixed width.
  final Widget? suffix;

  /// Shadow color. Defaults to grey in light mode and the theme shadow in dark
  /// mode.
  final Color? shadowColor;

  /// Blur radius and offset of the shadow.
  final double shadowSize;

  /// Corner radius, in logical pixels, of the corners that [position] rounds.
  final double borderRadius;

  /// Border thickness while the field is not focused.
  final double borderThickness;

  /// Border color while the field is not focused.
  ///
  /// Defaults to grey in light mode and [ColorScheme.outline] in dark mode.
  final Color? borderColor;

  /// Border thickness while the wrapped field has focus.
  final double borderFocusedThickness;

  /// Border color while the wrapped field has focus.
  ///
  /// Defaults to light blue in light mode and [ColorScheme.primary] in dark
  /// mode.
  final Color? borderFocusedColor;

  /// Fill color used while the wrapper is enabled.
  ///
  /// When null, light mode uses the 1.0.0 grey and dark mode uses
  /// [InputDecorationTheme.fillColor] or [ColorScheme.surfaceContainerHighest].
  final Color? fillColor;

  /// Fill color used while the wrapper is disabled.
  ///
  /// When null, light mode uses the 1.0.0 grey and dark mode uses a tint of
  /// [ColorScheme.onSurface] over [ColorScheme.surface].
  final Color? disabledFillColor;

  /// Whether the wrapper paints the enabled or the disabled fill.
  ///
  /// When null, the wrapper follows [FormField.enabled] on [formField]. Pass
  /// true or false to override the wrapped field.
  final bool? isEnabled;

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

  bool get _hasTopLeftRadius =>
      _positionsWithTopLeftRadius.contains(widget.position);

  bool get _hasTopRightRadius =>
      _positionsWithTopRightRadius.contains(widget.position);

  bool get _hasBottomLeftRadius =>
      _positionsWithBottomLeftRadius.contains(widget.position);

  bool get _hasBottomRightRadius =>
      _positionsWithBottomRightRadius.contains(widget.position);

  /// Edges that meet a neighbor are omitted so the neighbor's border is the
  /// only line on that seam. Focus does not add those edges back.
  bool get _restsOnTop => _positionsWithTopBorder.contains(widget.position);

  bool get _restsOnLeft => _positionsWithLeftBorder.contains(widget.position);

  bool get _enabled => widget.isEnabled ?? widget.formField.enabled;

  BorderRadius _radii(double radius) {
    final Radius corner = Radius.circular(radius);
    return BorderRadius.only(
      topLeft: _hasTopLeftRadius ? corner : Radius.zero,
      topRight: _hasTopRightRadius ? corner : Radius.zero,
      bottomLeft: _hasBottomLeftRadius ? corner : Radius.zero,
      bottomRight: _hasBottomRightRadius ? corner : Radius.zero,
    );
  }

  EdgeInsets _edgeInsets(double width) {
    return EdgeInsets.fromLTRB(
      _restsOnLeft ? width : 0,
      _restsOnTop ? width : 0,
      width,
      width,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isLight = theme.brightness == Brightness.light;
    final ColorScheme scheme = theme.colorScheme;

    final Color shadowColor =
        widget.shadowColor ?? (isLight ? Colors.grey : scheme.shadow);
    final Color borderColor = _hasFocus
        ? (widget.borderFocusedColor ??
            (isLight ? Colors.lightBlue.shade300 : scheme.primary))
        : (widget.borderColor ??
            (isLight ? Colors.grey.shade300 : scheme.outline));
    final Color fillColor = _fillColor(theme, enabled: _enabled);

    // Reserve the thicker border up front and only paint [visible] of it, so
    // focus can thicken the stroke without moving the field. The leftover
    // inset is filled, not left as a second border.
    final double visible =
        _hasFocus ? widget.borderFocusedThickness : widget.borderThickness;
    final double reserved = math.max(
      widget.borderThickness,
      widget.borderFocusedThickness,
    );
    final double cushion = reserved - visible;
    final double innerRadius = math.max(0, widget.borderRadius - visible);

    return Focus(
      focusNode: _focusNode,
      canRequestFocus: false,
      skipTraversal: true,
      includeSemantics: false,
      child: Container(
        padding: _edgeInsets(visible),
        width: double.infinity,
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: _radii(widget.borderRadius),
          boxShadow: [
            if (widget.shadowSize != 0)
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.5),
                blurRadius: widget.shadowSize,
                offset: Offset(widget.shadowSize, widget.shadowSize),
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: _radii(innerRadius),
          ),
          padding:
              _edgeInsets(cushion) + const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              if (widget.prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: widget.prefix!,
                ),
              Expanded(child: widget.formField),
              if (widget.suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: widget.suffix!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _fillColor(ThemeData theme, {required bool enabled}) {
    if (enabled && widget.fillColor != null) {
      return widget.fillColor!;
    }
    if (!enabled && widget.disabledFillColor != null) {
      return widget.disabledFillColor!;
    }
    if (theme.brightness == Brightness.light) {
      return enabled ? Colors.grey.shade50 : Colors.grey.shade100;
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

const Set<TextFormFieldPosition> _positionsWithTopLeftRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.topLeft,
  TextFormFieldPosition.left,
};

const Set<TextFormFieldPosition> _positionsWithTopRightRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.topRight,
  TextFormFieldPosition.right,
};

const Set<TextFormFieldPosition> _positionsWithBottomLeftRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.bottom,
  TextFormFieldPosition.bottomLeft,
  TextFormFieldPosition.left,
};

const Set<TextFormFieldPosition> _positionsWithBottomRightRadius = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.bottom,
  TextFormFieldPosition.bottomRight,
  TextFormFieldPosition.right,
};

const Set<TextFormFieldPosition> _positionsWithTopBorder = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.topLeft,
  TextFormFieldPosition.topRight,
  TextFormFieldPosition.left,
  TextFormFieldPosition.right,
};

const Set<TextFormFieldPosition> _positionsWithLeftBorder = {
  TextFormFieldPosition.alone,
  TextFormFieldPosition.top,
  TextFormFieldPosition.bottom,
  TextFormFieldPosition.topLeft,
  TextFormFieldPosition.left,
  TextFormFieldPosition.center,
  TextFormFieldPosition.bottomLeft,
};

/// One configured field for [ColumnOfWrappedTextFields].
///
/// This widget is configuration. [ColumnOfWrappedTextFields] reads [formField],
/// [prefix], and [suffix] and builds the wrappers itself.
class ColumnFormFieldItem extends StatelessWidget {
  /// Creates configuration for a single stacked field.
  const ColumnFormFieldItem({
    super.key,
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

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// A vertical stack of [TextFormFieldWrapper]s with shared borders.
class ColumnOfWrappedTextFields extends StatelessWidget {
  /// Creates a stack of wrapped fields from [columnFormFieldItems].
  const ColumnOfWrappedTextFields({
    super.key,
    required this.columnFormFieldItems,
    this.shadowColor,
    this.shadowSize = 0.5,
    this.borderRadius = 12.0,
    this.borderThickness = 1.0,
    this.borderColor,
    this.borderFocusedThickness = 3.0,
    this.borderFocusedColor,
    this.fillColor,
    this.disabledFillColor,
  })  : assert(borderRadius >= 0, 'borderRadius must be >= 0'),
        assert(borderThickness >= 0, 'borderThickness must be >= 0'),
        assert(
          borderFocusedThickness >= 0,
          'borderFocusedThickness must be >= 0',
        );

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
