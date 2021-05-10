import 'dart:async';

import 'package:flutter/services.dart';
import 'package:multi_window_interface/multi_window_interface.dart';

class MultiWindowLinux extends MultiWindowInterface {
  static const MethodChannel _channel =
      const MethodChannel('multi_window_linux');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  @override
  Future<void> createWindow() async {
    print(await _channel.invokeMethod('create'));
  }
}
