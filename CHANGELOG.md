## 1.1.0 - November 20, 2026

### Appearance
- Default fill, border, and shadow now come from the ambient `Theme` in light mode as well as dark mode. Unfocused and focused borders are adjusted so they meet WCAG 3:1 against the fill and the scaffold (#11).
- `left` / `right` positions follow the writing direction. `left` is the start edge and `right` is the end edge. In left-to-right text the geometry matches 1.0.1. In right-to-left text the rounded corner and the shared seam move to the outer start edge (#13).

### Added
- `TextFormFieldWrapperTheme` sets colors, radius, border thickness, and shadow size for every wrapper under a `Theme`.
- `topStart`, `topEnd`, `bottomStart`, and `bottomEnd` positions. They match `topLeft`, `topRight`, `bottomLeft`, and `bottomRight`.
- `hasError`, `errorText`, and `errorBorderColor`. `errorText` is drawn below the border so the box does not grow or throw off a neighboring seam (#12).
- `TextFormFieldWrapper.builder` validates through a `FormField` and exposes the `FormFieldState` to the input.

### Other
- Require Dart `^3.8.0` and Flutter `>=3.32.0`. Pub keeps resolving 1.0.1 for older SDKs.
- CI runs on the minimum Flutter and on stable, with formatting, coverage, an example web build, `dart pub publish --dry-run`, and pana (#14).

To keep the 1.0.0 light palette, pass the old swatches explicitly:

```dart
TextFormFieldWrapper(
  fillColor: Colors.grey.shade50,
  disabledFillColor: Colors.grey.shade100,
  borderColor: Colors.grey.shade300,
  borderFocusedColor: Colors.lightBlue.shade300,
  shadowColor: Colors.grey,
  formField: formField,
)
```

## 1.0.1 - November 19, 2026

### Fixes
- Attach the focus listener once and dispose the internal `FocusNode` (#4).
- In dark mode, derive the fill, border, and shadow from the theme so typed text stays readable. Light mode keeps the 1.0.0 colors (#5, closes #1).
- Keep the wrapper's size and the wrapped field's rect stable when focus changes, and keep a single shared seam between neighbors (#6).
- Clamp the inner corner radius at zero when the radius is smaller than the border (#7).
- Follow `formField.enabled` when `isEnabled` is omitted (#8).
- Skip the wrapper in keyboard traversal and semantics so Tab moves from field to field (#9).

### Added
- Optional `fillColor` and `disabledFillColor` on `TextFormFieldWrapper` and `ColumnOfWrappedTextFields`.

### Other
- Require Dart `^3.6.0` and Flutter `>=3.27.0` so `Color.withValues` can replace `Color.withOpacity`. Pub still resolves 1.0.0 for older SDKs.
- Correct the `bottomLeft` and `bottomRight` docs and document the public API.
- Point `repository` and `issue_tracker` at this GitHub repository (#10).

## 1.0.0 - November 16, 2021
- Initial release.
