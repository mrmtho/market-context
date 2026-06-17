import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/asset.dart';
import '../../data/models/context_models.dart';
import '../../data/providers/insights_controller.dart';
import '../../data/models/user_data.dart';

/// Persists a snapshot as a shareable insight and surfaces a confirmation
/// snackbar with a jump-to action (Feature 14).
void saveSnapshotInsight(
  BuildContext context,
  WidgetRef ref, {
  required Asset asset,
  required ContextSnapshot snapshot,
}) {
  final id = 'ins_${DateTime.now().microsecondsSinceEpoch}';
  final insight = SavedInsight(
    id: id,
    assetId: asset.id,
    ticker: asset.ticker,
    name: asset.displayName,
    title: '${asset.ticker} context · ${Fmt.date(snapshot.nearestActualDate)}',
    body: snapshot.headline,
    kind: 'snapshot',
    referenceDate: snapshot.nearestActualDate,
    createdAt: DateTime.now(),
    priceAtSave: snapshot.price,
  );
  ref.read(insightsProvider.notifier).save(insight);
  ref.read(analyticsProvider).log(AnalyticsEvents.insightSaved, {
    'ticker': asset.ticker,
    'kind': 'snapshot',
  });
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: const Text('Insight saved'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () => context.go('/insights/$id'),
        ),
      ),
    );
}
