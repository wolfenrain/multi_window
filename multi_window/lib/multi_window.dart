library multi_window;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/platform_not_implemented.dart';
import 'package:multi_window_interface/data_event.dart';
import 'package:multi_window_linux/multi_window_linux.dart';
import 'package:multi_window_macos/multi_window_macos.dart';

class MultiWindow {
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
    _ensureInitialized();

    await MultiWindowInterface.instance.create(key);
    return MultiWindow._(key);
  }

  static Future<int> count() {
    _ensureInitialized();

    return MultiWindowInterface.instance.count();
  }

  final String key;

  Stream<DataEvent> get events {
    return MultiWindowInterface.instance.events.where(
      (event) => event.key == key,
    );
  }

  MultiWindow._(this.key);

  Future<String> getTitle() {
    return MultiWindowInterface.instance.getTitle(key);
  }

  Future<void> setTitle(String title) async {
    return MultiWindowInterface.instance.setTitle(key, title);
  }
}
