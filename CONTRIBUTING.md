# Contributing Guidelines

If you're interested in contributing to this project, here are a few ways to do so:

## Bug fixes

* If you find a bug, please first report it using [Gitlab issues](https://gitlab.com/wolfenrain/multi_window/issues/new).
* Issues that have already been identified as a bug will be labelled ~"type::bug" .
* If you'd like to submit a fix for a bug, send a [Merge Request](https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html#merging-upstream) from your own fork, also read the [How To](#how-to) and [Development Guidelines](#development-guidelines).
* Include a test that isolates the bug and verifies that it was fixed.
* Also update the example and documentation if necessary.

## New Features

* If you'd like to add a feature to the library that doesn't already exist, feel free to describe the feature in a new [Gitlab issue](https://gitlab.com/wolfenrain/multi_window/issues/new).
* Issues that have been identified as a feature request will be labelled ~"type::feature".
* If you'd like to implement the new feature, please wait for feedback from the project maintainers before spending too much time writing the code. In some cases, enhancements may not align well with the project objectives at the time.
* Implement your code and please read the [How To](#how-to) and [Development Guidelines](#development-guidelines).
* Also update the example and documentation where needed.

## Documentation & Miscellaneous

* If you think the documentation could be clearer, or you have an alternative implementation of something that may have more advantages, we would love to hear it.
* As always first file a report in a [Gitlab issue](https://gitlab.com/wolfenrain/multi_window/issues/new).
* Issues that have been identified as a documentation change will be labelled ~"type::documentation".
* Implement the changes to the documentation, please read the [How To](#how-to) and [Development Guidelines](#development-guidelines).

# Requirements

The requirements for a contribution to be accepted:

* Should follow the [Development Guidelines](#development-guidelines)
* The code must follow existing styling conventions
* Commit message should start with a [issue number](#how-to) and should also be descriptive.

If the contribution doesn't meet these criteria, a maintainer will discuss it with you. You can still continue to add more commits to your working branch.

# How To Contribute

* First of all [file an bug or feature report](https://gitlab.com/wolfenrain/multi_window/issues/new) on this repository.
* [Fork the project](https://docs.gitlab.com/ee/gitlab-basics/fork-project.html) on Gitlab
* Clone the forked repository to your local development machine (e.g. `git clone https://gitlab.com/<YOUR_GITLAB_USER>/multi_window.git`)
* Create a new local branch, you can base it on the issue itself (e.g. `git checkout -b 12-new-feature`)
* Make your changes and test your changes if required
* Push your new branch to your own fork into the same remote branch (e.g. `git push origin 12-new-feature`)
* On Gitlab go to the [merge request page](https://docs.gitlab.com/ee/user/project/repository/forking_workflow.html#merging-upstream) on your own fork and create a merge request to this reposistory

# Development Guidelines

* Documentation should always be updated where required.
* Example application should be updated with showcases for new features.
* Format the Flutter code accordingly.
* Note the [`analysis_options.yaml`](https://gitlab.com/wolfenrain/multi_window/-/blob/master/analysis_options.yaml) and write code as stated in this file

# Test generating of `dartdoc`

* On local development make sure the `dartdoc` program is mentioned in your `$PATH`
* `dartdoc` can be found here: `<FLUTTER_INSTALL_DIR>/bin/cache/dart-sdk/bin/dartdoc`
* Generate docs with the following command: `dartdoc --no-auto-include-dependencies --quiet`
* Output will be placed into `doc/api/`

# Communicating between Dart and Native

The communication between Native code and Dart goes through EventChannels. See the [Events table](#events-table) for an overview of all the implemented system events.

Check this [overview](https://flutter.dev/docs/development/platform-integration/platform-channels?tab=ios-channel-swift-tab#codec) for more information on platform channel data types support and codecs.

### Events table

Reference table of all the events the system events the plugin supports and their native platform counter part.

| Dart Event name | MacOS | Linux | Windows  |
| --- | --- | --- | --- |
| windowClose          | [windowWillClose](https://developer.apple.com/documentation/appkit/nswindowdelegate/1419605-windowwillclose) | [delete-event](https://developer.gnome.org/gtk3/stable/GtkWidget.html#GtkWidget-delete-event) | |
