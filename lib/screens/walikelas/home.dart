import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../navigation/walikelas.dart';
import 'siswa.dart';
import 'laporan.dart';

class WalikelasMainScreen extends StatefulWidget {
  const WalikelasMainScreen({Key? key}) : super(key: key);

  @override
  State<WalikelasMainScreen> createState() => _WalikelasMainScreenState();
}

class _WalikelasMainScreenState extends State<WalikelasMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SiswaScreen(),
    const LaporanScreen(),
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _screens[_currentIndex],
      bottomNavigationBar: WalikelasNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x200083EE),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(width: 16, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1))),
                                  Positioned(top: 8, child: Container(width: 16, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)))),
                                  Positioned(top: 16, child: Container(width: 16, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)))),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(Icons.notifications_outlined, color: Color(0xFF0083EE), size: 22),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                                            ),
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFFF6B6D).withOpacity(0.4),
                                                blurRadius: 4,
                                                offset: const Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFFF6B6D).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.person, color: Colors.white, size: 22),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hello, Maam Euis! 👋',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Semoga harimu penuh berkah dan menyenangkan',
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Cari siswa, kelas, atau aktivitas...',
                                    hintStyle: GoogleFonts.poppins(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        Row(
                          children: [
                            _buildActionButton('Umum', 0),
                            const SizedBox(width: 10),
                           
                            const SizedBox(width: 10),
                            _buildActionButton('Terbaik', 2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildEnhancedChartCard(
                        'Grafik Apresiasi Siswa',
                        'Pencapaian positif minggu ini',
                        Icons.trending_up,
                        const LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)]),
                        _buildBarChart([
                          {'value': 80.0, 'label': 'Sen'},
                          {'value': 120.0, 'label': 'Sel'},
                          {'value': 90.0, 'label': 'Rab'},
                          {'value': 40.0, 'label': 'Kam'},
                          {'value': 100.0, 'label': 'Jum'},
                        ], const LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)])),
                        'Minggu',
                        'Bulan',
                        true,
                      ),
                      const SizedBox(height: 20),
                      
                      _buildEnhancedChartCard(
                        'Grafik Pelanggaran Siswa',
                        'Monitoring pelanggaran minggu ini',
                        Icons.warning_amber_rounded,
                        const LinearGradient(colors: [Color(0xFFF2D6D7), Color(0xFFFF6B6D)]),
                        _buildBarChart([
                          {'value': 60.0, 'label': 'Sen'},
                          {'value': 25.0, 'label': 'Sel'},
                          {'value': 15.0, 'label': 'Rab'},
                          {'value': 10.0, 'label': 'Kam'},
                          {'value': 20.0, 'label': 'Jum'},
                        ], const LinearGradient(colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)])),
                        'Minggu',
                        'Bulan',
                        false,
                      ),
                      const SizedBox(height: 20),
                      
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.history, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Aktivitas Terkini',
                                        style: GoogleFonts.poppins(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      Text(
                                        'Update terbaru dari sistem',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            _buildEnhancedActivityItem(
                              Icons.assessment_outlined,
                              const LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)]),
                              'Laporan Bulanan',
                              'Laporan evaluasi siswa telah selesai dibuat',
                              '10.30',
                              'SELESAI',
                              const Color(0xFF10B981),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildEnhancedActivityItem(
                              Icons.emoji_events_outlined,
                              const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                              'Poin Apresiasi',
                              'Poin apresiasi berhasil ditambahkan kepada 3 siswa berprestasi',
                              '08.30',
                              'BARU',
                              const Color(0xFF10B981),
                            ),
                            const SizedBox(height: 16),
                            
                            _buildEnhancedActivityItem(
                              Icons.report_problem_outlined,
                              const LinearGradient(colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)]),
                              'Pelanggaran',
                              'Terdapat 3 siswa dengan pelanggaran ringan',
                              '06.30',
                              'PERLU TINDAKAN',
                              const Color(0xFFEA580C),
                            ),
                          ],
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
    );
  }

  Widget _buildActionButton(String text, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isActive && index == 0)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)]),
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                text,
                style: GoogleFonts.poppins(
                  color: isActive 
                    ? (index == 0 ? const Color(0xFF1F2937) : const Color(0xFF6B7280))
                    : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedChartCard(String title, String subtitle, IconData icon, Gradient gradient, Widget chart, String button1, String button2, bool isFirst) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _buildChartButton(button1, isFirst),
                    const SizedBox(width: 8),
                    _buildChartButton(button2, !isFirst),
                  ],
                ),
              ],
            ),
          ),
          // Chart content
          Padding(
            padding: const EdgeInsets.all(20),
            child: chart,
          ),
        ],
      ),
    );
  }

  Widget _buildChartButton(String text, bool isActive) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: isActive ? const Color(0xFF1F2937) : Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, Gradient gradient) {
    double maxValue = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${maxValue.toInt()}', 
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                      Text('${(maxValue * 0.75).toInt()}', 
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                      Text('${(maxValue * 0.5).toInt()}', 
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                      Text('${(maxValue * 0.25).toInt()}', 
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                      Text('0', 
                          style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF), fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((item) {
                      double value = item['value'];
                      double height = (value / maxValue) * 120;
                      return Container(
                        width: 24,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: gradient,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 42),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.map((item) {
                    return Text(
                      item['label'],
                      style: GoogleFonts.poppins(
                        fontSize: 11, 
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActivityItem(IconData icon, Gradient gradient, String title, String subtitle, String time, String badge, Color badgeColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF9CA3AF),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
                ),
                child: Text(
                  badge,
                  style: GoogleFonts.poppins(
                    color: badgeColor,
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

