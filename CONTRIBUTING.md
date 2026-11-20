# Contributing

## Release lines

pub.dev still serves 1.0.0. Downstream packages, including `checkout_screen_ui`, depend on `text_form_field_wrapper: ^1.0.0`.

`master` contains an unpublished 2.0.0. That release raises the SDK floor and changes `ColumnFormFieldItem` from a widget into a data class. Publishing it does not update packages that constrain `^1.0.0`.

### Decision

1. Ship patch and minor fixes from `release/1.x`, branched from the 1.0.0 commit (`1d65acc`).
2. **1.0.1** is the non-breaking patch: focus disposal, dark-mode fill, stable layout, non-negative radii, disabled styling, Tab traversal, and listing hygiene.
3. **1.1.0** is the next minor on this same branch. It is not released yet. It covers theme-driven light-mode defaults, validation error styling, and RTL geometry (issues 11-14).
4. **2.0.0 stays unpublished** until 1.1.0 is published and `master` is rebased onto that release. Publish 2.x only after that rebase. In the same coordinated release, bump `checkout_screen_ui` to `^2.0.0`. That consumer release accepts 2.0.0's higher SDK floor.

Do not publish `master` as 2.0.0 before that rebase.

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
4. Publish from this repository, which is the pub.dev source of truth:

   ```bash
   dart pub publish
   ```

5. Transfer the package to the verified publisher used for the org's other packages. That is an owner action in the pub.dev admin UI, not a repository change.

1.0.1 requires Dart `^3.6.0` and Flutter `>=3.27.0`. Older SDKs keep resolving 1.0.0, so existing apps on those SDKs are left on the previous version.
