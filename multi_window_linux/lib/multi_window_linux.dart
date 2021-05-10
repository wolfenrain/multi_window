import 'package:flutter/services.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/data_event.dart';

class MultiWindowLinux extends MultiWindowInterface {
  static const MethodChannel _methodChannel =
      const MethodChannel('multi_window_linux');

  static const EventChannel _eventChannel =
      const EventChannel('multi_window_linux/events');

  @override
  Stream<DataEvent> get events {
    return _eventChannel.receiveBroadcastStream().map(DataEvent.from);
  }

  @override
  Future<void> create(String key) async {
    await _methodChannel.invokeMethod('create');
  }

  @override
  Future<int> count() async => await _methodChannel.invokeMethod('count');

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
