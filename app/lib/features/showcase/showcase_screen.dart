import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_typography.dart';
import '../../ui/components/change_indicator.dart';
import '../../ui/components/glass_container.dart';
import '../../ui/components/loading_skeleton.dart';
import '../../ui/components/mc_badge.dart';
import '../../ui/components/mc_button.dart';
import '../../ui/components/mc_card.dart';
import '../../ui/components/mc_chip.dart';
import '../../ui/components/metric_tile.dart';
import '../../ui/components/page_scaffold.dart';
import '../../ui/components/section_header.dart';
import '../../ui/components/sparkline.dart';
import '../../ui/components/status_views.dart';

/// Living style guide for the design system (Feature 15, task 19).
class ShowcaseScreen extends ConsumerWidget {
  const ShowcaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'Design system',
            title: 'Component showcase',
          ),
          AppSpacing.vGapLg,
          _Block(
            title: 'Color roles',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: const [
                _Swatch('Cyan', AppColors.accentCyan),
                _Swatch('Violet', AppColors.accentViolet),
                _Swatch('Teal', AppColors.accentTeal),
                _Swatch('Blue', AppColors.accentBlue),
                _Swatch('Magenta', AppColors.accentMagenta),
                _Swatch('Positive', AppColors.positive),
                _Swatch('Negative', AppColors.negative),
                _Swatch('Warning', AppColors.warning),
              ],
            ),
          ),
          _Block(
            title: 'Typography',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Display', style: Theme.of(context).textTheme.displaySmall),
                Text('Headline medium', style: Theme.of(context).textTheme.headlineMedium),
                Text('Title medium', style: Theme.of(context).textTheme.titleMedium),
                Text('Body — every price has context.',
                    style: Theme.of(context).textTheme.bodyLarge),
                Text('1,234.56 monospace figures',
                    style: AppTypography.mono(size: 16, weight: FontWeight.w600)),
              ],
            ),
          ),
          _Block(
            title: 'Buttons',
            child: Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                MCPrimaryButton(label: 'Primary', icon: Icons.bolt_rounded, onPressed: () {}),
                MCSecondaryButton(label: 'Secondary', icon: Icons.tune_rounded, onPressed: () {}),
                MCIconButton(icon: Icons.star_rounded, onPressed: () {}, active: true),
                MCIconButton(icon: Icons.share_rounded, onPressed: () {}),
              ],
            ),
          ),
          _Block(
            title: 'Chips & badges',
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                MCChip(label: '1Y', selected: true),
                MCChip(label: '5Y'),
                MCBadge(label: 'Stock', color: AppColors.accentViolet),
                MCBadge(label: 'Bullish', color: AppColors.positive, icon: Icons.trending_up_rounded),
                MCBadge(label: 'Filled', color: AppColors.accentCyan, filled: true),
              ],
            ),
          ),
          _Block(
            title: 'Change indicators & sparkline',
            child: Row(
              children: [
                const ChangeIndicator(percent: 2.41, absolute: 4.92, pill: true),
                AppSpacing.hGapLg,
                const ChangeIndicator(percent: -1.18, pill: true),
                AppSpacing.hGapLg,
                Sparkline(values: const [3, 5, 4, 6, 7, 6, 8, 9, 8, 10], width: 90),
              ],
            ),
          ),
          _Block(
            title: 'Metric tiles',
            child: Row(
              children: [
                const Expanded(
                  child: MetricTile(label: 'P/E (TTM)', value: '31.2×', help: 'Price / earnings'),
                ),
                AppSpacing.hGapMd,
                const Expanded(
                  child: MetricTile(
                      label: 'Revenue', value: r'$96.3B', sublabel: 'TTM · Reported'),
                ),
              ],
            ),
          ),
          _Block(
            title: 'Card',
            child: MCCard(
              eyebrow: 'Example',
              title: 'Glass card',
              icon: Icons.dashboard_rounded,
              child: Text('Cards use a frosted-glass surface with a hairline border.',
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
          ),
          _Block(
            title: 'Loading skeletons',
            child: const Row(
              children: [
                Expanded(child: SkeletonCard(height: 120, lines: 2)),
                SizedBox(width: AppSpacing.md),
                Expanded(child: SkeletonCard(height: 120, lines: 2)),
              ],
            ),
          ),
          _Block(
            title: 'Status views',
            child: const SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    child: EmptyStateView(
                        title: 'Empty', message: 'Nothing here yet.'),
                  ),
                  Expanded(
                    child: ErrorStateView(
                        title: 'Error', message: 'Something failed.', compact: true),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.vGapXl,
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  const _Block({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: AppTypography.eyebrow()),
            AppSpacing.vGapLg,
            child,
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.label, this.color);
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            borderRadius: AppRadii.brSm,
            boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 14, spreadRadius: -4)],
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
