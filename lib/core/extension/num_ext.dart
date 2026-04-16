import 'package:flutter/material.dart';

/// Extension on [num] to provide shorthand [SizedBox] creators.
extension NumExt on num {
  /// Returns a [SizedBox] with the given height.
  SizedBox get h => SizedBox(height: toDouble());

  /// Returns a [SizedBox] with the given width.
  SizedBox get w => SizedBox(width: toDouble());

  /// Returns a [SizedBox] with the given height.
  SizedBox get height => h;

  /// Returns a [SizedBox] with the given width.
  SizedBox get width => w;
}
