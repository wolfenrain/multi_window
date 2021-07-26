import 'package:flutter/material.dart';
import 'package:multi_window/multi_window.dart';

/// Helper widget that picks up the right widget based on the [MultiWindow.key].
class MultiWidget extends StatelessWidget {
  /// Map of widgets to map between depending on the key.
  final Map<String, Widget> widgets;

  /// Optional fallback widget when none of the [widgets] match.
  final Widget? fallback;

  MultiWidget(
    this.widgets, {
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (widgets.containsKey(MultiWindow.current.key)) {
      return widgets[MultiWindow.current.key]!;
    }
    if (fallback != null) {
      return fallback!;
    }
    throw Exception('No widget found for "${MultiWindow.current.key}');
  }
}
