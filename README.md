[![plugin version](https://img.shields.io/pub/v/multi_window?label=pub)](https://pub.dev/packages/multi_window)
[![coverage report](https://gitlab.com/wolfenrain/multi_window/badges/master/coverage.svg)](https://gitlab.com/wolfenrain/multi_window/-/commits/master)
[![pipeline status](https://gitlab.com/wolfenrain/multi_window/badges/master/pipeline.svg)](https://gitlab.com/wolfenrain/multi_window/-/commits/master)
[![dependencies](https://img.shields.io/librariesio/release/pub/multi_window?label=dependencies)](https://gitlab.com/wolfenrain/multi_window/-/blob/master/multi_window/pubspec.yaml)
<h1 align="center">multi_window</h1>

**NOTE**: This plugin is still under heavy development, as long as v1 hasn't been reach expect breaking changes left and right.

## Development and Contributing

Interested in contributing? We love merge requests! See the [Contribution](https://gitlab.com/wolfenrain/multi_window/-/tree/master/CONTRIBUTING.md) guidelines.

## Current state of development

The following list is a list of all the features we want to implement, that are implemented and possible tasks that are still needed to be done.

- Create new flutter windows
  - [x] Linux
  - [x] macOS
  - [ ] Windows
- Communicate between windows through EventChannels
  - [x] Linux
    - [x] Cleanup references to closed event channels
  - [x] macOS
    - [x] Cleanup references to closed event channels
  - [ ] Windows
    - [ ] Cleanup references to closed event channels
- Emit user events
  - [x] Linux
  - [x] macOS
  - [ ] Windows
- Emit system events
  - Close
    - [x] Linux
      - [x] Remove all references to windows/event channels
    - [x] macOS
      - [x] Remove all references to windows/event channels
    - [ ] Windows
      - [ ] Remove all references to windows/event channels
  - Minimize
    - [ ] Linux
    - [ ] macOS
    - [ ] Windows
  - Maximize
    - [ ] Linux
    - [ ] macOS
    - [ ] Windows
- Update window properties on the go
  - title
    - [x] Linux
    - [x] macOS
    - [ ] Windows
