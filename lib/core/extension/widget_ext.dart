import 'package:flutter/material.dart';

/// Extension on [Widget] to provide common styling and layout utilities.
extension WidgetExt on Widget {
  /// Wraps the widget with [Padding] on all sides.
  Widget paddingAll(double value) =>
      Padding(padding: EdgeInsets.all(value), child: this);

  /// Wraps the widget with symmetric [Padding].
  Widget paddingSymmetric({double h = 0.0, double v = 0.0}) => Padding(
    padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
    child: this,
  );

  /// Conditionally displays the widget.
  Widget visible({required bool condition}) =>
      condition ? this : const SizedBox.shrink();
}
