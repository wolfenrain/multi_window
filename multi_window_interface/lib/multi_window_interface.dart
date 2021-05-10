library multi_window_interface;

import 'package:multi_window_interface/data_event.dart';
import 'package:multi_window_interface/platform_not_implemented.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

abstract class MultiWindowInterface extends PlatformInterface {
  static final Object _token = Object();

  static MultiWindowInterface _instance = PlatformNotImplemented();

  /// The default instance of [MultiWindowInterface] to use.
  static MultiWindowInterface get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [MultiWindowInterface] when they register themselves.
  static set instance(MultiWindowInterface instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  MultiWindowInterface() : super(token: _token);

  Stream<DataEvent> get events;

  Future<void> create(String key);

  Future<int> count();

  Future<String> getTitle(String key);

  Future<void> setTitle(String key, String title);
}
