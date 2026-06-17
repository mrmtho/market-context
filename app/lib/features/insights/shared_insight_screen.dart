import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/components/page_scaffold.dart';
import '../../ui/components/status_views.dart';

class SharedInsightScreen extends ConsumerWidget {
  const SharedInsightScreen({super.key, required this.insightId});
  final String insightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(child: EmptyStateView(title: 'Insight · $insightId'));
  }
}
