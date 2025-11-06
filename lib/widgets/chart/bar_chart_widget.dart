// widgets/bar_chart_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/api/api_chart_data.dart';

class BarChartWidget extends StatelessWidget {
  final List<ApiChartData> data;
  final bool isApresiasi;

  const BarChartWidget({Key? key, required this.data, required this.isApresiasi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxValue = data.isNotEmpty ? data.map((e) => e.value).reduce((a, b) => a > b ? a : b) : 1.0;
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [maxValue, maxValue * 0.75, maxValue * 0.5, maxValue * 0.25, 0.0].map((v) => Text(
                      '${v.toInt()}',
                      style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF)),
                    )).toList(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((item) {
                      final height = (item.value / maxValue) * 150;
                      return Container(
                        width: 32,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: isApresiasi
                              ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                              : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 52),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.map((item) => Text(
                    item.label,
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w600),
                  )).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}