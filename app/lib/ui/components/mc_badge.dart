import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Small status badge / tag (categories, impact direction, confidence).
class MCBadge extends StatelessWidget {
  const MCBadge({
    super.key,
    required this.label,
    this.color = AppColors.accentCyan,
    this.icon,
    this.filled = false,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: icon != null ? 8 : 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: filled ? 0.9 : 0.13),
        borderRadius: const BorderRadius.all(Radius.circular(7)),
        border: Border.all(color: color.withValues(alpha: filled ? 0.9 : 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: filled ? Colors.white : color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}
