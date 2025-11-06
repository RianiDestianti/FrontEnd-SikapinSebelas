// widgets/empty_state_widget.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(40)),
            child: const Icon(Icons.search_off, color: Color(0xFF9CA3AF), size: 40),
          ),
          const SizedBox(height: 16),
          Text('Tidak ada aktivitas ditemukan', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Text('Coba ubah filter atau kata kunci pencarian', style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF9CA3AF))),
        ],
      ),
    );
  }
}