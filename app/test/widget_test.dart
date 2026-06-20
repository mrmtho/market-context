import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:market_context/app.dart';
import 'package:market_context/data/local/local_store.dart';
import 'package:market_context/data/providers/providers.dart';
import 'package:market_context/data/api/market_api.dart';
import 'package:market_context/ui/components/mc_chip.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences sharedPrefs;
  late LocalStore localStore;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPrefs = await SharedPreferences.getInstance();
    localStore = LocalStore(sharedPrefs);
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        localStoreProvider.overrideWithValue(localStore),
        marketApiProvider.overrideWithValue(
          MockMarketApi(failureRate: 0.0, latency: Duration.zero),
        ),
      ],
      child: const MarketContextApp(),
    );
  }

  void ignoreOverflowErrors() {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.toString().contains('overflowed')) {
        return; // Ignore layout overflows in tests
      }
      originalOnError?.call(details);
    };
  }

  testWidgets('AppShell switches navigation based on screen size', (tester) async {
    ignoreOverflowErrors();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // 1. Desktop layout
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Verify desktop sidebar search element is present
    expect(find.text('Search markets'), findsOneWidget);
    // Design System link in the footer should be visible on desktop sidebar
    expect(find.text('Design System'), findsOneWidget);

    // 2. Mobile layout
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Desktop search bar should be hidden
    expect(find.text('Search markets'), findsNothing);
    // Mobile bottom bar short labels should be visible
    expect(find.text('Watch'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
  });

  testWidgets('Search overlay can be opened and closed', (tester) async {
    ignoreOverflowErrors();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Click search box to trigger search overlay
    await tester.tap(find.text('Search markets'));
    await tester.pumpAndSettle();

    // Verify search overlay hint text is displayed
    expect(find.text('Search ticker, company, sector…'), findsOneWidget); // This is in search overlay

    // Verify filter chips exist in overlay
    expect(find.widgetWithText(MCChip, 'Stock'), findsOneWidget);
    expect(find.widgetWithText(MCChip, 'Crypto'), findsOneWidget);

    // Close search overlay by sending escape key
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();

    // Overlay should be gone
    expect(find.text('Search ticker, company, sector…'), findsNothing);
  });

  testWidgets('AssetDashboardScreen displays V2 details (Context Score, AI Summary, Overlays)', (tester) async {
    ignoreOverflowErrors();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createTestableWidget());
    await tester.pumpAndSettle();

    // Open search overlay and search for NVDA
    await tester.tap(find.text('Search markets'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'NVDA');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    // Click the NVDA result row to navigate to dashboard
    await tester.tap(find.textContaining('NVIDIA Corporation'));
    await tester.pumpAndSettle();

    // Verify Context Score is displayed
    expect(find.text('CONTEXT SCORE'), findsOneWidget);
    expect(find.textContaining('/100'), findsOneWidget);

    // Verify AI Summary card is displayed
    expect(find.text('AI SUMMARY'), findsOneWidget);

    // Verify Background Overlay chips are displayed
    expect(find.text('BACKGROUND OVERLAY'), findsOneWidget);
    expect(find.widgetWithText(MCChip, 'Fed Rate'), findsOneWidget);
    expect(find.widgetWithText(MCChip, 'Inflation'), findsOneWidget);
  });
}
