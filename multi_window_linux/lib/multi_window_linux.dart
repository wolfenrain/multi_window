import 'package:flutter/services.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/data_event.dart';

class MultiWindowLinux extends MultiWindowInterface {
  static const MethodChannel _methodChannel =
      const MethodChannel('multi_window_linux');

  Map<String, EventChannel> _eventChannels = {};
  Map<String, Stream<DataEvent>> _eventStreams = {};

  @override
  Stream<DataEvent> events(String key) {
    if (!_eventChannels.containsKey(key)) {
      _eventChannels[key] = EventChannel('multi_window_linux/events/$key');
      _eventStreams[key] =
          _eventChannels[key]!.receiveBroadcastStream(key).map(DataEvent.from);
    }

    return _eventStreams[key]!;
  }

  @override
  Future<void> create(String key) async {
    await _methodChannel.invokeMethod<void>('create', {'key': key});
  }

  @override
  Future<int> count() async {
    return await _methodChannel.invokeMethod<int>('count', {}) ?? 1;
  }

  @override
  Future<String> getTitle(String key) async {
    final title = await _methodChannel.invokeMethod<String>('getTitle', {
      'key': key,
    });
    return title!;
  }

  @override
  Future<void> setTitle(String key, String title) {
    return _methodChannel.invokeMethod<void>('setTitle', {
      'key': key,
      'title': title,
    });
  }

  @override
  Future<void> emit(String key, data) {
    return _methodChannel.invokeMethod<void>('emit', {
      'key': key,
      'data': data,
    });
  }
}
