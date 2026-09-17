/// Financial powers of one thousand, capped at trillions.
enum CompactUnit {
  /// Base units (divisor 1).
  none,

  /// Thousands (divisor 1,000).
  thousand,

  /// Millions (divisor 1,000,000).
  million,

  /// Billions (divisor 1,000,000,000).
  billion,

  /// Trillions (divisor 1,000,000,000,000).
  trillion,
}

/// Display symbols for compact units, independent of currency and locale.
extension CompactUnitValue on CompactUnit {
  /// The empty string, k, M, B or T.
  String get symbol => switch (this) {
    CompactUnit.none => '',
    CompactUnit.thousand => 'k',
    CompactUnit.million => 'M',
    CompactUnit.billion => 'B',
    CompactUnit.trillion => 'T',
  };
}
