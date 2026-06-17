// Smoke test placeholder — comprehensive tests live alongside (Feature 19).
import 'package:flutter_test/flutter_test.dart';

import 'package:market_context/data/mock/mock_market_data.dart';

void main() {
  test('mock market data exposes a non-empty asset catalogue', () {
    expect(MockMarketData.instance.assets, isNotEmpty);
  });
}
