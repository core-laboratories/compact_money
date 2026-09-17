import 'compact_options.dart';
import 'compact_result.dart';
import 'compact_unit.dart';
import 'rounding.dart';
import 'precision.dart';
import 'units.dart';

/// Compacts a finite amount using powers of 1,000, capped at trillion (T).
///
/// Without rounding, uses the largest exact unit within the decimal limit
/// (default 0), falling back to the unchanged base amount when necessary.
/// With rounding, uses half-to-even at the given decimals or financial precision.
/// Rounded values of 1,000 promote to the next unit. Currency is metadata.
/// Throws [ArgumentError] for non-finite amounts, blank currency identifiers,
/// or decimal limits outside 0 through 100.
CompactResult compact(CompactOptions options) {
  final amount = options.amount;
  final currency = options.currency;
  final decimals = options.decimals;
  if (!amount.isFinite) {
    throw ArgumentError.value(amount, 'amount', 'must be finite');
  }
  if (currency != null && currency.trim().isEmpty) {
    throw ArgumentError.value(currency, 'currency', 'must be non-empty');
  }
  if (decimals != null && (decimals < 0 || decimals > 100)) {
    throw ArgumentError.value(
      decimals,
      'decimals',
      'must be between 0 and 100',
    );
  }
  var index = 0;
  while (index < divisors.length - 1 && amount.abs() >= divisors[index + 1]) {
    index++;
  }
  if (!options.allowRounding) {
    final places = decimalPlaces(amount);
    while (index > 0 && places + index * 3 > (decimals ?? 0)) {
      index--;
    }
  }
  num normalized = index == 0 ? amount : amount / divisors[index];
  if (options.allowRounding) {
    normalized = decimals == null
        ? financialRound(normalized)
        : roundHalfEven(normalized, decimals);
    while (normalized.abs() >= 1000 && index < divisors.length - 1) {
      index++;
      normalized = decimals == null
          ? financialRound(normalized / 1000)
          : roundHalfEven(normalized / 1000, decimals);
    }
  }
  return CompactResult(
    amount: cleanNumber(normalized),
    unit: CompactUnit.values[index],
    currency: currency,
  );
}

/// Alias wrapper for [compact], with identical rounding and currency behavior.
CompactResult compactAmount(CompactOptions options) => compact(options);
