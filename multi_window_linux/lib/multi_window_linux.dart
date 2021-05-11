import 'package:flutter/foundation.dart';
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
      _eventChannels[key] = EventChannel('multi_window_macos/events/$key');
      _eventStreams[key] =
          _eventChannels[key]!.receiveBroadcastStream().map(DataEvent.from);
    }

    return _eventStreams[key]!;
  }

  @override
  Future<void> create(String key) async {
    await _methodChannel.invokeMethod('create', {'key': key});
  }

  @override
  Future<int> count() async {
    // If running in debug mode we have to remove 1 because Flutter uses a
    // hidden window.
    return ((await _methodChannel.invokeMethod('count')) ?? 2) -
        (kDebugMode ? 1 : 0);
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

  @override
  Future<void> emit(String key, data) {
    return _methodChannel.invokeMethod('emit', {
      'key': key,
      'data': data,
    });
  }
}
