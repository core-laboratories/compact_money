import 'package:compact_money/src/rounding.dart';
import 'package:test/test.dart';

void main() {
  final cases = <(num, int, num)>[
    (2.5, 0, 2),
    (3.5, 0, 4),
    (4.5, 0, 4),
    (5.5, 0, 6),
    (1.245, 2, 1.24),
    (1.255, 2, 1.26),
    (12.45, 1, 12.4),
    (12.55, 1, 12.6),
    (1.244999999, 2, 1.24),
    (1.245000001, 2, 1.25),
    (1.254999999, 2, 1.25),
    (1.255000001, 2, 1.26),
    (2.499999999, 0, 2),
    (2.500000001, 0, 3),
    (0.005, 2, 0),
    (0.015, 2, 0.02),
    (1.234, 2, 1.23),
    (1000000000000000.25, 0, 1000000000000000),
    (1000000000000000.5, 0, 1000000000000000),
    (1000000000000001.5, 0, 1000000000000002),
    (double.maxFinite, 0, double.maxFinite),
    (double.maxFinite, 2, double.maxFinite),
  ];
  for (final (value, decimals, expected) in cases) {
    test('half-even $value at $decimals decimals -> $expected', () {
      expect(roundHalfEven(value, decimals), expected);
      expect(roundHalfEven(-value, decimals), -expected);
    });
  }
  test('default integer rounding', () => expect(roundHalfEven(2.5), 2));
  for (final (value, expected) in [
    (8.123, 8.12),
    (81.234, 81.2),
    (812.345, 812),
  ]) {
    test(
      'financial precision $value',
      () => expect(financialRound(value), expected),
    );
  }
}
