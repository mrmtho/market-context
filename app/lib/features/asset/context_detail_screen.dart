import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/components/page_scaffold.dart';
import '../../ui/components/status_views.dart';

class ContextDetailScreen extends ConsumerWidget {
  const ContextDetailScreen({super.key, required this.symbol, required this.dateIso});
  final String symbol;
  final String dateIso;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(
      child: EmptyStateView(title: 'Context · $symbol · $dateIso'),
    );
  }
}
