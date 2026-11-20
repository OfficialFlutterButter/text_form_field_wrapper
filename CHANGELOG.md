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
