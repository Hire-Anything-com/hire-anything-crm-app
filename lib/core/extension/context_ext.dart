import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Extension on [BuildContext] to access common theme and layout information.
extension ContextExt on BuildContext {
  /// Returns the current [ThemeData].
  ThemeData get theme => Theme.of(this);

  GoRouterState get goRouterState => GoRouterState.of(this);

  /// Returns the current [TextTheme].
  TextTheme get textTheme => theme.textTheme;

  /// Returns the current [ColorScheme].
  ColorScheme get colorScheme => theme.colorScheme;

  /// Returns the screen size.
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Returns the screen width.
  double get screenWidth => screenSize.width;

  /// Returns the screen height.
  double get screenHeight => screenSize.height;

  /// Returns whether the current view is view-only.
  bool get isViewOnly => false;

  /// Shows a clinical snackbar with the given [message].
  void showSnackBar(String message, {bool isWarning = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isWarning ? colorScheme.error : null,
      ),
    );
  }
}
