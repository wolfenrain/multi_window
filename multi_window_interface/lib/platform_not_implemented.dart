import 'package:multi_window_interface/data_event.dart';
import 'package:multi_window_interface/multi_window_interface.dart';

class PlatformNotImplemented extends MultiWindowInterface {
  @override
  Stream<DataEvent> events(String key) => throw UnimplementedError();

  @override
  Future<void> create(String key) async => throw UnimplementedError();

  @override
  Future<int> count() async => throw UnimplementedError();

  @override
  Future<String> getTitle(String key) => throw UnimplementedError();

  @override
  Future<void> setTitle(String key, String title) => throw UnimplementedError();

  @override
  Future<void> emit(String key, String from, data) => throw UnimplementedError();
}
