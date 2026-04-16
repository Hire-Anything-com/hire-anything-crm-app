/// Extension on [bool] to provide utility methods.
extension BoolExt on bool {
  /// Converts boolean to integer (true: 1, false: 0).
  int get toInt => this ? 1 : 0;
}
