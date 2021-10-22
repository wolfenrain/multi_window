import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_window_interface/multi_window_interface.dart';
import 'package:multi_window_interface/data_event.dart';

class MultiWindowMacOS extends MultiWindowInterface {
  static const MethodChannel _methodChannel =
      const MethodChannel('multi_window_macos');

  Map<String, EventChannel> _eventChannels = {};
  Map<String, Stream<DataEvent>> _eventStreams = {};

  @override
  Stream<DataEvent> events(String key, String creatorKey) {
    if (!_eventChannels.containsKey(key)) {
      _eventChannels[key] = EventChannel('multi_window_macos/events/$key');
      _eventStreams[key] = _eventChannels[key]!
          .receiveBroadcastStream('$creatorKey/$key')
          .map(DataEvent.fromMap);
    }

    return _eventStreams[key]!;
  }

  @override
  Future<void> create(
    String key, {
    Size? size,
    String? title,
    Alignment? alignment,
  }) async {
    await _methodChannel.invokeMethod<void>('create', {
      'key': key,
      'size': size != null
          ? {
              'width': size.width,
              'height': size.height,
            }
          : null,
      'title': title,
      'alignment': alignment != null
          ? {
              'x': alignment.x,
              'y': alignment.y,
            }
          : null,
    });
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
  Future<void> emit(String key, String from, dynamic data) {
    return _methodChannel.invokeMethod<void>('emit', {
      'key': key,
      'from': from,
      'data': data,
    });
  }

  @override
  Future<void> close(String key) {
    return _methodChannel.invokeMethod<void>('close', {
      'key': key,
    });
  }
}
