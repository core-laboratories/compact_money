import 'compact_unit.dart';

/// Immutable structured output with value equality. Formatting is up to callers.
class CompactResult {
  /// Creates a result from an amount, unit and optional currency metadata.
  const CompactResult({
    required this.amount,
    required this.unit,
    this.currency,
  });

  /// Normalized numeric amount, optionally rounded.
  final num amount;

  /// Financial unit used to normalize [amount].
  final CompactUnit unit;

  /// Unmodified currency identifier, or null when absent.
  final String? currency;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompactResult &&
          amount == other.amount &&
          unit == other.unit &&
          currency == other.currency;

  @override
  int get hashCode => Object.hash(amount, unit, currency);

  @override
  String toString() =>
      'CompactResult(amount: $amount, unit: $unit, currency: $currency)';
}
