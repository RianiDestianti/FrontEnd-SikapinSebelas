// widgets/trend_analysis_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/api/api_chart_data.dart';

class TrendAnalysisWidget extends StatelessWidget {
  final List<ApiChartData> data;
  final bool isApresiasi;

  const TrendAnalysisWidget({Key? key, required this.data, required this.isApresiasi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final total = data.fold(0.0, (s, i) => s + i.value);
    final isIncreasing = data.length > 1 && data.last.value > data.first.value;
    final change = data.length > 1 ? ((data.last.value - data.first.value).abs() / data.first.value * 100).toInt() : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isApresiasi
            ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
            : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.insights, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Text('Analisis Tren', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _card('Status Tren', isIncreasing ? 'Meningkat' : 'Menurun', isIncreasing ? Icons.trending_up : Icons.trending_down)),
              const SizedBox(width: 12),
              Expanded(child: _card('Perubahan', '$change%', isIncreasing ? Icons.north : Icons.south)),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rekomendasi', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  isApresiasi
                      ? (isIncreasing
                          ? 'Tren positif! Pertahankan program apresiasi...'
                          : 'Perlu peningkatan program apresiasi...')
                      : (isIncreasing
                          ? 'Perlu perhatian khusus! Tingkatkan pengawasan...'
                          : 'Tren menurun sangat baik! Pertahankan...'),
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9), height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.2))),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
          Text(title, style: GoogleFonts.poppins(fontSize: 10, color: Colors.white.withOpacity(0.8))),
        ],
      ),
    );
  }
}