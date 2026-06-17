import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/models/enums.dart';
import 'data/providers/preferences_controller.dart';
import 'routing/app_router.dart';

/// Root application widget. Wires the router and reacts to the theme
/// preference (Feature 17, task 11).
class MarketContextApp extends ConsumerWidget {
  const MarketContextApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      preferencesProvider.select((p) => p.themeMode),
    );

    return MaterialApp.router(
      title: 'Market Context',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode:
          themeMode == AppThemeMode.dark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: appRouter,
    );
  }
}
