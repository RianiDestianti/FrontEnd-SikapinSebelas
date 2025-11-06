// widgets/pie_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/api/api_chart_data.dart';
import 'pie_chart_painter.dart';

class PieChartWidget extends StatelessWidget {
  final List<ApiChartData> data;
  final double total;
  final bool isApresiasi;

  const PieChartWidget({Key? key, required this.data, required this.total, required this.isApresiasi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = isApresiasi
        ? [const Color(0xFF61B8FF), const Color(0xFF0083EE), const Color(0xFF3B82F6), const Color(0xFF1E40AF), const Color(0xFF1E3A8A)]
        : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F), const Color(0xFFEF4444), const Color(0xFFDC2626), const Color(0xFFB91C1C)];

    return SizedBox(
      height: 250,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomPaint(
              size: const Size(150, 150),
              painter: PieChartPainter(data: data, total: total, colors: colors),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                final percentage = total > 0 ? (item.value / total) * 100 : 0;
                final color = colors[i % colors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
                            Text('${percentage.toInt()}%', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF6B7280))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}