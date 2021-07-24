<h1 align="center">multi_window</h1>

## Development and Contributing
Interested in contributing? We love merge requests! See the [Contribution](https://gitlab.com/wolfenrain/multi_window/-/tree/master/CONTRIBUTING.md) guidelines.

## Current state of development

## Features implemented
- Create new flutter windows
  - [x] Linux
    - [ ] Cleanup references to closed windows
  - [x] macOS
    - [x] Cleanup references to closed windows
  - [ ] Windows
    - [ ] Cleanup references to closed windows
- Communicate between windows through EventChannels
  - [x] Linux
    - [ ] Cleanup references to closed event channels
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
    - [ ] Linux
      - [ ] Remove all references to windows/event channels
    - [x] macOS
      - [ ] Remove all references to windows/event channels
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
