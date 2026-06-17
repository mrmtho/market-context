import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/analytics/analytics_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/narrative.dart';
import '../../../data/providers/providers.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/components/loading_skeleton.dart';
import '../../../ui/components/mc_badge.dart';
import '../../../ui/components/section_header.dart';
import '../../../ui/components/status_views.dart';

/// AI narrative explanation layer (Feature 10).
class NarrativeCard extends ConsumerStatefulWidget {
  const NarrativeCard({super.key, required this.symbol});
  final String symbol;

  @override
  ConsumerState<NarrativeCard> createState() => _NarrativeCardState();
}

class _NarrativeCardState extends ConsumerState<NarrativeCard> {
  bool _expanded = false;
  int _feedback = 0; // -1, 0, 1

  @override
  Widget build(BuildContext context) {
    final range = ref.watch(selectedRangeProvider(widget.symbol));
    final explanation =
        ref.watch(explanationProvider((id: widget.symbol, range: range)));

    return GlassContainer(
      glow: AppColors.accentViolet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SectionHeader(
                  eyebrow: 'AI narrative',
                  title: 'Why is it moving?',
                  accent: AppColors.accentMagenta,
                  trailing: explanation.maybeWhen(
                    data: (e) => MCBadge(
                      label: e.confidenceFraming,
                      color: AppColors.accentMagenta,
                      icon: Icons.auto_awesome_rounded,
                    ),
                    orElse: () => null,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.vGapLg,
          explanation.when(
            loading: () => const SkeletonCard(height: 220, lines: 4),
            error: (e, _) => ErrorStateView(
              title: 'Explanation unavailable',
              message: e.toString(),
              onRetry: () => ref.invalidate(
                  explanationProvider((id: widget.symbol, range: range))),
            ),
            data: (e) => _body(context, e),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, NarrativeExplanation e) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(e.summary, style: Theme.of(context).textTheme.bodyLarge),
        AppSpacing.vGapLg,
        Text('LIKELY DRIVERS', style: AppTypography.eyebrow()),
        AppSpacing.vGapSm,
        for (final d in e.drivers) ...[
          _DriverBar(driver: d),
          AppSpacing.vGapSm,
        ],
        if (_expanded) ...[
          AppSpacing.vGapSm,
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: AppRadii.brMd,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(e.longForm,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.55,
                    )),
          ),
        ],
        AppSpacing.vGapSm,
        TextButton.icon(
          onPressed: () => setState(() => _expanded = !_expanded),
          icon: Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18),
          label: Text(_expanded ? 'Show less' : 'Read the full reasoning'),
        ),
        const Divider(height: AppSpacing.lg),
        Text('REFERENCED DATA', style: AppTypography.eyebrow()),
        AppSpacing.vGapSm,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final ref_ in e.referencedData)
              MCBadge(label: ref_, color: AppColors.accentCyan),
          ],
        ),
        AppSpacing.vGapMd,
        _Caveats(caveats: e.caveats),
        AppSpacing.vGapMd,
        _Footer(
          feedback: _feedback,
          onCopy: () {
            Clipboard.setData(ClipboardData(text: '${e.summary}\n\n${e.longForm}'));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Explanation copied to clipboard')),
            );
          },
          onFeedback: (v) {
            setState(() => _feedback = v);
            ref.read(analyticsProvider).log(AnalyticsEvents.explanationFeedback,
                {'ticker': widget.symbol, 'value': v});
          },
        ),
        AppSpacing.vGapMd,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.shield_outlined, size: 13, color: AppColors.textTertiary),
            AppSpacing.hGapSm,
            Expanded(
              child: Text(NarrativeExplanation.disclaimer,
                  style: Theme.of(context).textTheme.labelSmall),
            ),
          ],
        ),
      ],
    );
  }
}

class _DriverBar extends StatelessWidget {
  const _DriverBar({required this.driver});
  final NarrativeDriver driver;

  @override
  Widget build(BuildContext context) {
    final color = driver.direction > 0
        ? AppColors.positive
        : driver.direction < 0
            ? AppColors.negative
            : AppColors.neutral;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              driver.direction > 0
                  ? Icons.trending_up_rounded
                  : driver.direction < 0
                      ? Icons.trending_down_rounded
                      : Icons.trending_flat_rounded,
              size: 15,
              color: color,
            ),
            AppSpacing.hGapSm,
            Expanded(child: Text(driver.label, style: Theme.of(context).textTheme.titleSmall)),
            Text('${(driver.weight * 100).round()}%',
                style: AppTypography.mono(size: 12, weight: FontWeight.w600, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(builder: (context, c) {
          return Container(
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: AppRadii.brPill,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: c.maxWidth * driver.weight.clamp(0.02, 1.0),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: AppRadii.brPill,
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 5),
        Text(driver.detail, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Caveats extends StatelessWidget {
  const _Caveats({required this.caveats});
  final List<String> caveats;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppRadii.brMd,
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CAVEATS', style: AppTypography.eyebrow(color: AppColors.warning)),
          AppSpacing.vGapSm,
          for (final c in caveats)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('· ', style: TextStyle(color: AppColors.warning)),
                  Expanded(child: Text(c, style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.feedback, required this.onCopy, required this.onFeedback});
  final int feedback;
  final VoidCallback onCopy;
  final ValueChanged<int> onFeedback;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onCopy,
          icon: const Icon(Icons.copy_rounded, size: 16),
          label: const Text('Copy'),
        ),
        const Spacer(),
        Text('Helpful?', style: Theme.of(context).textTheme.labelMedium),
        AppSpacing.hGapSm,
        IconButton(
          onPressed: () => onFeedback(feedback == 1 ? 0 : 1),
          icon: Icon(Icons.thumb_up_rounded,
              size: 17,
              color: feedback == 1 ? AppColors.positive : AppColors.textTertiary),
        ),
        IconButton(
          onPressed: () => onFeedback(feedback == -1 ? 0 : -1),
          icon: Icon(Icons.thumb_down_rounded,
              size: 17,
              color: feedback == -1 ? AppColors.negative : AppColors.textTertiary),
        ),
      ],
    );
  }
}
