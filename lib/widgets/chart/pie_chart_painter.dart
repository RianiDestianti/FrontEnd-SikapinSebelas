// widgets/pie_chart_painter.dart
import 'package:flutter/material.dart';
import 'package:skoring/models/api/api_chart_data.dart';

class PieChartPainter extends CustomPainter {
  final List<ApiChartData> data;
  final double total;
  final List<Color> colors;

  PieChartPainter({required this.data, required this.total, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    double startAngle = -90 * (3.14159 / 180);

        for (int i = 0; i < data.length; i++) {
      final value = data[i].value.isNaN ? 0.0 : data[i].value;
      final safeTotal = (total <= 0 || total.isNaN) ? 1.0 : total;

      final sweepAngle = (value / safeTotal) * 2 * 3.141592653589793;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      startAngle += sweepAngle;
    }

    canvas.drawCircle(center, radius * 0.4, Paint()..color = Colors.white..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}