#!/usr/bin/env bash
set -euo pipefail
package_root="$(cd "$(dirname "$0")/.." && pwd)"
smoke_dir="$(mktemp -d)"
trap 'rm -rf "$smoke_dir"' EXIT
mkdir -p "$smoke_dir/test"
cat > "$smoke_dir/pubspec.yaml" <<YAML
name: compact_money_flutter_smoke
publish_to: none
environment:
  sdk: '>=3.10.0 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  compact_money:
    path: "$package_root"
dev_dependencies:
  flutter_test:
    sdk: flutter
YAML
cat > "$smoke_dir/test/compact_money_test.dart" <<'DART'
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:compact_money/compact_money.dart';

void main() {
  testWidgets('renders a compact result in Flutter', (tester) async {
    final result = compact(const CompactOptions(amount: 30487, currency: 'VND'));
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Text('${result.amount}${result.unit.symbol} ${result.currency}'),
    ));
    expect(find.text('30487 VND'), findsOneWidget);
  });
}
DART
cd "$smoke_dir"
flutter pub get
flutter test
