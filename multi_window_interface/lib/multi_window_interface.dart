library multi_window_interface;

import 'dart:ui';

import 'package:flutter/material.dart';
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

  /// Setup a EventChannel to the native side for a window identified by [key].
  ///
  /// The [creatorKey] is used as a unique value for each instance of a window,
  /// to ensure the right engine is linking up to the right event channel.
  /// Should default to the current window's key.
  Stream<DataEvent> events(String key, String creatorKey);

  /// Create a new window identified by the given [key].
  ///
  /// If there already exists a window with [key] then the native code won't
  /// create another window.
  ///
  /// An optional [size] can be passed. If none is given it should use the size
  /// of the main window.
  ///
  /// An optional [title] can be passed. If none is given it should use the
  /// title of the main window.
  ///
  /// The [alignment] can be used to position the created window on the screen.
  /// If none is passed it should be centered on top of the window that will
  /// create this window.
  Future<void> create(
    String key, {
    Size? size,
    String? title,
    Alignment? alignment,
  });

  /// Return the count of all created windows.
  Future<int> count();

  /// Get the title on a window identified by the given [key].
  Future<String> getTitle(String key);

  /// Set the [title] on a window identified by the given [key].
  Future<void> setTitle(String key, String title);

  /// Emit [data] to the window identified by the given [key].
  ///
  /// The [from] should default to the current window's key.
  /// [data] can be anything as long as it is a Dart standart data type.
  Future<void> emit(String key, String from, dynamic data);

  Future<void> close(String key);
}
