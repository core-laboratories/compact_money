import 'package:compact_money/compact_money.dart';
import 'package:test/test.dart';

void main() {
  test('unit symbols in ascending magnitude', () {
    expect(CompactUnit.values.map((unit) => unit.symbol), [
      '',
      'k',
      'M',
      'B',
      'T',
    ]);
  });
}
