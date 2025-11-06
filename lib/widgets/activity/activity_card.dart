// widgets/activity_card.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/api/api_activity.dart';

class ActivityCard extends StatelessWidget {
  final ApiActivity activity;
  final VoidCallback onTap;

  const ActivityCard({Key? key, required this.activity, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: activity.gradient.first.withOpacity(0.1), width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildIcon(),
                const SizedBox(width: 16),
                Expanded(child: _buildContent()),
              ],
            ),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(gradient: LinearGradient(colors: activity.gradient), borderRadius: BorderRadius.circular(16), boxShadow: [
        BoxShadow(color: activity.gradient.first.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
      ]),
      child: Icon(activity.icon, color: Colors.white, size: 24),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(activity.title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: activity.statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: activity.statusColor.withOpacity(0.3), width: 1),
              ),
              child: Text(activity.status, style: GoogleFonts.poppins(color: activity.statusColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          activity.subtitle,
          style: GoogleFonts.poppins(color: const Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w400, height: 1.4),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.access_time, size: 16, color: Color(0xFF9CA3AF)),
            const SizedBox(width: 6),
            Text('${activity.time} • ${activity.date}', style: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }
}