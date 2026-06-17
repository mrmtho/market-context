import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_gradients.dart';
import '../../core/theme/app_spacing.dart';

enum MCButtonSize { small, medium }

/// Primary call-to-action: gradient fill with glow.
class MCPrimaryButton extends StatelessWidget {
  const MCPrimaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = MCButtonSize.medium,
    this.expand = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final MCButtonSize size;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final vPad = size == MCButtonSize.small ? 9.0 : 13.0;
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 17, color: const Color(0xFF04121A)),
          AppSpacing.hGapSm,
        ],
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF04121A),
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: MouseRegion(
        cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding:
                EdgeInsets.symmetric(horizontal: 20, vertical: vPad),
            decoration: BoxDecoration(
              gradient: AppGradients.accent,
              borderRadius: AppRadii.brPill,
              boxShadow: disabled
                  ? null
                  : [
                      BoxShadow(
                        color: AppColors.accentCyan.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: -6,
                      ),
                    ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Secondary / ghost button: glass outline.
class MCSecondaryButton extends StatelessWidget {
  const MCSecondaryButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.size = MCButtonSize.medium,
    this.expand = false,
    this.accent,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final MCButtonSize size;
  final bool expand;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    final color = accent ?? AppColors.textPrimary;
    final vPad = size == MCButtonSize.small ? 8.0 : 12.0;
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: MouseRegion(
        cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onPressed,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: vPad),
            decoration: BoxDecoration(
              color: AppColors.glassFill,
              borderRadius: AppRadii.brPill,
              border: Border.all(color: AppColors.borderStrong),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color),
                  AppSpacing.hGapSm,
                ],
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Circular glass icon button.
class MCIconButton extends StatelessWidget {
  const MCIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.active = false,
    this.accent,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool active;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.accentCyan;
    final btn = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: active
                ? color.withValues(alpha: 0.16)
                : AppColors.glassFill,
            borderRadius: AppRadii.brSm,
            border: Border.all(
              color: active ? color.withValues(alpha: 0.5) : AppColors.border,
            ),
          ),
          child: Icon(icon,
              size: 18,
              color: active ? color : AppColors.textSecondary),
        ),
      ),
    );
    if (tooltip == null) return btn;
    return Tooltip(message: tooltip!, child: btn);
  }
}
