import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/profile.dart';

class HomeKaprogScreen extends StatefulWidget {
  const HomeKaprogScreen({Key? key}) : super(key: key);

  @override
  State<HomeKaprogScreen> createState() => _HomeKaprogScreenState();
}

class _HomeKaprogScreenState extends State<HomeKaprogScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TextEditingController _searchController;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _siswaTerbaik = [
    {
      'nama': 'Ahmad Zaky',
      'kelas': 'XII RPL 1',
      'poin': 900,
      'prestasi': 'Juara 1 Hackathon Nasional',
      'avatar': Icons.person,
      'rank': 1,
    },
    {
      'nama': 'Siti Aisyah',
      'kelas': 'XII DKV 2',
      'poin': 870,
      'prestasi': 'Juara 2 Desain Poster',
      'avatar': Icons.person,
      'rank': 2,
    },
    {
      'nama': 'Budi Santoso',
      'kelas': 'XII TKJ 1',
      'poin': 850,
      'prestasi': 'Ketua Tim Jaringan Berprestasi',
      'avatar': Icons.person,
      'rank': 3,
    },
    {
      'nama': 'Rina Amelia',
      'kelas': 'XII MP 1',
      'poin': 820,
      'prestasi': 'Juara 1 Lomba Administrasi',
      'avatar': Icons.person,
      'rank': 4,
    },
  ];

  final List<Map<String, dynamic>> _siswaBerpelanggaran = [
    {
      'nama': 'Dedi Kurniawan',
      'kelas': 'XII RPL 2',
      'pelanggaran': 'Terlambat 3 kali',
      'poin': 50,
      'avatar': Icons.person,
      'severity': 'Ringan',
    },
    {
      'nama': 'Lina Sari',
      'kelas': 'XII TKJ 1',
      'pelanggaran': 'Tidak memakai seragam lengkap',
      'poin': 30,
      'avatar': Icons.person,
      'severity': 'Ringan',
    },
    {
      'nama': 'Rudi Hartono',
      'kelas': 'XII DKV 2',
      'pelanggaran': 'Merokok di lingkungan sekolah',
      'poin': 100,
      'avatar': Icons.person,
      'severity': 'Berat',
    },
    {
      'nama': 'Mila Putri',
      'kelas': 'XII MP 1',
      'pelanggaran': 'Melanggar tata tertib kelas',
      'poin': 40,
      'avatar': Icons.person,
      'severity': 'Ringan',
    },
  ];

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
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredSiswaTerbaik() {
    if (_searchQuery.isEmpty) return _siswaTerbaik;
    return _siswaTerbaik.where((siswa) {
      return siswa['nama'].toString().toLowerCase().contains(_searchQuery) ||
             siswa['kelas'].toString().toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _getFilteredSiswaBerpelanggaran() {
    if (_searchQuery.isEmpty) return _siswaBerpelanggaran;
    return _siswaBerpelanggaran.where((siswa) {
      return siswa['nama'].toString().toLowerCase().contains(_searchQuery) ||
             siswa['kelas'].toString().toLowerCase().contains(_searchQuery);
    }).toList();
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
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
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
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person_rounded,
                                  color: Color(0xFF0083EE),
                                  size: 24,
                                ),
                              ),
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
                                'Hello, Pak Budi! 👋',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Kelola program keahlian dengan optimal',
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
                                  controller: _searchController,
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
                            _buildActionButton('Siswa Terbaik', 0),
                            const SizedBox(width: 10),
                            _buildActionButton('Siswa Berpelanggaran', 1),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _selectedTab == 0
                      ? _buildSiswaTerbaikSection()
                      : _buildSiswaBerpelanggaranSection(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSiswaTerbaikSection() {
    final filteredSiswa = _getFilteredSiswaTerbaik();
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
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
                  child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Siswa Terbaik',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Top ${filteredSiswa.length} siswa dengan poin tertinggi',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: filteredSiswa.isEmpty
                ? Text(
                    'Tidak ada siswa ditemukan',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Column(
                    children: filteredSiswa.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> siswa = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < filteredSiswa.length - 1 ? 16 : 0),
                        child: _buildSiswaTerbaikItem(siswa),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaBerpelanggaranSection() {
    final filteredSiswa = _getFilteredSiswaBerpelanggaran();
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
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
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Siswa Berpelanggaran',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Daftar ${filteredSiswa.length} siswa dengan pelanggaran',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: filteredSiswa.isEmpty
                ? Text(
                    'Tidak ada siswa ditemukan',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF6B7280),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Column(
                    children: filteredSiswa.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> siswa = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < filteredSiswa.length - 1 ? 16 : 0),
                        child: _buildSiswaBerpelanggaranItem(siswa),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaTerbaikItem(Map<String, dynamic> siswa) {
    Color rankColor = _getRankColor(siswa['rank']);
    IconData rankIcon = _getRankIcon(siswa['rank']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rankColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: siswa['rank'] <= 3
                    ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                    : [const Color(0xFF61B8FF), const Color(0xFF0083EE)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: rankColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.person, color: Colors.white, size: 24),
                if (siswa['rank'] <= 3)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: rankColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(rankIcon, color: Colors.white, size: 10),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rankColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: rankColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        '#${siswa['rank']}',
                        style: GoogleFonts.poppins(
                          color: rankColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      siswa['nama'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0083EE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        siswa['kelas'],
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0083EE),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.star, color: const Color(0xFFFFD700), size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${siswa['poin']} poin',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  siswa['prestasi'],
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.trending_up,
              color: rankColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaBerpelanggaranItem(Map<String, dynamic> siswa) {
    Color severityColor = _getSeverityColor(siswa['severity']);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: severityColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: severityColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: severityColor.withOpacity(0.3), width: 1),
                      ),
                      child: Text(
                        siswa['severity'],
                        style: GoogleFonts.poppins(
                          color: severityColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      siswa['nama'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0083EE).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        siswa['kelas'],
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF0083EE),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.warning_amber_rounded, color: severityColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${siswa['poin']} poin',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  siswa['pelanggaran'],
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6B7280),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.warning,
              color: severityColor,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0); 
      case 3:
        return const Color(0xFFCD7F32); 
      default:
        return const Color(0xFF0083EE); 
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

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Berat':
        return const Color(0xFFFF6B6D); 
      case 'Ringan':
      default:
        return const Color(0xFFEA580C); 
    }
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
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
                    gradient: LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
                    shape: BoxShape.circle,
                  ),
                ),
              if (isActive && index == 1)
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
                  color: isActive ? const Color(0xFF1F2937) : Colors.white,
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
}