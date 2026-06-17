import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/events.dart';
import '../../../data/providers/providers.dart';
import '../../../ui/components/glass_container.dart';
import '../../../ui/components/loading_skeleton.dart';
import '../../../ui/components/mc_badge.dart';
import '../../../ui/components/mc_chip.dart';
import '../../../ui/components/section_header.dart';
import '../../../ui/components/status_views.dart';

final _eventFilterProvider =
    StateProvider.family<Set<EventCategory>, String>((ref, id) => {});

/// News & events timeline (Feature 9).
class NewsTimeline extends ConsumerWidget {
  const NewsTimeline({super.key, required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(eventsProvider(symbol));
    final filters = ref.watch(_eventFilterProvider(symbol));
    final selectedDate = ref.watch(selectedDateProvider(symbol));

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            eyebrow: 'What happened',
            title: 'News & events',
            accent: AppColors.warning,
          ),
          AppSpacing.vGapLg,
          events.when(
            loading: () => const SkeletonCard(height: 220, lines: 5),
            error: (e, _) => ErrorStateView(
              message: e.toString(),
              onRetry: () => ref.invalidate(eventsProvider(symbol)),
            ),
            data: (all) {
              final categories = all.map((e) => e.category).toSet().toList();
              final filtered = filters.isEmpty
                  ? all
                  : all.where((e) => filters.contains(e.category)).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (final c in categories)
                        MCChip(
                          label: c.label,
                          icon: c.icon,
                          accent: c.color,
                          selected: filters.contains(c),
                          onTap: () {
                            final next = {...filters};
                            next.contains(c) ? next.remove(c) : next.add(c);
                            ref.read(_eventFilterProvider(symbol).notifier).state = next;
                          },
                        ),
                    ],
                  ),
                  AppSpacing.vGapLg,
                  if (filtered.isEmpty)
                    const EmptyStateView(
                      icon: Icons.event_busy_rounded,
                      title: 'No events match',
                      message: 'Try clearing the category filters.',
                    )
                  else
                    _Timeline(events: filtered, selectedDate: selectedDate),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.events, this.selectedDate});
  final List<NarrativeEvent> events;
  final DateTime? selectedDate;

  bool _isNearSelected(NarrativeEvent e) {
    if (selectedDate == null) return false;
    return e.date.difference(selectedDate!).inDays.abs() <= 7;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < events.length; i++)
          _EventRow(
            event: events[i],
            isLast: i == events.length - 1,
            highlighted: _isNearSelected(events[i]),
          ),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.isLast, required this.highlighted});
  final NarrativeEvent event;
  final bool isLast;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline rail.
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: event.category.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: event.category.color.withValues(alpha: 0.5)),
                ),
                child: Icon(event.category.icon, size: 15, color: event.category.color),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1.5, color: AppColors.border),
                ),
            ],
          ),
          AppSpacing.hGapMd,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: highlighted
                      ? AppColors.accentViolet.withValues(alpha: 0.1)
                      : AppColors.glassFill,
                  borderRadius: AppRadii.brMd,
                  border: Border.all(
                    color: highlighted
                        ? AppColors.accentViolet.withValues(alpha: 0.4)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(Fmt.date(event.date),
                              style: AppTypography.eyebrow()),
                        ),
                        MCBadge(
                          label: event.impact.label,
                          color: event.impact.color,
                          icon: event.impact.icon,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(event.title,
                        style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(event.summary,
                        style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.source_rounded, size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(event.source,
                            style: Theme.of(context).textTheme.labelSmall),
                        const SizedBox(width: 12),
                        Icon(Icons.verified_rounded,
                            size: 13,
                            color: event.confidence >= 0.75
                                ? AppColors.positive
                                : AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(event.confidenceLabel,
                            style: Theme.of(context).textTheme.labelSmall),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
