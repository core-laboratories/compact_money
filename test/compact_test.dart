import 'dart:convert';
import 'dart:io';

import 'package:compact_money/compact_money.dart';
import 'package:test/test.dart';

void main() {
  for (final decimals in [-1, 101]) {
    test('rejects invalid decimals $decimals', () {
      expect(
        () => compact(CompactOptions(amount: 8123456, decimals: decimals)),
        throwsArgumentError,
      );
    });
  }
  test('rounding is opt-in for the constructor and both entry points', () {
    const options = CompactOptions(amount: 30487, currency: 'VND');
    expect(options.allowRounding, isFalse);
    expect(compact(options).amount, 30487);
    expect(compactAmount(options).amount, 30487);
    expect(
      compact(const CompactOptions(amount: 30487, allowRounding: true)).amount,
      30.5,
    );
  });
  final fixtures =
      jsonDecode(File('test/fixtures/compaction.json').readAsStringSync())
          as List<dynamic>;
  for (final raw in fixtures) {
    final fixture = raw as Map<String, dynamic>;
    final input = fixture['input'] as Map<String, dynamic>;
    final expected = fixture['expected'] as Map<String, dynamic>;
    test('$input -> $expected', () {
      final options = CompactOptions(
        amount: input['amount'] as num,
        currency: input['currency'] as String?,
        allowRounding: input['allowRounding'] as bool? ?? false,
        decimals: input['decimals'] as int?,
      );
      final result = compact(options);
      expect(result.amount, expected['amount']);
      expect(result.unit.symbol, expected['unit']);
      expect(result.currency, expected['currency']);
      expect(compactAmount(options), result);
    });
  }
  for (final amount in [
    0,
    -0.0,
    -0.001,
    double.minPositive,
    -double.minPositive,
  ]) {
    test('zero normalization $amount', () {
      final result = compact(
        CompactOptions(amount: amount, allowRounding: true),
      );
      expect(result.amount, 0);
      expect(result.amount.isNegative, isFalse);
      expect(result.unit, CompactUnit.none);
    });
  }
  for (final amount in [0, -0.0, double.minPositive, -double.minPositive]) {
    test('unrounded tiny value $amount', () {
      final result = compact(
        CompactOptions(amount: amount, allowRounding: false),
      );
      expect(result.amount, amount);
      expect(result.unit, CompactUnit.none);
      if (amount == 0) {
        expect(result.amount.isNegative, isFalse);
      }
    });
  }
  for (final amount in [double.nan, double.infinity, double.negativeInfinity]) {
    test(
      'invalid amount $amount',
      () => expect(
        () => compact(CompactOptions(amount: amount)),
        throwsArgumentError,
      ),
    );
  }
  for (final currency in ['', '   ', '\t\n']) {
    test(
      'invalid currency "$currency"',
      () => expect(
        () => compact(CompactOptions(amount: 1, currency: currency)),
        throwsArgumentError,
      ),
    );
  }
  for (final amount in [
    double.maxFinite,
    -double.maxFinite,
    9007199254740991,
    -9007199254740991,
  ]) {
    test('large finite amount $amount', () {
      final result = compact(
        CompactOptions(amount: amount, allowRounding: true),
      );
      expect(result.amount.isFinite, isTrue);
      expect(result.unit, CompactUnit.trillion);
      if (amount.abs() == double.maxFinite) {
        expect(result.amount, amount / 1e12);
      }
    });
  }
  test('clean integers and decimal inputs', () {
    expect(compact(const CompactOptions(amount: 80000)).amount, isA<int>());
    expect(compact(const CompactOptions(amount: 1.234)).amount, 1.234);
  });
  test('immutable result value equality and diagnostic string', () {
    const a = CompactResult(
      amount: 80,
      unit: CompactUnit.thousand,
      currency: 'VND',
    );
    final b = compact(const CompactOptions(amount: 80000, currency: 'VND'));
    expect(a, a);
    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(
      a,
      isNot(
        const CompactResult(
          amount: 81,
          unit: CompactUnit.thousand,
          currency: 'VND',
        ),
      ),
    );
    expect(
      a,
      isNot(
        const CompactResult(
          amount: 80,
          unit: CompactUnit.million,
          currency: 'VND',
        ),
      ),
    );
    expect(
      a,
      isNot(const CompactResult(amount: 80, unit: CompactUnit.thousand)),
    );
    expect(a, isNot('80k VND'));
    expect(
      a.toString(),
      'CompactResult(amount: 80, unit: CompactUnit.thousand, currency: VND)',
    );
  });
}
