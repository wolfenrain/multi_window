## Description

*Replace this paragraph with a description of what this MR is doing. If you're modifying existing behavior, describe the existing behavior, how this MR is changing it, and what motivated the change.*

## Checklist

Before you create this MR confirm that it meets all requirements listed below by checking the relevant checkboxes (`[x]`). This will ensure a smooth and quick review process.

- [ ] I read the [Contributor Guide] and followed the process outlined there for submitting MRs.
- [ ] My MR includes unit or integration tests for *all* changed/updated/fixed behaviors (See [Contributor Guide]).
- [ ] All existing and new tests are passing.
- [ ] I updated/added relevant documentation (doc comments with `///`).
- [ ] The flutter analyzer (`flutter analyze`) does not report any problems on my MR.
- [ ] The swift analyzer (`swiftlint`) does not report any problems on my MR.
- [ ] I read and followed the [Flutter Style Guide].
- [ ] I updated the related `pubspec.yaml` with an appropriate new version according to the [pub versioning philosophy]. And afterwards run `flutter pub get`, which will update the `pubspec.lock` with the correct new version.
- [ ] I updated the related `CHANGELOG.md` to add a description of the change.
- [ ] I am willing to follow-up on review comments in a timely manner.
- [ ] I am done with this MR and removed the `Draft` status, by clicking on the `Mark as ready` button in this MR

## Breaking Change

Does your MR require plugin users to manually update their apps to accommodate your change?

- [ ] Yes, this is a breaking change (please indicate a breaking change in `CHANGELOG.md` and increment major revision).
- [ ] No, this is *not* a breaking change.

## Related Issues

*Replace this paragraph with a list of issues related to this MR from the [issue database]. Indicate, which of these issues are resolved or fixed by this MR. If you created the MR within this project, this will be filled automatically*

<!-- Links -->
[issue database]: https://gitlab.com/wolfenrain/multi_window/issues
[Contributor Guide]: https://gitlab.com/wolfenrain/multi_window/-/blob/master/CONTRIBUTING.md
[Flutter Style Guide]: https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo
[pub versioning philosophy]: https://www.dartlang.org/tools/pub/versioning