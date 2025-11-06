// widgets/chart_type_selector.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartTypeSelector extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ChartTypeSelector({Key? key, required this.selectedIndex, required this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final types = [
      {'name': 'Bar', 'icon': Icons.bar_chart},
      {'name': 'Pie', 'icon': Icons.pie_chart},
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: types.asMap().entries.map((e) {
          final i = e.key;
          final type = e.value;
          final active = selectedIndex == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(color: active ? const Color(0xFFF3F4F6) : null, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(type['icon'] as IconData, color: active ? const Color(0xFF1F2937) : const Color(0xFF6B7280), size: 18),
                    const SizedBox(width: 6),
                    Text(type['name'] as String, style: GoogleFonts.poppins(color: active ? const Color(0xFF1F2937) : const Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 12)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}