import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../routing/nav_items.dart';
import '../../ui/components/glass_container.dart';
import '../search/search_overlay.dart';
import 'app_background.dart';
import 'brandmark.dart';

/// The responsive frame around every routed page (Feature 1).
///
/// - Desktop/wide → persistent left sidebar.
/// - Tablet       → top navigation bar.
/// - Mobile       → bottom navigation bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final device = context.device;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppBackground(
        child: switch (device) {
          DeviceClass.mobile => _MobileScaffold(location: location, child: child),
          DeviceClass.tablet => _TabletScaffold(location: location, child: child),
          _ => _DesktopScaffold(location: location, child: child),
        },
      ),
    );
  }
}

void _go(BuildContext context, String location) {
  if (GoRouterState.of(context).uri.path != location) context.go(location);
}

// ---------------------------------------------------------------------------
// Desktop
// ---------------------------------------------------------------------------

class _DesktopScaffold extends StatelessWidget {
  const _DesktopScaffold({required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final activeIndex =
        AppDestinations.indexForLocation(location, AppDestinations.primary);
    return Row(
      children: [
        Container(
          width: 256,
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.md, AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(left: AppSpacing.sm),
                child: Brandmark(),
              ),
              AppSpacing.vGapXl,
              const _SearchButton(),
              AppSpacing.vGapLg,
              for (var i = 0; i < AppDestinations.primary.length; i++)
                _SidebarTile(
                  item: AppDestinations.primary[i],
                  active: i == activeIndex,
                  onTap: () => _go(context, AppDestinations.primary[i].location),
                ),
              const Spacer(),
              const _SidebarFooter(),
            ],
          ),
        ),
        Expanded(
          child: ClipRect(
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.lg, bottom: AppSpacing.lg),
              child: child,
            ),
          ),
        ),
      ],
    );
  }
}

class _SidebarTile extends StatefulWidget {
  const _SidebarTile({required this.item, required this.active, required this.onTap});
  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          decoration: BoxDecoration(
            color: active
                ? AppColors.accentCyan.withValues(alpha: 0.12)
                : _hover
                    ? AppColors.glassFill
                    : Colors.transparent,
            borderRadius: AppRadii.brMd,
            border: Border.all(
              color: active ? AppColors.accentCyan.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                active ? widget.item.selectedIcon : widget.item.icon,
                size: 20,
                color: active ? AppColors.accentCyan : AppColors.textSecondary,
              ),
              AppSpacing.hGapMd,
              Text(
                widget.item.label,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                  color: active ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
              const Spacer(),
              if (active)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.accentCyan,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: AppColors.cyanGlow, blurRadius: 8),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        AppSpacing.vGapSm,
        TextButton.icon(
          onPressed: () => _go(context, '/showcase'),
          icon: const Icon(Icons.palette_outlined, size: 17),
          label: const Text('Design System'),
          style: TextButton.styleFrom(foregroundColor: AppColors.textTertiary),
        ),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.sm, top: 6),
          child: Text('Mocked data · for demo',
              style: Theme.of(context).textTheme.labelSmall),
        ),
      ],
    );
  }
}

class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      onTap: () => showSearchOverlay(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: AppRadii.brMd,
      child: Row(
        children: [
          const Icon(Icons.search_rounded, size: 18, color: AppColors.accentCyan),
          AppSpacing.hGapMd,
          Text('Search markets',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              border: Border.all(color: AppColors.border),
            ),
            child: Text('/', style: AppTypography.mono(size: 11, color: AppColors.textTertiary)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tablet
// ---------------------------------------------------------------------------

class _TabletScaffold extends StatelessWidget {
  const _TabletScaffold({required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final activeIndex =
        AppDestinations.indexForLocation(location, AppDestinations.primary);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            borderRadius: AppRadii.brLg,
            child: Row(
              children: [
                const Brandmark(),
                const Spacer(),
                for (var i = 0; i < AppDestinations.primary.length; i++)
                  _TopNavTile(
                    item: AppDestinations.primary[i],
                    active: i == activeIndex,
                    onTap: () => _go(context, AppDestinations.primary[i].location),
                  ),
                AppSpacing.hGapMd,
                IconButton(
                  onPressed: () => showSearchOverlay(context),
                  icon: const Icon(Icons.search_rounded),
                  color: AppColors.accentCyan,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: child,
          ),
        ),
      ],
    );
  }
}

class _TopNavTile extends StatelessWidget {
  const _TopNavTile({required this.item, required this.active, required this.onTap});
  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: TextButton.icon(
        onPressed: onTap,
        icon: Icon(active ? item.selectedIcon : item.icon, size: 18),
        label: Text(item.label),
        style: TextButton.styleFrom(
          foregroundColor: active ? AppColors.accentCyan : AppColors.textSecondary,
          backgroundColor:
              active ? AppColors.accentCyan.withValues(alpha: 0.1) : null,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile
// ---------------------------------------------------------------------------

class _MobileScaffold extends StatelessWidget {
  const _MobileScaffold({required this.location, required this.child});
  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final activeIndex =
        AppDestinations.indexForLocation(location, AppDestinations.mobile);
    return Column(
      children: [
        Expanded(child: child),
        _MobileBottomNav(activeIndex: activeIndex),
      ],
    );
  }
}

class _MobileBottomNav extends StatelessWidget {
  const _MobileBottomNav({required this.activeIndex});
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.sm + padding * 0.4),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs, vertical: AppSpacing.xs),
        borderRadius: AppRadii.brXl,
        blur: 26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < AppDestinations.mobile.length; i++)
              Expanded(
                child: _BottomTile(
                  item: AppDestinations.mobile[i],
                  active: i == activeIndex,
                  onTap: () => _go(context, AppDestinations.mobile[i].location),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomTile extends StatelessWidget {
  const _BottomTile({required this.item, required this.active, required this.onTap});
  final NavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? AppColors.accentCyan.withValues(alpha: 0.12) : null,
          borderRadius: AppRadii.brLg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(active ? item.selectedIcon : item.icon,
                size: 21,
                color: active ? AppColors.accentCyan : AppColors.textTertiary),
            const SizedBox(height: 3),
            Text(item.shortLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: active ? AppColors.accentCyan : AppColors.textTertiary,
                )),
          ],
        ),
      ),
    );
  }
}
