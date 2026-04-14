## 2.0.0 - April 14, 2026

### Breaking changes
- Raised minimum SDK constraints to Dart `>=3.11.0 <4.0.0` and Flutter `>=3.41.0`.
- `ColumnFormFieldItem` is now a data holder (no longer a widget class).

### Improvements
- Fixed focus lifecycle handling in `TextFormFieldWrapper` by attaching the focus listener once and disposing the internal `FocusNode`.
- Added optional theming hooks: `fillColor` and `disabledFillColor`.
- Updated package tooling and lint configuration for modern Flutter/Dart.
- Added widget tests and a CI workflow for analyze/test checks.

### Migration notes
- Upgrade your app to the required Flutter and Dart versions before upgrading this package.
- If you used `ColumnFormFieldItem` as a widget, migrate those UI usages to `TextFormFieldWrapper` and keep `ColumnFormFieldItem` only for `ColumnOfWrappedTextFields` item configuration.
- The new theming options are optional; default visual behavior remains unchanged.

## 1.0.0 - November 16, 2021
- Initial release