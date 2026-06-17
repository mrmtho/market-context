import 'package:flutter/material.dart';

/// Top-level navigation destinations (Feature 1, task 17).
class NavItem {
  const NavItem({
    required this.label,
    required this.shortLabel,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final String shortLabel;
  final IconData icon;
  final IconData selectedIcon;
  final String location;
}

class AppDestinations {
  AppDestinations._();

  static const explore = NavItem(
    label: 'Explore',
    shortLabel: 'Explore',
    icon: Icons.travel_explore_outlined,
    selectedIcon: Icons.travel_explore_rounded,
    location: '/',
  );

  static const compare = NavItem(
    label: 'Compare',
    shortLabel: 'Compare',
    icon: Icons.compare_arrows_outlined,
    selectedIcon: Icons.compare_arrows_rounded,
    location: '/compare',
  );

  static const watchlist = NavItem(
    label: 'Watchlist',
    shortLabel: 'Watch',
    icon: Icons.star_outline_rounded,
    selectedIcon: Icons.star_rounded,
    location: '/watchlist',
  );

  static const insights = NavItem(
    label: 'Saved Insights',
    shortLabel: 'Saved',
    icon: Icons.bookmark_outline_rounded,
    selectedIcon: Icons.bookmark_rounded,
    location: '/saved',
  );

  static const settings = NavItem(
    label: 'Settings',
    shortLabel: 'Menu',
    icon: Icons.tune_outlined,
    selectedIcon: Icons.tune_rounded,
    location: '/settings',
  );

  /// Primary rail destinations (desktop sidebar + tablet top nav).
  static const List<NavItem> primary = [
    explore,
    watchlist,
    compare,
    insights,
    settings,
  ];

  /// Mobile bottom-bar destinations (max 5, search is a dedicated tab).
  static const List<NavItem> mobile = [
    explore,
    watchlist,
    compare,
    insights,
    settings,
  ];

  /// Best-effort index of the currently-active destination for a location.
  static int indexForLocation(String location, List<NavItem> items) {
    // Longest-prefix match so nested routes still highlight their parent.
    var best = 0;
    var bestLen = -1;
    for (var i = 0; i < items.length; i++) {
      final loc = items[i].location;
      final matches = loc == '/'
          ? location == '/'
          : location.startsWith(loc);
      if (matches && loc.length > bestLen) {
        best = i;
        bestLen = loc.length;
      }
    }
    return best;
  }
}
