# Contributing

## Release lines

pub.dev still serves 1.0.0. Downstream packages, including `checkout_screen_ui`, depend on `text_form_field_wrapper: ^1.0.0`.

`master` contains an unpublished 2.0.0. That release raises the SDK floor and changes `ColumnFormFieldItem` from a widget into a data class. Publishing it does not update packages that constrain `^1.0.0`.

### Decision

1. Ship patch and minor fixes from `release/1.x`, branched from the 1.0.0 commit (`1d65acc`).
2. **1.0.1** is the non-breaking patch: focus disposal, dark-mode fill, stable layout, non-negative radii, disabled styling, Tab traversal, and listing hygiene.
3. **1.1.0** is developed on `release/1.1`, branched from the `v1.0.1` tag. That keeps the 1.0.1 publish commit stable. After 1.0.1 is on pub.dev, merge `release/1.1` into `release/1.x` and tag `v1.1.0`. It covers theme-driven defaults, validation error styling, RTL geometry, and the min-plus-stable CI matrix (issues 11-14).
4. **2.0.0** is on `release/2.0`, branched from `release/1.1`. It rebases the breaking release onto 1.1.0, moves Material imports to `package:material_ui`, and raises the floor to Dart `^3.13.0` and Flutter `>=3.47.0`. Publish it only after 1.1.0 is on pub.dev. In that same release, ship a minor of `checkout_screen_ui` that depends on `text_form_field_wrapper: ^2.0.0` and uses the same SDK floor.

Do not publish `master` as 2.0.0. `master` is an older 2.0.0 snapshot. `release/2.0` replaces it.

### Status of the audit tracker

- 1.0.1 is on `release/1.x`, tagged `v1.0.1`. Publishing is blocked until pub.dev support restores an uploader.
- 1.1.0 is on `release/1.1`.
- 2.0.0, including the `material_ui` migration, is on `release/2.0`.
- `checkout_screen_ui` `release/1.2` depends on `text_form_field_wrapper: ^2.0.0` and imports `package:material_ui`. Publish that minor only after 2.0.0 is on pub.dev.
- Pull request #2 overlaps fixes already shipped in 1.0.1 and 1.1.0. Its extra gradient and center-position API is not part of these releases.

## Publishing a release

1. Update `CHANGELOG.md` and `version` in `pubspec.yaml`.
2. From a clean checkout of the release branch:

   ```bash
   dart format --set-exit-if-changed .
   flutter analyze
   flutter test
   dart pub publish --dry-run
   dart pub global activate pana
   pana .
   ```

3. Tag the commit `vX.Y.Z` (for example `v1.0.1`) and push the branch and the tag.
   On GitHub, require the `analyze-and-test` check before merging into `release/1.x` or `master`.
4. Publish from this repository, which is the pub.dev source of truth:

   ```bash
   dart pub publish
   ```

5. Transfer the package to the verified publisher used for the org's other packages. That is an owner action in the pub.dev admin UI, not a repository change.

1.0.1 requires Dart `^3.6.0` and Flutter `>=3.27.0`. Older SDKs keep resolving 1.0.0, so existing apps on those SDKs are left on the previous version.
