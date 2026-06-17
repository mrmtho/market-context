import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/components/page_scaffold.dart';
import '../../ui/components/status_views.dart';

class ScenarioScreen extends ConsumerWidget {
  const ScenarioScreen({super.key, required this.symbol});
  final String symbol;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PageScaffold(child: EmptyStateView(title: 'Scenario · $symbol'));
  }
}
