import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/kaprog/student.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.06;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: true,
          bottom: false,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LogoSection(),
                  SizedBox(height: padding * 2),
                  WelcomeSection(),
                  SizedBox(height: padding * 2.4),
                  RoleButton(
                    title: 'Kepala Program Keahlian',
                    subtitle: 'Kelola seluruh program keahlian dan monitoring siswa',
                    icon: Icons.admin_panel_settings_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProgramKeahlianScreen()),
                      );
                    },
                  ),
                  SizedBox(height: padding),
                  RoleButton(
                    title: 'Wali Kelas',
                    subtitle: 'Kelola kelas, siswa, dan laporan perkembangan',
                    icon: Icons.class_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/walikelas');
                    },
                  ),
                  SizedBox(height: padding * 2),
                  FooterSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final logoSize = screenWidth * 0.3;

    return Container(
      width: logoSize,
      height: logoSize,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0083EE).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.school_outlined,
        size: logoSize * 0.53,
        color: Colors.white,
      ),
    );
  }
}

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.08;
    final padding = screenWidth * 0.05;

    return Column(
      children: [
        Text(
          'Selamat Datang! 👋',
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
            height: 1.2,
          ),
        ),
        SizedBox(height: padding * 0.6),
        Container(
          padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.6),
          decoration: BoxDecoration(
            color: const Color(0xFF61B8FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(padding * 1.25),
            border: Border.all(color: const Color(0xFF61B8FF).withOpacity(0.2), width: 1),
          ),
          child: Text(
            'Pilih peran Anda untuk melanjutkan',
            style: GoogleFonts.poppins(
              fontSize: fontSize * 0.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class RoleButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.06;
    final fontSize = screenWidth * 0.045;
    final subtitleFontSize = screenWidth * 0.035;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(padding * 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 25, offset: const Offset(0, 8)),
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            RoleIcon(icon: icon, gradient: gradient),
            SizedBox(width: padding * 0.5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: padding * 0.2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: subtitleFontSize,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: padding * 0.4),
            RoleArrow(gradient: gradient),
          ],
        ),
      ),
    );
  }
}

class RoleIcon extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;

  const RoleIcon({super.key, required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final iconSize = screenWidth * 0.18;

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(iconSize * 0.28),
        boxShadow: [
          BoxShadow(color: gradient.colors.first.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Stack(
        children: [
          Center(child: Icon(icon, color: Colors.white, size: iconSize * 0.44)),
          Positioned(
            top: iconSize * 0.17,
            right: iconSize * 0.17,
            child: Container(
              width: iconSize * 0.17,
              height: iconSize * 0.17,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(iconSize * 0.085),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoleArrow extends StatelessWidget {
  final Gradient gradient;

  const RoleArrow({super.key, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final arrowSize = screenWidth * 0.11;

    return Container(
      width: arrowSize,
      height: arrowSize,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradient.colors.first.withOpacity(0.1),
            gradient.colors.last.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(arrowSize * 0.32),
        border: Border.all(color: gradient.colors.first.withOpacity(0.2), width: 1),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        color: gradient.colors.first,
        size: arrowSize * 0.41,
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenWidth * 0.04;
    final fontSize = screenWidth * 0.03;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(padding * 1.25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: padding * 0.5,
            height: padding * 0.5,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)]),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: padding * 0.5),
          Text(
            'Aplikasi Manajemen Siswa SMK',
            style: GoogleFonts.poppins(
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}