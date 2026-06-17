import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A tiny inline line chart for trends inside cards/rows.
class Sparkline extends StatelessWidget {
  const Sparkline({
    super.key,
    required this.values,
    this.color,
    this.width = 72,
    this.height = 28,
    this.fill = true,
  });

  final List<double> values;
  final Color? color;
  final double width;
  final double height;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final c = color ??
        (values.isNotEmpty && values.last >= values.first
            ? AppColors.positive
            : AppColors.negative);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SparkPainter(values, c, fill)),
    );
  }
}

class _SparkPainter extends CustomPainter {
  _SparkPainter(this.values, this.color, this.fill);
  final List<double> values;
  final Color color;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final minV = values.reduce((a, b) => a < b ? a : b);
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final range = (maxV - minV).abs() < 1e-9 ? 1 : (maxV - minV);
    final dx = size.width / (values.length - 1);

    Offset pointAt(int i) {
      final x = dx * i;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      return Offset(x, y);
    }

    final path = Path()..moveTo(0, pointAt(0).dy);
    for (var i = 1; i < values.length; i++) {
      path.lineTo(pointAt(i).dx, pointAt(i).dy);
    }

    if (fill) {
      final fillPath = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.0)],
          ).createShader(Offset.zero & size),
      );
    }

    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.values != values || old.color != color;
}
