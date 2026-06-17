import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'status_views.dart';

/// Standardised rendering of a Riverpod [AsyncValue]: data / loading / error,
/// with a consistent error panel + retry (Feature 16).
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.loading,
    this.onRetry,
    this.errorTitle = 'Could not load data',
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final VoidCallback? onRetry;
  final String errorTitle;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () =>
          loading ?? const Center(child: CircularProgressIndicator()),
      error: (e, _) => ErrorStateView(
        title: errorTitle,
        message: e.toString(),
        onRetry: onRetry,
      ),
    );
  }
}
