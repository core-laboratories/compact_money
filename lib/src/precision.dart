/// Decimal places in the shortest input representation; may be negative.
int decimalPlaces(num value) {
  final parts = value.toString().split('e');
  final coefficient = parts.first;
  final exponent = parts.length == 1 ? 0 : int.parse(parts.last);
  final point = coefficient.indexOf('.');
  final fractionLength = point < 0 ? 0 : coefficient.length - point - 1;
  final digits = coefficient.replaceAll('.', '');
  final trailingZeros =
      digits.length - digits.replaceFirst(RegExp(r'0+$'), '').length;
  return fractionLength - exponent - trailingZeros;
}
