# multi_window_interface

A common platform interface for the [multi_window](https://pub.dev/packages/multi_window) plugin.

Platform-specific implementations of the `multi_window` can be created through this interface.

## Implementing

To implement a platform-specific implementation, extend `MultiWindowPlatformInterface` with an implementation that performs the platform-specific behavior. And ensure you register your plugin by setting `MultiWindowPlatformInterface.instance` to your own implementation at run-time.
