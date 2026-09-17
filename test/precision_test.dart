import 'package:compact_money/compact_money.dart';
import 'package:compact_money/src/precision.dart';
import 'package:test/test.dart';

void main() {
  for (final (amount, places) in <(num, int)>[
    (8123000, -3),
    (8123000.0, -3),
    (-8123000, -3),
    (1.234, 3),
    (1000.0000000000001, 13),
    (1e21, -21),
    (1e-7, 7),
    (double.minPositive, 324),
  ]) {
    test('decimal representation of $amount', () {
      expect(decimalPlaces(amount), places);
    });
  }
  for (final (options, amount, unit) in [
    (const CompactOptions(amount: 8123456), 8123456, CompactUnit.none),
    (const CompactOptions(amount: 8123000), 8123, CompactUnit.thousand),
    (
      const CompactOptions(amount: 8123000, decimals: 3),
      8.123,
      CompactUnit.million,
    ),
    (
      const CompactOptions(amount: 8123456, decimals: 3),
      8123.456,
      CompactUnit.thousand,
    ),
    (
      const CompactOptions(amount: 1000.0000000000001),
      1000.0000000000001,
      CompactUnit.none,
    ),
    (
      const CompactOptions(amount: 8123456, decimals: 1, allowRounding: true),
      8.1,
      CompactUnit.million,
    ),
    (
      const CompactOptions(amount: 999999, decimals: 2, allowRounding: true),
      1,
      CompactUnit.million,
    ),
  ]) {
    test(
      'portable decimal selection for ${options.amount}, decimals ${options.decimals}, rounding ${options.allowRounding}',
      () {
        final result = compact(options);
        expect(result.amount, amount);
        expect(result.unit, unit);
      },
    );
  }
}
