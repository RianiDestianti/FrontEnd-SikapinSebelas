// widgets/activity_detail_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:skoring/models/api/api_activity.dart';

class ActivityDetailBottomSheet extends StatelessWidget {
  final ApiActivity activity;

  const ActivityDetailBottomSheet({Key? key, required this.activity}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (context, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              _buildHeader(),
              const SizedBox(height: 24),
              Expanded(child: SingleChildScrollView(controller: controller, child: _buildDetails())),
              const SizedBox(height: 16),
              _buildCloseButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(gradient: LinearGradient(colors: activity.gradient), borderRadius: BorderRadius.circular(20), boxShadow: [
            BoxShadow(color: activity.gradient.first.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
          ]),
          child: Icon(activity.icon, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.title, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937))),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: activity.statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: activity.statusColor.withOpacity(0.3), width: 1)),
                child: Text(activity.status, style: GoogleFonts.poppins(color: activity.statusColor, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _detailRow('Waktu', '${activity.time} • ${activity.date}'),
        const SizedBox(height: 16),
        _detailRow('Deskripsi', activity.subtitle),
        const SizedBox(height: 16),
        _detailRow('Detail', activity.details),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF374151))),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E7EB), width: 1)),
          child: Text(value, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280), height: 1.5)),
        ),
      ],
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0083EE),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: Text('Tutup', style: GoogleFonts.poppins(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}