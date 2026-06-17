import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';

/// A consistent scrollable page body with a max content width and responsive
/// horizontal padding (Feature 1, task 11).
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.child,
    this.maxWidth = 1240,
    this.padding,
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final pad = padding ??
        const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl);
    final content = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: pad, child: child),
      ),
    );
    if (!scrollable) return content;
    return SingleChildScrollView(
      child: content,
    );
  }
}
