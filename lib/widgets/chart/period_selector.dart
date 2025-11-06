// widgets/period_selector.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PeriodSelector extends StatelessWidget {
  final int selectedIndex;
  final bool isApresiasi;
  final ValueChanged<int> onChanged;

  const PeriodSelector({Key? key, required this.selectedIndex, required this.isApresiasi, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final periods = ['Minggu', 'Bulan', 'Tahun'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: periods.asMap().entries.map((e) {
          final i = e.key;
          final period = e.value;
          final active = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: active
                      ? LinearGradient(colors: isApresiasi
                          ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                          : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)])
                      : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: active ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}