/// Centralized clinical validation utility class.
class ValidationUtils {
  /// Strict email validation regex.
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+\.[a-z]+$',
  );

  /// Validates email strictly for clinical authenticity.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Simple required field validation for passwords on login.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates that a name contains only alphabets and spaces.
  static String? validateName(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Please enter a valid $fieldName (alphabets only)';
    }
    return null;
  }

  /// Strict password security validation for signup.
  /// Rules: 8+ chars, 1 uppercase, 1 lowercase, 1 digit.
  static String? validatePasswordSecurity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!value.contains(RegExp('[A-Z]'))) {
      return 'At least one uppercase letter required';
    }
    if (!value.contains(RegExp('[a-z]'))) {
      return 'At least one lowercase letter required';
    }
    if (!RegExp('[0-9]').hasMatch(value)) {
      return 'At least one digit required';
    }
    return null;
  }

  /// Form validation helper for login forms
  static String? validateLoginEmail(String? value) {
    return validateEmail(value);
  }

  static String? validateLoginPassword(String? value) {
    return validateRequired(value, 'Password');
  }

  static bool isLoginFormValid(String email, String password) {
    return validateEmail(email) == null && password.isNotEmpty;
  }
}
