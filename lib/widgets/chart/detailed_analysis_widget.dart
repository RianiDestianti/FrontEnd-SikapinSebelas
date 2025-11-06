// widgets/detailed_analysis_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/api/api_chart_data.dart';

class DetailedAnalysisWidget extends StatelessWidget {
  final List<ApiChartData> data;
  final bool isApresiasi;

  const DetailedAnalysisWidget({Key? key, required this.data, required this.isApresiasi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isApresiasi
                      ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                      : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Analisis Detail', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
            ],
          ),
          const SizedBox(height: 16),
          data.isEmpty
              ? _buildEmpty('Tidak ada data untuk analisis')
              : Column(children: data.map((item) => _buildItem(item)).toList()),
        ],
      ),
    );
  }

  Widget _buildItem(ApiChartData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: isApresiasi
                      ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                      : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${item.value.toInt()}', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(item.detail, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF6B7280), fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildEmpty(String msg) => Center(child: Text(msg, style: GoogleFonts.poppins(color: const Color(0xFF6B7280))));
}