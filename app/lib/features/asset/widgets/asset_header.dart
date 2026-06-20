import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/layout/breakpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/asset.dart';
import '../../../data/providers/watchlist_controller.dart';
import '../../../ui/components/asset_avatar.dart';
import '../../../ui/components/change_indicator.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/components/mc_badge.dart';
import '../../../ui/components/mc_button.dart';

class AssetHeader extends ConsumerWidget {
  const AssetHeader({
    super.key,
    required this.overview,
    required this.currency,
    this.onShare,
  });

  final AssetOverview overview;
  final String currency;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final a = overview.asset;
    final watched = ref.watch(
      watchlistProvider.select((list) => list.any((e) => e.assetId == a.id)),
    );
    final isMobile = context.isMobile;

    final identity = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AssetAvatar(asset: a, size: isMobile ? 48 : 56),
        AppSpacing.hGapLg,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(a.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(a.ticker,
                      style: AppTypography.mono(
                          size: 14,
                          weight: FontWeight.w700,
                          color: AppColors.accentCyan)),
                  MCBadge(label: a.assetType.label, color: AppColors.accentViolet),
                  MCBadge(label: a.exchange, color: AppColors.neutral),
                  if (a.sector != null)
                    MCBadge(label: a.sector!, color: AppColors.accentTeal),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MCSecondaryButton(
          label: watched ? 'Watching' : 'Watch',
          icon: watched ? Icons.star_rounded : Icons.star_outline_rounded,
          accent: watched ? AppColors.warning : AppColors.textPrimary,
          size: MCButtonSize.small,
          onPressed: () {
            ref.read(watchlistProvider.notifier).toggle(a);
          },
        ),
        AppSpacing.hGapSm,
        MCIconButton(
          icon: Icons.ios_share_rounded,
          tooltip: 'Save insight',
          onPressed: onShare,
        ),
      ],
    );

    final priceBlock = _PriceBlock(overview: overview, currency: currency);

    return GlassContainer(
      glow: AppColors.accentCyan,
      padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                AppSpacing.vGapLg,
                priceBlock,
                AppSpacing.vGapLg,
                Align(alignment: Alignment.centerLeft, child: actions),
                AppSpacing.vGapLg,
                _AiSummaryCard(summary: overview.contextSummary),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: identity),
                    AppSpacing.hGapLg,
                    actions,
                  ],
                ),
                AppSpacing.vGapXl,
                priceBlock,
                AppSpacing.vGapLg,
                _AiSummaryCard(summary: overview.contextSummary),
              ],
            ),
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.overview, required this.currency});
  final AssetOverview overview;
  final String currency;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.xl,
      runSpacing: AppSpacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(Fmt.priceExact(overview.price, currency: currency),
                style: AppTypography.mono(size: 40, weight: FontWeight.w700)),
            const SizedBox(height: 6),
            ChangeIndicator(
              percent: overview.changePercent,
              absolute: overview.changeAbsolute,
              currency: currency,
              size: 14,
              pill: true,
            ),
          ],
        ),
        _ContextScoreStat(score: overview.contextScore),
        _MarketStatus(open: overview.marketOpen, asOf: overview.asOf),
        _MiniStat(label: 'Day Range',
            value: '${Fmt.compact(overview.dayLow)} – ${Fmt.compact(overview.dayHigh)}'),
        _MiniStat(label: 'Prev Close', value: Fmt.priceExact(overview.previousClose, currency: currency)),
        _MiniStat(label: 'Market Cap', value: Fmt.compactCurrency(overview.marketCap, currency: currency)),
        _MiniStat(label: 'Volume', value: Fmt.compact(overview.volume)),
      ],
    );
  }
}

class _ContextScoreStat extends StatelessWidget {
  const _ContextScoreStat({required this.score});
  final double score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accentViolet.withValues(alpha: 0.1),
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.accentViolet.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('CONTEXT SCORE', style: AppTypography.eyebrow(color: AppColors.accentViolet)),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.hub_rounded, size: 16, color: AppColors.accentViolet),
              const SizedBox(width: 6),
              Text(
                '${score.toStringAsFixed(0)}/100',
                style: AppTypography.mono(size: 15, weight: FontWeight.w700, color: AppColors.accentViolet),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiSummaryCard extends StatelessWidget {
  const _AiSummaryCard({required this.summary});
  final String summary;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accentCyan.withValues(alpha: 0.08),
            AppColors.accentViolet.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.borderStrong),
        boxShadow: [
          BoxShadow(
            color: AppColors.accentCyan.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.accentCyan),
              const SizedBox(width: 8),
              Text(
                'AI SUMMARY',
                style: AppTypography.eyebrow(color: AppColors.accentCyan),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

class _MarketStatus extends StatelessWidget {
  const _MarketStatus({required this.open, required this.asOf});
  final bool open;
  final DateTime asOf;

  @override
  Widget build(BuildContext context) {
    final color = open ? AppColors.positive : AppColors.neutral;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.7), blurRadius: 8)],
              ),
            ),
            AppSpacing.hGapSm,
            Text(open ? 'Market Open' : 'Market Closed',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 4),
        Text('As of ${Fmt.date(asOf)}',
            style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: AppTypography.eyebrow()),
        const SizedBox(height: 4),
        Text(value, style: AppTypography.mono(size: 14, weight: FontWeight.w600)),
      ],
    );
  }
}
