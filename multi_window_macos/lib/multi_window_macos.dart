import 'package:flutter/services.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/data_event.dart';

class MultiWindowMacOS extends MultiWindowInterface {
  static const MethodChannel _methodChannel =
      const MethodChannel('multi_window_macos');

  static const EventChannel _eventChannel =
      const EventChannel('multi_window_macos/events');

  @override
  Stream<DataEvent> get events {
    return _eventChannel.receiveBroadcastStream().map(DataEvent.from);
  }

  @override
  Future<void> create(String key) async {
    await _methodChannel.invokeMethod('create', {'key': key});
  }

  @override
  Future<int> count() async {
    return await _methodChannel.invokeMethod<int>('count', {}) ?? 1;
  }

  @override
  Future<String> getTitle(String key) {
    return _methodChannel.invokeMethod('getTitle', {
      'key': key,
    }) as Future<String>;
  }

  @override
  Future<void> setTitle(String key, String title) {
    return _methodChannel.invokeMethod('getTitle', {
      'key': key,
      'title': title,
    });
  }
}
