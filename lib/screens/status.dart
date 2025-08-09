import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StatusScreen extends StatefulWidget {
  final Map<String, dynamic> siswaData;

  const StatusScreen({Key? key, required this.siswaData}) : super(key: key);

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedTab = 0;

  final List<Map<String, dynamic>> _riwayatApresiasi = [
    {
      'tanggal': '15 Agt 2025',
      'waktu': '10:30',
      'jenis': 'Prestasi Akademik',
      'deskripsi': 'Juara 1 OSN Matematika Tingkat Provinsi',
      'poin': 100,
      'pemberi': 'Bu Sari',
      'kategori': 'akademik',
    },
    {
      'tanggal': '12 Agt 2025',
      'waktu': '14:15',
      'jenis': 'Sikap Positif',
      'deskripsi': 'Membantu teman yang kesulitan memahami materi',
      'poin': 25,
      'pemberi': 'Pak Budi',
      'kategori': 'sikap',
    },
    {
      'tanggal': '10 Agt 2025',
      'waktu': '08:45',
      'jenis': 'Kehadiran',
      'deskripsi': 'Datang tepat waktu selama 1 minggu berturut-turut',
      'poin': 20,
      'pemberi': 'System',
      'kategori': 'kehadiran',
    },
  ];

  final List<Map<String, dynamic>> _riwayatPelanggaran = [
    {
      'tanggal': '08 Agt 2025',
      'waktu': '07:45',
      'jenis': 'Keterlambatan',
      'deskripsi': 'Terlambat masuk kelas 10 menit',
      'poin': -5,
      'pemberi': 'Bu Ani',
      'kategori': 'ringan',
    },
  ];

  final List<Map<String, dynamic>> _statistikBulanan = [
    {'bulan': 'Jan', 'apresiasi': 180, 'pelanggaran': 10},
    {'bulan': 'Feb', 'apresiasi': 220, 'pelanggaran': 5},
    {'bulan': 'Mar', 'apresiasi': 195, 'pelanggaran': 15},
    {'bulan': 'Apr', 'apresiasi': 240, 'pelanggaran': 8},
    {'bulan': 'May', 'apresiasi': 210, 'pelanggaran': 3},
  ];

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
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildTabSelector(),
                Expanded(
                  child:
                      _selectedTab == 0
                          ? _buildOverviewTab()
                          : _selectedTab == 1
                          ? _buildRiwayatTab()
                          : _buildStatistikTab(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    Color rankColor = _getRankColor(widget.siswaData['rank']);

    return Container(
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
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Status Siswa',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Profile Section
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors:
                      widget.siswaData['rank'] <= 3
                          ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                          : [const Color(0xFF61B8FF), const Color(0xFF0083EE)],
                ),
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: rankColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.person, color: Colors.white, size: 48),
                  if (widget.siswaData['rank'] <= 3)
                    Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: rankColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          _getRankIcon(widget.siswaData['rank']),
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              widget.siswaData['nama'],
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.siswaData['kelas'],
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Rank #${widget.siswaData['rank']}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('Overview', 0, Icons.dashboard_outlined),
          _buildTabButton('Riwayat', 1, Icons.history_outlined),
          _buildTabButton('Statistik', 2, Icons.bar_chart_outlined),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index, IconData icon) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient:
                isActive
                    ? const LinearGradient(
                      colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                    )
                    : null,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : const Color(0xFF6B7280),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: isActive ? Colors.white : const Color(0xFF6B7280),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildScoreCard(
                  'Total Poin',
                  '${widget.siswaData['poin']}',
                  Icons.star,
                  const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildScoreCard(
                  'Pelanggaran',
                  '2',
                  Icons.warning_amber,
                  const LinearGradient(
                    colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAchievementCard(),
          const SizedBox(height: 20),
          _buildRecentActivitiesCard(),
        ],
      ),
    );
  }

  Widget _buildScoreCard(
    String title,
    String value,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Prestasi Terbaru',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.siswaData['prestasi'] ?? 'Belum ada prestasi terbaru',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '15 Agustus 2025',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: Color(0xFF0083EE), size: 24),
              const SizedBox(width: 12),
              Text(
                'Aktivitas Terkini',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._riwayatApresiasi
              .take(3)
              .map((item) => _buildActivityItem(item))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRiwayatTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFilterButton('Apresiasi', 0)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterButton('Pelanggaran', 1)),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _selectedTab == 0 ? Icons.star : Icons.warning_amber,
                      color:
                          _selectedTab == 0
                              ? const Color(0xFFFFD700)
                              : const Color(0xFFFF6B6D),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTab == 0
                          ? 'Riwayat Apresiasi'
                          : 'Riwayat Pelanggaran',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ...(_selectedTab == 0 ? _riwayatApresiasi : _riwayatPelanggaran)
                    .map((item) => _buildHistoryItem(item))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          _buildMonthlyChart(),
          const SizedBox(height: 20),
          _buildComparisonCard(),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String title, int index) {
    bool isActive = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF0083EE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF0083EE) : const Color(0xFFE5E7EB),
          ),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: const Color(0xFF0083EE).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : null,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF34D399)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['jenis'],
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                Text(
                  item['deskripsi'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${item['poin']}',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Text(
                item['waktu'],
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> item) {
    bool isPositive = item['poin'] > 0;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isPositive
                  ? const Color(0xFF10B981).withOpacity(0.2)
                  : const Color(0xFFFF6B6D).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      isPositive
                          ? const Color(0xFF10B981).withOpacity(0.1)
                          : const Color(0xFFFF6B6D).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['jenis'],
                  style: GoogleFonts.poppins(
                    color:
                        isPositive
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFF6B6D),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${isPositive ? '+' : ''}${item['poin']} poin',
                style: GoogleFonts.poppins(
                  color:
                      isPositive
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFF6B6D),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item['deskripsi'],
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF1F2937),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${item['tanggal']} • ${item['waktu']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const Spacer(),
              Text(
                'Oleh: ${item['pemberi']}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik 5 Bulan Terakhir',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: CustomPaint(
              painter: ChartPainter(_statistikBulanan),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perbandingan Kelas',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 20),
          _buildComparisonItem('Rata-rata Kelas', '650 poin', false),
          _buildComparisonItem('Posisi di Kelas', '#1 dari 32 siswa', true),
          _buildComparisonItem('Pencapaian Target', '125% dari target', true),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(String title, String value, bool isGood) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isGood ? const Color(0xFF10B981) : const Color(0xFF6B7280),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isGood ? const Color(0xFF10B981) : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF0083EE); // Blue
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.star;
    }
  }
}

class ChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final apresiasiPaint =
        Paint()
          ..color = const Color(0xFF10B981)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    final pelanggaranPaint =
        Paint()
          ..color = const Color(0xFFFF6B6D)
          ..strokeWidth = 3
          ..style = PaintingStyle.stroke;

    // Menghitung maksimum nilai untuk scaling
    double maxApresiasi =
        data
            .map((e) => e['apresiasi'] as int)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();
    double maxPelanggaran =
        data
            .map((e) => e['pelanggaran'] as int)
            .reduce((a, b) => a > b ? a : b)
            .toDouble();
    double maxValue =
        maxApresiasi > maxPelanggaran ? maxApresiasi : maxPelanggaran;

    // Menggambar grid lines
    final gridPaint =
        Paint()
          ..color = const Color(0xFFE5E7EB)
          ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      double y = (size.height - 40) * (1 - i / 4) + 20;
      canvas.drawLine(Offset(40, y), Offset(size.width - 20, y), gridPaint);
    }

    // Menggambar garis apresiasi
    Path apresiasiPath = Path();
    Path pelanggaranPath = Path();

    for (int i = 0; i < data.length; i++) {
      double x = 40 + (size.width - 60) * i / (data.length - 1);
      double apresiasiY =
          (size.height - 40) * (1 - data[i]['apresiasi'] / maxValue) + 20;
      double pelanggaranY =
          (size.height - 40) * (1 - data[i]['pelanggaran'] / maxValue) + 20;

      if (i == 0) {
        apresiasiPath.moveTo(x, apresiasiY);
        pelanggaranPath.moveTo(x, pelanggaranY);
      } else {
        apresiasiPath.lineTo(x, apresiasiY);
        pelanggaranPath.lineTo(x, pelanggaranY);
      }

      // Menggambar titik data
      canvas.drawCircle(
        Offset(x, apresiasiY),
        4,
        Paint()..color = const Color(0xFF10B981),
      );
      canvas.drawCircle(
        Offset(x, pelanggaranY),
        4,
        Paint()..color = const Color(0xFFFF6B6D),
      );
    }

    canvas.drawPath(apresiasiPath, apresiasiPaint);
    canvas.drawPath(pelanggaranPath, pelanggaranPaint);

    // Menggambar label bulan
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < data.length; i++) {
      double x = 40 + (size.width - 60) * i / (data.length - 1);

      textPainter.text = TextSpan(
        text: data[i]['bulan'],
        style: const TextStyle(
          color: Color(0xFF6B7280),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }

    // Menggambar legend
    final legendPaint = Paint()..style = PaintingStyle.fill;

    // Legend Apresiasi
    legendPaint.color = const Color(0xFF10B981);
    canvas.drawCircle(const Offset(60, 10), 4, legendPaint);
    textPainter.text = const TextSpan(
      text: 'Apresiasi',
      style: TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(70, 5));

    // Legend Pelanggaran
    legendPaint.color = const Color(0xFFFF6B6D);
    canvas.drawCircle(const Offset(150, 10), 4, legendPaint);
    textPainter.text = const TextSpan(
      text: 'Pelanggaran',
      style: TextStyle(
        color: Color(0xFF1F2937),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(160, 5));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
