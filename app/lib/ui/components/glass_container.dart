import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';

/// A frosted-glass surface: blurred translucent fill with a hairline border
/// and a subtle top sheen. The visual backbone of the whole UI.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.borderRadius = AppRadii.brLg,
    this.blur = 18,
    this.fillOpacity = 0.05,
    this.borderColor,
    this.glow,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final double blur;
  final double fillOpacity;
  final Color? borderColor;
  final Color? glow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: AppGradients.glass,
            color: Colors.white.withValues(alpha: fillOpacity),
            borderRadius: borderRadius,
            border: Border.all(
              color: borderColor ?? AppColors.border,
              width: 1,
            ),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );

    final decorated = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: [
          if (glow != null)
            BoxShadow(
              color: glow!.withValues(alpha: 0.35),
              blurRadius: 36,
              spreadRadius: -6,
            ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: content,
    );

    if (onTap == null) return decorated;
    return _Hoverable(borderRadius: borderRadius, onTap: onTap!, child: decorated);
  }
}

/// Adds a pointer-cursor + lift-on-hover affordance for clickable surfaces.
class _Hoverable extends StatefulWidget {
  const _Hoverable({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });
  final Widget child;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  State<_Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<_Hoverable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.012 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
