library multi_window;

import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:multi_window/echo.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/platform_not_implemented.dart';
import 'package:multi_window_interface/data_event.dart';
import 'package:multi_window_linux/multi_window_linux.dart';
import 'package:multi_window_macos/multi_window_macos.dart';

export 'package:multi_window_interface/data_event.dart';

class MultiWindow {
  static late final MultiWindow _currentWindow;

  /// The current instance of this window.
  static MultiWindow get current => _currentWindow;

  /// Initialize the [MultiWindow] plugin.
  ///
  /// The [args] list come from the `main` method, it will determine the current
  /// window based on it.
  static void init(List<String> args) {
    print('Initializing unknown');
    if (args.isNotEmpty) {
      if (args.first.startsWith('-')) {
        // Xcode adds parameters.
        _currentWindow = MultiWindow._('main');
      } else {
        _currentWindow = MultiWindow._(args.first);
      }
    } else {
      _currentWindow = MultiWindow._('main');
    }
    echo('Initialized');
  }

  static void _ensureInitialized() {
    if (!kIsWeb && MultiWindowInterface.instance is PlatformNotImplemented) {
      if (Platform.isWindows) {
        MultiWindowInterface.instance = PlatformNotImplemented();
      } else if (Platform.isMacOS) {
        MultiWindowInterface.instance = MultiWindowMacOS();
      } else if (Platform.isLinux) {
        MultiWindowInterface.instance = MultiWindowLinux();
      }
    }
  }

  /// Create a new window with given [key].
  ///
  /// If a window with the given [key] already exists then the returned
  /// [MultiWindow] will be linked to that window.
  ///
  /// An optional [size] can be passed. If none is given it will use the size of
  /// the main window.
  ///
  /// An optional [title] can be passed. If none is given it will use the title
  /// of the main window.
  ///
  /// The [alignment] can be used to position the created window on the screen.
  /// If none is passed it will be centered on top of the window that will
  /// create this window.
  static Future<MultiWindow> create(
    String key, {
    Size? size,
    String? title,
    Alignment? alignment,
  }) async {
    assert(!key.startsWith('-'), 'Keys cannot start with "-"');
    _ensureInitialized();

    await MultiWindowInterface.instance.create(
      key,
      size: size,
      title: title,
      alignment: alignment,
    );
    return MultiWindow._(key);
  }

  /// Return the count of all created windows.
  static Future<int> count() {
    _ensureInitialized();
    return MultiWindowInterface.instance.count();
  }

  /// The key with which this window is identified.
  final String key;

  Stream<DataEvent>? _events;

  StreamController<DataEvent> _streamController = StreamController();

  /// Event stream on which all events for this window will be received.
  Stream<DataEvent> get events {
    if (_events == null) {
      _events = _streamController.stream;
      MultiWindowInterface.instance
          .events(key, MultiWindow.current.key)
          .listen(_streamController.add);
    }
    return _events!;
  }

  MultiWindow._(this.key) {
    _ensureInitialized();
  }

  @mustCallSuper
  void dispose() {
    _streamController.close();
  }

  /// Retrieve the title of this window.
  Future<String> getTitle() {
    return MultiWindowInterface.instance.getTitle(key);
  }

  /// Set the title of this window.
  Future<void> setTitle(String title) {
    return MultiWindowInterface.instance.setTitle(key, title);
  }

  /// Emit [data] to this window.
  ///
  /// [data] can be anything as long as it is a Dart standart data type.
  Future<void> emit(dynamic data) {
    return MultiWindowInterface.instance.emit(key, current.key, data);
  }

  Future<void> close() {
    return MultiWindowInterface.instance.close(key);
  }
}
