// widgets/grafik_app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GrafikAppBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isApresiasi;
  final IconData icon;

  const GrafikAppBar({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.isApresiasi,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isApresiasi
              ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
              : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 30),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(subtitle, style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w400)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}