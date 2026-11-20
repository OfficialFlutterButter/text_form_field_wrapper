A widget that wraps a `TextFormField` and draws a border with corner radii that
adjust when fields sit against each other.

![Grouped form fields with connected borders.](./demo/text_form_field_wrapper_demo.gif)

## Installation

Add the dependency to your app's `pubspec.yaml`:

```yaml
dependencies:
  text_form_field_wrapper: ^1.0.1
```

Requires Dart `^3.6.0` and Flutter `>=3.27.0`.

```dart
import 'package:text_form_field_wrapper/text_form_field_wrapper.dart';
```

## Usage

Set the inner field's border to `InputBorder.none`. The wrapper draws the border.

### Standalone field

```dart
TextFormFieldWrapper(
  formField: TextFormField(
    controller: myController,
    decoration: const InputDecoration(border: InputBorder.none),
  ),
  position: TextFormFieldPosition.alone,
)
```

### Grouped fields

`position` chooses which corners are rounded and which edges are shared with a
neighbor. Adjacent fields keep a single seam.

```dart
Column(
  children: [
    TextFormFieldWrapper(
      formField: TextFormField(
        controller: cardNumberController,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
      position: TextFormFieldPosition.top,
    ),
    Row(
      children: [
        Expanded(
          child: TextFormFieldWrapper(
            formField: TextFormField(
              controller: expiryController,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            position: TextFormFieldPosition.bottomLeft,
          ),
        ),
        Expanded(
          child: TextFormFieldWrapper(
            formField: TextFormField(
              controller: cvvController,
              decoration: const InputDecoration(border: InputBorder.none),
            ),
            position: TextFormFieldPosition.bottomRight,
          ),
        ),
      ],
    ),
  ],
)
```

`ColumnOfWrappedTextFields` stacks `ColumnFormFieldItem`s and assigns `top`,
`center`, and `bottom` for you. `ColumnFormFieldItem` is configuration for that
column, not a field you place in the tree yourself.

## Appearance

Light mode uses the original grey fill and border. Dark mode takes the fill,
border, and shadow from the surrounding `Theme`, so typed text stays readable.
Pass `fillColor` and `disabledFillColor` to override either mode.

When `isEnabled` is omitted, the wrapper follows `formField.enabled`.

Focus changes the border color and thickness. It does not move the field or
change the wrapper's size.

## Issues

Report bugs and open pull requests on
[GitHub](https://github.com/OfficialFlutterButter/text_form_field_wrapper/issues).
See [CONTRIBUTING.md](CONTRIBUTING.md) for how releases are published.
