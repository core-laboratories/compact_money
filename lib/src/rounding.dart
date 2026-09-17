import 'dart:math' as math;

/// Internal rounding with capped tolerance for binary midpoint noise.
num roundHalfEven(num value, [int decimals = 0]) {
  final factor = math.pow(10.0, decimals);
  final scaled = value.abs() * factor;
  // Doubles have no fractional precision here; avoid integer conversion overflow.
  if (scaled >= 4503599627370496) return value;
  final lower = scaled.floor();
  final fraction = scaled - lower;
  final tolerance = math.min(1e-7, 2 * 2.220446049250313e-16 * scaled);
  final rounded = (fraction - 0.5).abs() <= tolerance
      ? lower + lower % 2
      : lower + (fraction > 0.5 ? 1 : 0);
  return cleanNumber(value.sign * rounded / factor);
}

/// Applies the financial decimal-place policy.
num financialRound(num value) {
  final magnitude = value.abs();
  return roundHalfEven(
    value,
    magnitude < 10
        ? 2
        : magnitude < 100
        ? 1
        : 0,
  );
}

/// Normalizes zero and integers safely on the Dart VM and JavaScript web.
num cleanNumber(num value) {
  if (value == 0) return 0;
  if (value.abs() <= 9007199254740991 && value == value.truncateToDouble()) {
    return value.toInt();
  }
  return value;
}
