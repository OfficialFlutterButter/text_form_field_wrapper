import 'package:flutter/material.dart';

/// Describes the position of a [TextFormFieldWrapper] relative to neighboring
/// wrapped fields.
enum TextFormFieldPosition {
  /// No borders touch any adjacent [TextFormFieldWrapper].
  alone,

  /// Only the bottom border touches an adjacent wrapper.
  /// This field is above another field, with no neighbors to either side.
  top,

  /// Bottom and right borders touch adjacent wrappers.
  /// This field is above and to the left of neighboring fields.
  topLeft,

  /// Bottom and left borders touch adjacent wrappers.
  /// This field is above and to the right of neighboring fields.
  topRight,

  /// Only the top border touches an adjacent wrapper.
  /// This field is below another field, with no neighbors to either side.
  bottom,

  /// Top and left borders touch adjacent wrappers.
  /// This field is below and to the right of neighboring fields.
  bottomLeft,

  /// Top and right borders touch adjacent wrappers.
  /// This field is below and to the left of neighboring fields.
  bottomRight,

  /// Only the right border touches an adjacent wrapper.
  /// This field is left of another field, with no fields above or below.
  left,

  /// Only the left border touches an adjacent wrapper.
  /// This field is right of another field, with no fields above or below.
  right,

  /// All four sides touch adjacent wrappers.
  /// This field has neighbors above, below, left, and right.
  center,
}

class TextFormFieldWrapper extends StatefulWidget {
  /// Decorates a form field with a border and corner radii that adapt to the
  /// field's [position] within a grouped layout.
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
    this.isEnabled = true,
  });

  /// The form field to wrap.
  ///
  /// Set the wrapped field's `InputDecoration.border` to `InputBorder.none`.
  final FormField<dynamic> formField;

  /// The wrapper's position relative to neighboring wrappers.
  ///
  /// This determines which corners receive a radius.
  final TextFormFieldPosition position;

  /// The widget to the 'left' of the form field. If you are trying
  /// to keep multiple form fields in alignment, consider inserting
  /// a 'SizedBox' widget or another widget type that allows a width
  /// constraint.
  final Widget? prefix;

  /// The widget to the 'right' of the form field. If you are trying
  /// to keep multiple form fields in alignment, consider inserting
  /// a 'SizedBox' widget or another widget type that allows a width
  /// constraint.
  final Widget? suffix;

  /// The shadow color.
  final Color? shadowColor;

  /// The radius / size of the shadow.
  final double shadowSize;

  /// The radius of the corners.
  final double borderRadius;

  /// The thickness of the border while not in focus.
  final double borderThickness;

  /// The color of the border while not in focus.
  final Color? borderColor;

  /// The thickness of the border while the widget is in focus.
  final double borderFocusedThickness;

  /// The border color while the wrapped field has focus.
  final Color? borderFocusedColor;

  /// Optional fill color while the field is enabled.
  /// Defaults to the package's legacy color for continuity.
  final Color? fillColor;

  /// Optional fill color while the field is disabled.
  /// Defaults to the package's legacy color for continuity.
  final Color? disabledFillColor;

  /// Whether the wrapped field is enabled.
  ///
  /// A different fill color may be used when disabled.
  final bool isEnabled;

  @override
  State<TextFormFieldWrapper> createState() => _TextFormFieldWrapperState();
}

class _TextFormFieldWrapperState extends State<TextFormFieldWrapper> {
  bool _hasFocus = false;

  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChanged);
  }

  void _handleFocusChanged() {
    if (_focusNode.hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = _focusNode.hasFocus;
      });
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasTopLeftRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.top,
    TextFormFieldPosition.topLeft,
    TextFormFieldPosition.left,
  ].contains(widget.position);

  bool get _hasTopRightRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.top,
    TextFormFieldPosition.topRight,
    TextFormFieldPosition.right,
  ].contains(widget.position);

  bool get _hasBottomLeftRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.bottom,
    TextFormFieldPosition.bottomLeft,
    TextFormFieldPosition.left,
  ].contains(widget.position);

  bool get _hasBottomRightRadius => [
    TextFormFieldPosition.alone,
    TextFormFieldPosition.bottom,
    TextFormFieldPosition.bottomRight,
    TextFormFieldPosition.right,
  ].contains(widget.position);

  bool get _hasTopBorder =>
      _hasFocus ||
      [
        TextFormFieldPosition.alone,
        TextFormFieldPosition.top,
        TextFormFieldPosition.topLeft,
        TextFormFieldPosition.topRight,
        TextFormFieldPosition.left,
        TextFormFieldPosition.right,
      ].contains(widget.position);

  bool get _hasLeftBorder =>
      _hasFocus ||
      [
        TextFormFieldPosition.alone,
        TextFormFieldPosition.top,
        TextFormFieldPosition.bottom,
        TextFormFieldPosition.topLeft,
        TextFormFieldPosition.left,
        TextFormFieldPosition.center,
        TextFormFieldPosition.bottomLeft,
      ].contains(widget.position);

  @override
  Widget build(BuildContext context) {
    final Color shadowColor = widget.shadowColor ?? Colors.grey;
    final Color borderColorUnFocused =
        widget.borderColor ?? Colors.grey.shade300;
    final Color borderColorFocused =
        widget.borderFocusedColor ?? Colors.lightBlue.shade300;
    final Color fillColorEnabled = widget.fillColor ?? Colors.grey.shade50;
    final Color fillColorDisabled =
        widget.disabledFillColor ?? Colors.grey.shade100;

    Color fillColor = widget.isEnabled ? fillColorEnabled : fillColorDisabled;
    Color borderColor = _hasFocus ? borderColorFocused : borderColorUnFocused;
    double borderWidth = _hasFocus
        ? widget.borderFocusedThickness
        : widget.borderThickness;
    double cornerRadius = widget.borderRadius;

    double innerRadius = cornerRadius - borderWidth;

    return Focus(
      focusNode: _focusNode,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          _hasLeftBorder ? borderWidth : 0.0,
          _hasTopBorder ? borderWidth : 0.0,
          borderWidth,
          borderWidth,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.only(
            topLeft: _hasTopLeftRadius
                ? Radius.circular(cornerRadius)
                : Radius.zero,
            topRight: _hasTopRightRadius
                ? Radius.circular(cornerRadius)
                : Radius.zero,
            bottomLeft: _hasBottomLeftRadius
                ? Radius.circular(cornerRadius)
                : Radius.zero,
            bottomRight: _hasBottomRightRadius
                ? Radius.circular(cornerRadius)
                : Radius.zero,
          ),
          boxShadow: [
            if (widget.shadowSize != 0.0)
              BoxShadow(
                color: shadowColor.withValues(alpha: 0.5),
                blurRadius: widget.shadowSize,
                offset: Offset(
                  widget.shadowSize,
                  widget.shadowSize,
                ), // changes position of shadow
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.only(
              topLeft: _hasTopLeftRadius
                  ? Radius.circular(innerRadius)
                  : Radius.zero,
              topRight: _hasTopRightRadius
                  ? Radius.circular(innerRadius)
                  : Radius.zero,
              bottomLeft: _hasBottomLeftRadius
                  ? Radius.circular(innerRadius)
                  : Radius.zero,
              bottomRight: _hasBottomRightRadius
                  ? Radius.circular(innerRadius)
                  : Radius.zero,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          child: Row(
            children: [
              if (widget.prefix != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: widget.prefix!,
                ),
              Expanded(child: widget.formField),
              if (widget.suffix != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: widget.suffix!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class ColumnFormFieldItem {
  /// Configuration data for one item in [ColumnOfWrappedTextFields].
  const ColumnFormFieldItem({
    required this.formField,
    this.prefix,
    this.suffix,
  });

  /// The wrapped form field used by ColumnOfWrappedTextFields.
  final FormField<dynamic> formField;

  /// Optional widget displayed before the field.
  final Widget? prefix;

  /// Optional widget displayed after the field.
  final Widget? suffix;
}

class ColumnOfWrappedTextFields extends StatelessWidget {
  /// A stateless helper that builds a vertical stack of wrapped text fields.
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
  });

  /// The configured wrapped field items.
  ///
  /// Set each wrapped field's `InputDecoration.border` to `InputBorder.none`.
  final List<ColumnFormFieldItem> columnFormFieldItems;

  /// The shadow color.
  final Color? shadowColor;

  /// The radius / size of the shadow.
  final double shadowSize;

  /// The radius of the corners.
  final double borderRadius;

  /// The thickness of the border while not in focus.
  final double borderThickness;

  /// The color of the border while not in focus.
  final Color? borderColor;

  /// The thickness of the border while the widget is in focus.
  final double borderFocusedThickness;

  /// The border color while a wrapped field has focus.
  final Color? borderFocusedColor;

  /// Optional fill color while fields are enabled.
  final Color? fillColor;

  /// Optional fill color while fields are disabled.
  final Color? disabledFillColor;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

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

      widgets.add(
        TextFormFieldWrapper(
          formField: columnFormFieldItems[i].formField,
          prefix: columnFormFieldItems[i].prefix,
          suffix: columnFormFieldItems[i].suffix,
          shadowColor: shadowColor,
          shadowSize: shadowSize,
          borderColor: borderColor,
          borderFocusedColor: borderFocusedColor,
          fillColor: fillColor,
          disabledFillColor: disabledFillColor,
          borderFocusedThickness: borderFocusedThickness,
          borderRadius: borderRadius,
          borderThickness: borderThickness,
          isEnabled: columnFormFieldItems[i].formField.enabled,
          position: position,
        ),
      );
    }

    return Column(children: widgets);
  }
}
