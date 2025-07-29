import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
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
                        BoxShadow(
                          color: const Color(0xFF61B8FF).withOpacity(0.2),
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 40),

                  Column(
                    children: [
                      Text(
                        'Selamat Datang! 👋',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                          height: 1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF61B8FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: const Color(0xFF61B8FF).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Pilih peran Anda untuk melanjutkan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  _buildEnhancedRoleButton(
                    context: context,
                    title: 'Kepala Program Keahlian',
                    subtitle:
                        'Kelola seluruh program keahlian dan monitoring siswa',
                    icon: Icons.admin_panel_settings_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      print('Navigating to Kaprog...');
                      Navigator.pushNamed(context, '/kaprog');
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildEnhancedRoleButton(
                    context: context,
                    title: 'Wali Kelas',
                    subtitle: 'Kelola kelas, siswa, dan laporan perkembangan',
                    icon: Icons.class_outlined,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    onTap: () {
                      print('Navigating to Walikelas...');
                      Navigator.pushNamed(context, '/walikelas');
                    },
                  ),

                  const SizedBox(height: 40),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Aplikasi Manajemen Siswa SMK',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedRoleButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 25,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: gradient.colors.first.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(child: Icon(icon, color: Colors.white, size: 32)),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 20),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
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

            const SizedBox(width: 16),

            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    gradient.colors.first.withOpacity(0.1),
                    gradient.colors.last.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: gradient.colors.first.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: gradient.colors.first,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KaprogMainScreen extends StatefulWidget {
  const KaprogMainScreen({Key? key}) : super(key: key);

  @override
  State<KaprogMainScreen> createState() => _KaprogMainScreenState();
}

class _KaprogMainScreenState extends State<KaprogMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const KaprogHomeScreen(),
    const KaprogSiswaScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: KaprogNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class KaprogHomeScreen extends StatelessWidget {
  const KaprogHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Dashboard Kaprog', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF0083EE),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 64,
              color: Colors.blue.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Dashboard Kepala Program',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Berhasil masuk sebagai Kaprog!',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class KaprogSiswaScreen extends StatelessWidget {
  const KaprogSiswaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Data Siswa Kaprog', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFF0083EE),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Halaman Data Siswa Kaprog',
          style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

class KaprogNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;

  const KaprogNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  State<KaprogNavigation> createState() => _KaprogNavigationState();
}

class _KaprogNavigationState extends State<KaprogNavigation> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          _buildNavItem(
            index: 1,
            icon: Icons.groups_outlined,
            activeIcon: Icons.groups,
            label: 'Siswa',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final bool isActive = widget.currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onTap(index),
        child: Container(
          height: 70,
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: 0,
                left: isActive ? 20 : 35,
                right: isActive ? 20 : 35,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  height: isActive ? 3 : 0,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0083EE),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Content
              Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: Icon(
                          isActive ? activeIcon : icon,
                          color:
                              isActive
                                  ? const Color(0xFF0083EE)
                                  : Colors.grey.shade600,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          color:
                              isActive
                                  ? const Color(0xFF0083EE)
                                  : Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                        child: Text(label),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
