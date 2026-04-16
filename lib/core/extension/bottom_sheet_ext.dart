import 'package:flutter/material.dart';

/// Extension on [BuildContext] to provide utility methods for
/// showing bottom sheets.
extension BottomSheetExt on BuildContext {
  /// Shows a custom styled bottom sheet with the given [child] widget.
  Future<T?> showAppBottomSheet<T>(Widget child) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: child,
      ),
    );
  }
}
