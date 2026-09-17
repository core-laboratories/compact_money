# Compact Money

Compact monetary amounts into structured amount, unit and optional currency data.
Pure Dart with no runtime dependencies or Flutter API imports; usable in Flutter
on Android, iOS, web, Windows, macOS and Linux, and in Dart CLI/server applications.
The companion [TypeScript package](https://github.com/core-laboratories/compact-money)
uses the same numeric policy and shared test examples.

## Installation

```sh
dart pub add compact_money
# For Flutter applications:
flutter pub add compact_money
```

Requires Dart 3.10 or newer (below 4.0). There is no separate Flutter version
constraint; use a Flutter release that includes a compatible Dart SDK.

## Usage

```dart
import 'package:compact_money/compact_money.dart';

void main() {
  final result = compact(const CompactOptions(amount: 80000, currency: 'VND'));
  print(result.amount);      // 80
  print(result.unit.symbol); // k
  print(result.currency);    // VND

  final precise = compact(const CompactOptions(
    amount: 8123456,
    currency: 'VND',
  ));
  print(precise.amount); // 8123456 (base unit)

  final exact = compact(const CompactOptions(amount: 8123000));
  print(exact.amount);      // 8123
  print(exact.unit.symbol); // k

  final withDecimals = compact(const CompactOptions(amount: 8123000, decimals: 3));
  print(withDecimals.amount);      // 8.123
  print(withDecimals.unit.symbol); // M

  final rounded = compact(const CompactOptions(
    amount: 30487,
    currency: 'VND',
    allowRounding: true,
  ));
  print(rounded.amount); // 30.5
}
```

Run the examples with `dart run example/compact_money_example.dart`.

## API

- `CompactResult compact(CompactOptions options)` is the primary function.
- `compactAmount(CompactOptions options)` delegates to the same implementation.
- `CompactOptions({required num amount, String? currency, bool allowRounding = false, int? decimals})`
  accepts both integers and doubles.
- `CompactResult({required num amount, required CompactUnit unit, String? currency})`
  has value equality, a compatible hash code and a debugging `toString()`.
- `CompactUnit` contains `none`, `thousand`, `million`, `billion`, and `trillion`.
- `CompactUnitValue` exposes the `.symbol` getter shown in the table below.

Both model classes have final fields and const constructors. No input is mutated.
Absent currency is `null`. Non-finite amounts (NaN and either infinity) and blank
currency identifiers or decimal limits outside 0–100 throw `ArgumentError`. The debugging string is not a
financial formatting API. Whole results are returned as integers where safely
representable across both VM and web; callers should use the public `num` type.

## Units and rounding

Units are selected using the absolute input and preserve its sign. Without
rounding, the largest unit that fits within `decimals` is selected, defaulting
to zero decimal places. With rounding, the largest unit based on magnitude is
selected first. Currency never participates in the calculation.

| Symbol | Divisor | Dart unit |
| --- | ---: | --- |
| `""` | 1 | `CompactUnit.none` |
| `k` | 1,000 | `CompactUnit.thousand` |
| `M` | 1,000,000 | `CompactUnit.million` |
| `B` | 1,000,000,000 | `CompactUnit.billion` |
| `T` | 1,000,000,000,000 | `CompactUnit.trillion` |

Rounding is disabled by default. Set `allowRounding: true` to enable half-to-even
rounding. If `decimals` is supplied, it sets the maximum decimal places. Otherwise,
the existing financial policy uses the absolute normalized amount:

| Magnitude | Maximum decimal places |
| --- | ---: |
| Less than 10 | 2 |
| Less than 100 | 1 |
| 100 or more | 0 |

This yields approximately three significant digits in the usual compact range,
not a general significant-digit formatter: small values can round to zero, and
amounts above 999 T retain more than three digits.

Midpoints use **round-half-to-even** (banker's rounding). At zero decimal places,
2.5 rounds to 2 and 3.5 to 4; at two places, 1.245 rounds to 1.24 and 1.255 to 1.26.
These examples describe the rounding primitive; with `allowRounding: true`,
`compact` chooses decimal places
using the table when `decimals` is omitted (so an input of 2.5 remains 2.5). The implementation explicitly
compares the fractional part with one half; it does not delegate midpoint decisions
to string formatting. A tolerance of twice machine epsilon times the scaled
magnitude, capped at 0.0000001, treats tiny binary midpoint errors as ties.
Values within that tolerance can therefore round as a midpoint.

With rounding enabled, if rounding reaches 1,000, the unit is promoted and rounding applied again:
999,999 becomes 1 M; 999,999,999 becomes 1 B; 999,999,999,999 becomes 1 T.
The same applies from base units to k. T is the ceiling: 1,500,000,000,000,000
becomes 1,500 T. Negative values use the same rules symmetrically. Zero always
uses the base unit, and negative zero is normalized to positive zero.

| Input | Rounded amount | Unit |
| ---: | ---: | --- |
| 800 | 800 | `""` |
| 30,487 | 30.5 | k |
| 80,000 | 80 | k |
| 812,345 | 812 | k |
| 8,123,456 | 8.12 | M |
| 81,234,567 | 81.2 | M |
| 812,345,678 | 812 | M |
| -30,487 | -30.5 | k |

## Decimal places without rounding

`decimals` is an optional integer from 0 to 100. When rounding is disabled,
its default is **0**. It limits unit selection, not the original amount's precision:
the library tries smaller units until the normalized amount fits exactly within
the requested decimal places. If no compact unit fits, the original amount is
returned unchanged with the base unit, even if it has more decimal places.
There is no truncation, rounding, or padding with trailing zeroes.

| Input | `decimals` | Amount | Unit |
| ---: | ---: | ---: | --- |
| 8,123,456 | omitted (0) | 8123456 | `""` |
| 8,123,000 | omitted (0) | 8123 | k |
| 8,000,000 | omitted (0) | 8 | M |
| 8,123,000 | 2 | 8123 | k |
| 8,123,000 | 3 | 8.123 | M |
| 8,123,456 | 3 | 8123.456 | k |
| 8,123,456 | 6 | 8.123456 | M |
| 1.23456 | 2 | 1.23456 | `""` |

For comparison, `allowRounding: true, decimals: 2` converts 8,123,456 to 8.12 M.
`allowRounding: true, decimals: 0` converts it to 8 M. Negative values behave
symmetrically in both modes.

Exact unit eligibility is determined from the input number's shortest decimal
representation, including scientific notation and trailing zeroes. This avoids
mistaking a division artifact for intentional precision. The returned amount is
still a numeric value and remains subject to floating-point limitations.

## Currency and presentation

Currency is optional metadata. There is no ISO 4217 lookup or currency database.
VND, LAK, IDR, KRW, JPY, EUR, USD, CZK, CSK, USDC, USDT, BTC, ETH, CORE and custom
identifiers all work. Empty and whitespace-only strings are rejected; valid
identifiers are preserved exactly, including case and surrounding whitespace.

The application decides how to show the separate values: `30.5k VND`,
`VND 30.5k`, `₫30.5k` or `30.5k ₫`. This library does not choose currency symbols,
locale, symbol placement, thousands separators or decimal separators.

## Numeric precision

IEEE-754 binary floating point cannot exactly represent every decimal fraction.
Normalization can introduce small errors even when rounding is disabled. The
midpoint tolerance mitigates common errors but does not provide exact decimal
arithmetic. Values too large to retain a fractional part are returned without
additional rounding. Finite values above the T range remain supported.

This package provides display-oriented numeric representations, not accounting
or bookkeeping arithmetic. Use an appropriate exact-decimal approach for those
calculations before passing a display amount to this package. Numeric results
do not retain formatting such as trailing decimal zeroes.

Dart `double` uses IEEE-754. Native Dart integers and web numeric representations
have different precision limits; division can convert an integer to a double.
Parity with TypeScript applies to equivalent representable inputs, not integers
that JavaScript has already rounded beyond its safe range (2⁵³ − 1).

## Development and releases

```sh
dart pub get
dart format --output=none --set-exit-if-changed .
dart analyze --fatal-infos
dart test
dart pub publish --dry-run
bash tool/flutter_smoke.sh
```

CI checks minimum and stable Dart, compiles the example to JavaScript, and runs
a Flutter widget integration test. See [CONTRIBUTING.md](https://github.com/core-laboratories/compact_money/blob/main/CONTRIBUTING.md) for
release setup and fixture maintenance.

## License

[CORE License](LICENSE), matching the CORE libraries.
