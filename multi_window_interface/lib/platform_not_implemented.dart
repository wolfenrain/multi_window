import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:multi_window_interface/data_event.dart';
import 'package:multi_window_interface/multi_window_interface.dart';

class PlatformNotImplemented extends MultiWindowInterface {
  @override
  Stream<DataEvent> events(
    String key,
    String creatorKey,
  ) =>
      throw UnimplementedError();

  @override
  Future<void> create(
    String key, {
    Size? size,
    String? title,
    Alignment? alignment,
  }) async =>
      throw UnimplementedError();

  @override
  Future<int> count() async => throw UnimplementedError();

  @override
  Future<String> getTitle(String key) => throw UnimplementedError();

  @override
  Future<void> setTitle(String key, String title) => throw UnimplementedError();

  @override
  Future<void> emit(String key, String from, data) =>
      throw UnimplementedError();

  @override
  Future<void> close(String key) => throw UnimplementedError();
}
