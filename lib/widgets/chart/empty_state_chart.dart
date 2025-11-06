// widgets/empty_state_chart.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyStateChart extends StatelessWidget {
  final String message;
  final bool isApresiasi;

  const EmptyStateChart({Key? key, required this.message, required this.isApresiasi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: isApresiasi
                  ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                  : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Icon(isApresiasi ? Icons.star : Icons.warning, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(message, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}