library multi_window;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/platform_not_implemented.dart';
import 'package:multi_window_interface/data_event.dart';
import 'package:multi_window_linux/multi_window_linux.dart';
import 'package:multi_window_macos/multi_window_macos.dart';

export 'package:multi_window_interface/data_event.dart';

class MultiWindow {
  static late final MultiWindow _currentWindow;

  static MultiWindow get current => _currentWindow;

  static void init(List<String> args) {
    _ensureInitialized();
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

  static Future<MultiWindow> create(String key) async {
    assert(!key.startsWith('-'), 'Keys cannot start with "-"');
    _ensureInitialized();

    // TODO cache reference?

    await MultiWindowInterface.instance.create(key);
    return MultiWindow._(key);
  }

  static Future<int> count() {
    _ensureInitialized();
    return MultiWindowInterface.instance.count();
  }

  final String key;

  Stream<DataEvent>? _events;

  StreamController<DataEvent> _streamController = StreamController();

  Stream<DataEvent> get events {
    if (_events == null) {
      _events = _streamController.stream;
      MultiWindowInterface.instance.events(key).listen((e) {
        if (e.key == key) {
          _streamController.add(e);
        }
      });
    }
    return _events!;
  }

  MultiWindow._(this.key) {
    _ensureInitialized();
  }

  Future<String> getTitle() {
    return MultiWindowInterface.instance.getTitle(key);
  }

  Future<void> setTitle(String title) async {
    return MultiWindowInterface.instance.setTitle(key, title);
  }

  Future<void> emit(dynamic data) async {
    return MultiWindowInterface.instance.emit(key, data);
  }
}
