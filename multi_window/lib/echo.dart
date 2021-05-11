import 'package:multi_window/multi_window.dart';

void echo(Object? object) {
  print('[${MultiWindow.current.key}] $object');
}