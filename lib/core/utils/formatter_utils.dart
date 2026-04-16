import 'package:flutter/services.dart';

/// Text input formatters for the medical platform.
class TextFormatter {
  /// Formatter that ensures:
  /// 1. Only alphabets and spaces are allowed.
  /// 2. First letter and letters after spaces are uppercase (Title Case).
  /// 3. Maximum of one space is allowed in total.
  /// 4. No consecutive spaces.
  static TextInputFormatter name() => _TextNameFormatter();
}

class _TextNameFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    // 1. Filter: Allow only alphabets and spaces
    var text = newValue.text.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');

    // 2. Space Control: No consecutive spaces, no leading space
    text = text.replaceAll(RegExp(r'\s{2,}'), ' ');
    if (text.startsWith(' ')) text = text.trimLeft();

    // 3. Limit: Only one space allowed total
    final firstSpaceIndex = text.indexOf(' ');
    if (firstSpaceIndex != -1) {
      final subAfterSpace = text.substring(firstSpaceIndex + 1);
      if (subAfterSpace.contains(' ')) {
        // If there's another space, revert to old or strip it
        return oldValue;
      }
    }

    // 4. Case Control: Title Case (First letter + letters after space)
    final words = text.split(' ');
    final capitalized = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();

    final resultText = capitalized.join(' ');

    // 5. Selection Management: Keep cursor position logical.
    // (Simple approach: if text changed significantly,
    // move to end or keep relative).
    var selectionIndex = newValue.selection.end;
    if (resultText.length != newValue.text.length) {
      selectionIndex = resultText.length;
    }

    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
