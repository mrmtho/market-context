import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ui/components/page_scaffold.dart';
import '../../ui/components/status_views.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const PageScaffold(child: EmptyStateView(title: 'Compare'));
  }
}
