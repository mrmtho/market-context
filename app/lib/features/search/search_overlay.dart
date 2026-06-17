import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/layout/breakpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../data/models/asset.dart';
import '../../data/models/enums.dart';
import '../../data/providers/search_controller.dart';
import '../../ui/components/asset_avatar.dart';
import '../../ui/components/change_indicator.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/mc_badge.dart';
import '../../ui/components/mc_chip.dart';
import '../../ui/components/status_views.dart';

/// Opens the universal asset search as a top-anchored overlay (Feature 2).
Future<void> showSearchOverlay(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Search',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => const SearchOverlay(),
    transitionBuilder: (_, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, -0.03), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

class SearchOverlay extends ConsumerStatefulWidget {
  const SearchOverlay({super.key});

  @override
  ConsumerState<SearchOverlay> createState() => _SearchOverlayState();
}

class _SearchOverlayState extends ConsumerState<SearchOverlay> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  int _highlighted = 0;

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _open(AssetSearchResult r) {
    ref.read(recentSearchesProvider.notifier).add(r.asset.ticker);
    ref.read(analyticsProvider).log(AnalyticsEvents.assetOpened, {
      'ticker': r.asset.ticker,
      'from': 'search',
    });
    Navigator.of(context).pop();
    context.go('/asset/${r.asset.ticker}');
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event, List<AssetSearchResult> results) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      Navigator.of(context).maybePop();
      return KeyEventResult.handled;
    }
    if (results.isEmpty) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlighted = (_highlighted + 1) % results.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() =>
          _highlighted = (_highlighted - 1 + results.length) % results.length);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _open(results[_highlighted.clamp(0, results.length - 1)]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchControllerProvider);
    final recents = ref.watch(recentSearchesProvider);
    final filters = ref.watch(searchFilterProvider);
    final isMobile = context.isMobile;

    final list = results.maybeWhen(
      data: (d) => d,
      orElse: () => const <AssetSearchResult>[],
    );
    if (_highlighted >= list.length) _highlighted = 0;

    return Align(
      alignment: isMobile ? Alignment.topCenter : Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(
          top: isMobile ? 0 : 72,
          left: isMobile ? 0 : 24,
          right: isMobile ? 0 : 24,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 680,
            maxHeight: isMobile
                ? MediaQuery.sizeOf(context).height
                : MediaQuery.sizeOf(context).height * 0.74,
          ),
          child: Focus(
            autofocus: true,
            onKeyEvent: (n, e) => _onKey(n, e, list),
            child: Material(
              type: MaterialType.transparency,
              child: GlassContainer(
                padding: EdgeInsets.zero,
                blur: 30,
                fillOpacity: 0.06,
                borderColor: AppColors.borderStrong,
                borderRadius: isMobile
                    ? BorderRadius.zero
                    : const BorderRadius.all(AppRadii.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInput(isMobile),
                    _buildFilters(filters),
                    const Divider(height: 1),
                    Flexible(
                      child: _buildBody(results, list, recents),
                    ),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput(bool isMobile) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpacing.lg, isMobile ? AppSpacing.xl : AppSpacing.lg, AppSpacing.md, AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.accentCyan, size: 22),
          AppSpacing.hGapMd,
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focus,
              autofocus: true,
              style: Theme.of(context).textTheme.titleMedium,
              cursorColor: AppColors.accentCyan,
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: 'Search ticker, company, sector…',
                hintStyle: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: AppColors.textTertiary),
              ),
              onChanged: (v) {
                ref.read(searchControllerProvider.notifier).updateQuery(v);
                setState(() => _highlighted = 0);
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              onPressed: () {
                _controller.clear();
                ref.read(searchControllerProvider.notifier).clear();
                setState(() {});
              },
            ),
          if (isMobile)
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Cancel'),
            ),
        ],
      ),
    );
  }

  Widget _buildFilters(Set<AssetType> filters) {
    const types = [
      AssetType.stock,
      AssetType.etf,
      AssetType.crypto,
      AssetType.commodity,
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Wrap(
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.sm,
        children: [
          for (final t in types)
            MCChip(
              label: t.label,
              icon: t.icon,
              selected: filters.contains(t),
              onTap: () {
                final next = {...filters};
                next.contains(t) ? next.remove(t) : next.add(t);
                ref.read(searchFilterProvider.notifier).state = next;
                ref.read(searchControllerProvider.notifier).reapplyFilters();
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AsyncValue<List<AssetSearchResult>> results,
      List<AssetSearchResult> list, List<String> recents) {
    final query = ref.read(searchControllerProvider.notifier).query;

    if (query.trim().isEmpty) {
      return _buildRecents(recents);
    }
    return results.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: ErrorStateView(
          title: 'Search failed',
          message: e.toString(),
          compact: true,
          onRetry: () =>
              ref.read(searchControllerProvider.notifier).updateQuery(query),
        ),
      ),
      data: (data) {
        if (data.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 28),
            child: EmptyStateView(
              icon: Icons.search_off_rounded,
              title: 'No matches',
              message: 'Try a ticker like NVDA, a name like Apple, or a sector.',
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          itemCount: data.length,
          itemBuilder: (_, i) => _ResultRow(
            result: data[i],
            highlighted: i == _highlighted,
            onTap: () => _open(data[i]),
            onHover: () => setState(() => _highlighted = i),
          ),
        );
      },
    );
  }

  Widget _buildRecents(List<String> recents) {
    if (recents.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: EmptyStateView(
          icon: Icons.bolt_rounded,
          title: 'Search the market',
          message: 'Find any asset and see the full context behind its price.',
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text('RECENT', style: AppTypography.eyebrow()),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: const Text('Clear'),
              ),
            ],
          ),
          AppSpacing.vGapSm,
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              for (final r in recents)
                MCChip(
                  label: r,
                  icon: Icons.history_rounded,
                  onTap: () {
                    _controller.text = r;
                    ref.read(searchControllerProvider.notifier).updateQuery(r);
                    setState(() {});
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _kbd('↑'),
          _kbd('↓'),
          const SizedBox(width: 6),
          Text('navigate', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 16),
          _kbd('↵'),
          const SizedBox(width: 6),
          Text('open', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: 16),
          _kbd('esc'),
          const SizedBox(width: 6),
          Text('close', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }

  Widget _kbd(String key) => Container(
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.glassFill,
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(key,
            style: AppTypography.mono(size: 10, color: AppColors.textSecondary)),
      );
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.result,
    required this.highlighted,
    required this.onTap,
    required this.onHover,
  });

  final AssetSearchResult result;
  final bool highlighted;
  final VoidCallback onTap;
  final VoidCallback onHover;

  @override
  Widget build(BuildContext context) {
    final a = result.asset;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => onHover(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            color: highlighted ? AppColors.glassFillStrong : Colors.transparent,
            borderRadius: AppRadii.brMd,
            border: Border.all(
              color: highlighted ? AppColors.borderStrong : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              AssetAvatar(asset: a, size: 40),
              AppSpacing.hGapMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(a.ticker,
                            style: Theme.of(context).textTheme.titleMedium),
                        AppSpacing.hGapSm,
                        MCBadge(label: a.assetType.label, color: AppColors.accentViolet),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${a.displayName} · ${a.exchange}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              AppSpacing.hGapMd,
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('\$${result.lastPrice.toStringAsFixed(2)}',
                      style: AppTypography.mono(size: 14, weight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  ChangeIndicator(percent: result.changePercent, size: 11),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
