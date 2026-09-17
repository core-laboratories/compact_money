import 'package:compact_money/compact_money.dart';

void main() {
  const values = [
    CompactOptions(amount: 30487, currency: 'VND'),
    CompactOptions(amount: 8123000, currency: 'VND'),
    CompactOptions(amount: 8123000, currency: 'VND', decimals: 3),
    CompactOptions(
      amount: 8123456,
      currency: 'VND',
      allowRounding: true,
      decimals: 1,
    ),
    CompactOptions(amount: 8123456, currency: 'VND'),
    CompactOptions(amount: 25000, currency: 'LAK'),
    CompactOptions(amount: 81234, currency: 'EUR'),
    CompactOptions(amount: 1250000, currency: 'CSK'),
    CompactOptions(amount: 1.245, currency: 'BTC'),
    CompactOptions(amount: 8123456, currency: 'VND', allowRounding: true),
  ];
  for (final value in values) {
    final result = compact(value);
    print('${result.amount} ${result.unit.symbol} ${result.currency ?? ''}');
  }
}
