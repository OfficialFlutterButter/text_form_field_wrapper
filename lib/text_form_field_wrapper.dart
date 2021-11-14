library text_form_field_wrapper;

import 'package:flutter/material.dart';

/// The TextFormFieldPosition enum describes the desired
/// location of the widget in respect to another of its own.
enum TextFormFieldPosition {
  /// Describes the position of the widget as having none of
  /// its borders against another TextFormFieldWrapper object
  alone,

  /// Describes the position of the widget having only its
  /// bottom border against another TextFormFieldWrapper object.
  /// This widget would on 'top' of another and none to its left
  /// or right
  top,

  /// Describes the position of the widget having its bottom and
  /// right borders against another TextFormFieldWrapper object.
  /// This widget would 'left' of another and 'above' another.
  topLeft,

  /// Describes the position of the widget having its bottom and
  /// left borders against another TextFormFieldWrapper object.
  /// This widget would 'right' of another and 'above' another.
  topRight,

  /// Describes the position of the widget having only its
  /// top border against another TextFormFieldWrapper object.
  /// This widget would 'below' of another and none to its left
  /// or right
  bottom,

  /// Describes the position of the widget having its top and
  /// left borders against another TextFormFieldWrapper object.
  /// This widget would 'right' of another and 'below' another.
  bottomLeft,

  /// Describes the position of the widget having its top and
  /// left borders against another TextFormFieldWrapper object.
  /// This widget would 'right' of another and 'below' another.
  bottomRight,

  /// Describes the position of the widget having only its
  /// right border against another TextFormFieldWrapper object.
  /// This widget would 'left' of another and none above or below.
  left,

  /// Describes the position of the widget having only its
  /// left border against another TextFormFieldWrapper object.
  /// This widget would 'right' of another and none above or below.
  right,

  /// Describes the position of the widget having all borders
  /// against another TextFormFieldWrapper object. This widget
  /// would have a widget above, below, left and right of it.
  center,
}

class TextFormFieldWrapper extends StatefulWidget {
  /// The TextFormFieldWrapper widget is used to decorate
  /// the standard flutter form field widget with a border
  /// and corner radiuses that react to a specified position.
  const TextFormFieldWrapper(
      {Key? key,
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
      this.isEnabled = true})
      : super(key: key);

  /// The form field that this widget is to wrap. Make sure to
  /// set the inputDecoration of the to have a Border of 'none'
  final FormField formField;

  /// The position of the wrapper widget in respects to others. The
  /// position will affect which corners of the border a radiiused.
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

  /// The color of the shadow
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

  /// Color of the border while the widget is in focus.
  final Color? borderFocusedColor;

  /// is this form field enabled? The fill color can be different
  /// if disabled.
  final bool isEnabled;

  @override
  _TextFormFieldWrapperState createState() => _TextFormFieldWrapperState();
}

class _TextFormFieldWrapperState extends State<TextFormFieldWrapper> {
  bool _hasFocus = false;

  final FocusNode _focusNode = FocusNode();

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
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && !_hasFocus) {
        setState(() {
          _hasFocus = true;
        });
      } else if (!_focusNode.hasFocus && _hasFocus) {
        setState(() {
          _hasFocus = false;
        });
      }
    });

    final Color _shadowColor = widget.shadowColor ?? Colors.grey;
    final Color _borderColorUnFocused =
        widget.borderColor ?? Colors.grey.shade300;
    final Color _borderColorFocused =
        widget.borderFocusedColor ?? Colors.lightBlue.shade300;
    final Color _fillColorEnabled = Colors.grey.shade50;
    final Color _fillColorDisabled = Colors.grey.shade100;

    Color _fillColor =
        widget.isEnabled ? _fillColorEnabled : _fillColorDisabled;
    Color _borderColor =
        _hasFocus ? _borderColorFocused : _borderColorUnFocused;
    double _borderWidth =
        _hasFocus ? widget.borderFocusedThickness : widget.borderThickness;
    double _cornerRadius = widget.borderRadius;

    double _innerRadius = _cornerRadius - _borderWidth;

    return Focus(
      focusNode: _focusNode,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          _hasLeftBorder ? _borderWidth : 0.0,
          _hasTopBorder ? _borderWidth : 0.0,
          _borderWidth,
          _borderWidth,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          color: _borderColor,
          borderRadius: BorderRadius.only(
            topLeft: _hasTopLeftRadius
                ? Radius.circular(_cornerRadius)
                : Radius.zero,
            topRight: _hasTopRightRadius
                ? Radius.circular(_cornerRadius)
                : Radius.zero,
            bottomLeft: _hasBottomLeftRadius
                ? Radius.circular(_cornerRadius)
                : Radius.zero,
            bottomRight: _hasBottomRightRadius
                ? Radius.circular(_cornerRadius)
                : Radius.zero,
          ),
          boxShadow: [
            if (widget.shadowSize != 0.0)
              BoxShadow(
                color: _shadowColor.withOpacity(0.5),
                blurRadius: widget.shadowSize,
                offset: Offset(widget.shadowSize,
                    widget.shadowSize), // changes position of shadow
              ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: _fillColor,
            borderRadius: BorderRadius.only(
              topLeft: _hasTopLeftRadius
                  ? Radius.circular(_innerRadius)
                  : Radius.zero,
              topRight: _hasTopRightRadius
                  ? Radius.circular(_innerRadius)
                  : Radius.zero,
              bottomLeft: _hasBottomLeftRadius
                  ? Radius.circular(_innerRadius)
                  : Radius.zero,
              bottomRight: _hasBottomRightRadius
                  ? Radius.circular(_innerRadius)
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
                )
            ],
          ),
        ),
      ),
    );
  }
}

class ColumnFormFieldItem extends StatelessWidget {
  /// The ColumnFormFieldItem is a restricted version of the
  /// TextFormFieldWrapper Widget and is only meant to be used within
  /// a ColumnOfWrappedTextFields widget.
  const ColumnFormFieldItem({
    Key? key,
    required this.formField,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  final FormField formField;
  final Widget? prefix;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ColumnOfWrappedTextFields extends StatelessWidget {
  /// The ColumnOfWrappedTextFields widget a stateless widget used to
  /// create a vertical stack of Wrapped TextFormFields.
  const ColumnOfWrappedTextFields({
    Key? key,
    required this.columnFormFieldItems,
    this.shadowColor,
    this.shadowSize = 0.5,
    this.borderRadius = 12.0,
    this.borderThickness = 1.0,
    this.borderColor,
    this.borderFocusedThickness = 3.0,
    this.borderFocusedColor,
  }) : super(key: key);

  /// The form field that this widget is to wrap. Make sure to
  /// set the inputDecoration of the to have a Border of 'none'
  final List<ColumnFormFieldItem> columnFormFieldItems;

  /// The color of the shadow
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

  /// Color of the border while the widget is in focus.
  final Color? borderFocusedColor;

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];

    for (int i = 0; i < columnFormFieldItems.length; i++) {
      TextFormFieldPosition _position = TextFormFieldPosition.center;
      if (i == 0) {
        _position = TextFormFieldPosition.top;
      }
      if (i == columnFormFieldItems.length - 1) {
        _position = TextFormFieldPosition.bottom;
      }
      if (columnFormFieldItems.length == 1) {
        _position = TextFormFieldPosition.alone;
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
          borderFocusedThickness: borderFocusedThickness,
          borderRadius: borderRadius,
          borderThickness: borderThickness,
          isEnabled: columnFormFieldItems[i].formField.enabled,
          position: _position,
        ),
      );
    }

    return Column(children: widgets);
  }
}
