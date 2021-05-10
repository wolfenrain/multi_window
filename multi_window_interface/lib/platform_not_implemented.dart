import 'package:multi_window_interface/multi_window_interface.dart';

class PlatformNotImplemented extends MultiWindowInterface {
  @override
  Future<void> createWindow() => throw UnimplementedError();
}
