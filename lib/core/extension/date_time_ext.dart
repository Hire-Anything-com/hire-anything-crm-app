import 'package:intl/intl.dart';

/// Extension on [DateTime] to provide common formatting patterns.
extension DateExt on DateTime {
  /// Returns date in dd/MM/yyyy format.
  String get formatDate => DateFormat('dd/MM/yyyy').format(this);

  /// Returns time in hh:mm a format.
  String get formatTime => DateFormat('hh:mm a').format(this);

  /// Returns date and time in dd/MM/yyyy hh:mm a format.
  String get formatDateTime => DateFormat('dd/MM/yyyy hh:mm a').format(this);
}
