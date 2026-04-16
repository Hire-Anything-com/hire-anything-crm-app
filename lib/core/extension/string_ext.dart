/// Extension on [String] to provide text manipulation and validation.
extension StringExt on String {
  /// Returns the string with the first character capitalized.
  String get capitalize =>
      isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : this;

  /// Returns true if the string is a valid email address.
  bool get isValidEmail => RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$',
  ).hasMatch(this);

  /// Returns true if the string meets password complexity requirements.
  bool get isHardPassword => RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  ).hasMatch(this);
}

/// Extension on nullable [String] to provide utility methods.
extension StringOptionalExt on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;
}
