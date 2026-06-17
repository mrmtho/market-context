import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/asset/asset_dashboard_screen.dart';
import '../features/asset/context_detail_screen.dart';
import '../features/compare/compare_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_list_screen.dart';
import '../features/insights/shared_insight_screen.dart';
import '../features/scenario/scenario_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/showcase/showcase_screen.dart';
import '../features/watchlist/watchlist_screen.dart';

/// A page with a soft fade + lift transition (Feature 1, task 13).
CustomTransitionPage<void> _fadePage({
  required Widget child,
  required GoRouterState state,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 280),
    child: child,
    transitionsBuilder: (_, animation, _, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.015), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (c, s) => _fadePage(child: const HomeScreen(), state: s),
        ),
        GoRoute(
          path: '/compare',
          pageBuilder: (c, s) =>
              _fadePage(child: const CompareScreen(), state: s),
        ),
        GoRoute(
          path: '/watchlist',
          pageBuilder: (c, s) =>
              _fadePage(child: const WatchlistScreen(), state: s),
        ),
        GoRoute(
          path: '/saved',
          pageBuilder: (c, s) =>
              _fadePage(child: const InsightsListScreen(), state: s),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (c, s) =>
              _fadePage(child: const SettingsScreen(), state: s),
        ),
        GoRoute(
          path: '/showcase',
          pageBuilder: (c, s) =>
              _fadePage(child: const ShowcaseScreen(), state: s),
        ),
        GoRoute(
          path: '/insights/:id',
          pageBuilder: (c, s) => _fadePage(
            child: SharedInsightScreen(insightId: s.pathParameters['id']!),
            state: s,
          ),
        ),
        GoRoute(
          path: '/asset/:symbol',
          pageBuilder: (c, s) => _fadePage(
            child: AssetDashboardScreen(symbol: s.pathParameters['symbol']!),
            state: s,
          ),
          routes: [
            GoRoute(
              path: 'context/:date',
              pageBuilder: (c, s) => _fadePage(
                child: ContextDetailScreen(
                  symbol: s.pathParameters['symbol']!,
                  dateIso: s.pathParameters['date']!,
                ),
                state: s,
              ),
            ),
            GoRoute(
              path: 'scenario',
              pageBuilder: (c, s) => _fadePage(
                child: ScenarioScreen(symbol: s.pathParameters['symbol']!),
                state: s,
              ),
            ),
          ],
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri}')),
  ),
);
