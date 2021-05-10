library multi_window;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/platform_not_implemented.dart';
import 'package:multi_window_linux/multi_window_linux.dart';

class MultiWindow {
  static void init() {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        MultiWindowInterface.instance = PlatformNotImplemented();
      } else if (Platform.isMacOS) {
        MultiWindowInterface.instance = PlatformNotImplemented();
      } else if (Platform.isLinux) {
        MultiWindowInterface.instance = MultiWindowLinux();
      }
    }
  }

  static Future<void> create() {
    return MultiWindowInterface.instance.createWindow();
  }
}
