import 'package:multi_window/multi_window.dart';

/// Simple replacement for [print], logs current window key as a prefix.
void echo(Object? object) {
  print('[${MultiWindow.current.key}] $object');
}
