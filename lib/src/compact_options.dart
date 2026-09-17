/// Immutable input. Currency is metadata; financial rounding defaults to false.
class CompactOptions {
  /// Creates options for structured monetary compaction.
  const CompactOptions({
    required this.amount,
    this.currency,
    this.allowRounding = false,
    this.decimals,
  });

  /// Finite input amount, positive, negative or zero.
  final num amount;

  /// Optional non-blank identifier, preserved exactly without ISO validation.
  final String? currency;

  /// Whether to apply half-to-even rounding after normalization.
  final bool allowRounding;

  /// Maximum decimal places, from 0 through 100.
  /// Defaults to 0 without rounding, or financial precision with rounding.
  /// Without rounding this limits unit selection; base amounts stay unchanged.
  final int? decimals;
}
