import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'points.dart';
import 'notes.dart';
import '../history.dart'; // Added import for HistoryScreen

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const DetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedTab = 0;

  late Map<String, dynamic> detailedStudent;

  final List<Map<String, dynamic>> pelanggaranHistory = [
    {
      "type": "Pelanggaran Kedisiplinan",
      "description": "Terlambat masuk kelas lebih dari 15 menit",
      "date": "20 Jul 2025",
      "time": "07:30",
      "points": -10,
      "icon": Icons.access_time,
      "color": Color(0xFFFF6B6D),
      "pelapor": "Pak Budi (Guru Piket)",
    },
    {
      "type": "Pelanggaran Pakaian",
      "description": "Tidak memakai seragam sesuai ketentuan",
      "date": "18 Jul 2025",
      "time": "07:00",
      "points": -5,
      "icon": Icons.checkroom,
      "color": Color(0xFFEA580C),
      "pelapor": "Bu Sari (Guru BK)",
    },
    {
      "type": "Pelanggaran Tugas",
      "description": "Tidak mengumpulkan tugas matematika",
      "date": "15 Jul 2025",
      "time": "10:30",
      "points": -8,
      "icon": Icons.assignment_late,
      "color": Color(0xFFFF6B6D),
      "pelapor": "Bu Ani (Guru Matematika)",
    },
  ];

  final List<Map<String, dynamic>> apresiasiHistory = [
    {
      "type": "Prestasi Akademik",
      "description": "Juara 1 Olimpiade Matematika Tingkat Kota",
      "date": "22 Jul 2025",
      "time": "14:00",
      "points": 30,
      "icon": Icons.emoji_events,
      "color": Color(0xFFFFD700),
      "pemberi": "Kepala Sekolah",
    },
    {
      "type": "Prestasi Non-Akademik",
      "description": "Juara 2 Lomba Coding Regional",
      "date": "19 Jul 2025",
      "time": "16:30",
      "points": 25,
      "icon": Icons.code,
      "color": Color(0xFF10B981),
      "pemberi": "Pak Dedi (Guru Produktif)",
    },
    {
      "type": "Kegiatan Sosial",
      "description": "Membantu kegiatan bakti sosial sekolah",
      "date": "16 Jul 2025",
      "time": "08:00",
      "points": 15,
      "icon": Icons.volunteer_activism,
      "color": Color(0xFF0EA5E9),
      "pemberi": "Bu Lisa (Guru OSIS)",
    },
    {
      "type": "Sikap Positif",
      "description": "Membantu teman yang kesulitan belajar",
      "date": "14 Jul 2025",
      "time": "13:15",
      "points": 10,
      "icon": Icons.people_alt,
      "color": Color(0xFF8B5CF6),
      "pemberi": "Pak Rahman (Wali Kelas)",
    },
  ];

  final List<Map<String, dynamic>> akumulasiHistory = [
    {
      "periode": "Minggu ke-4 Juli 2025",
      "pelanggaran": -23,
      "apresiasi": 80,
      "total": 57,
      "status": "Aman",
      "date": "21-27 Jul 2025",
    },
    {
      "periode": "Minggu ke-3 Juli 2025",
      "pelanggaran": -15,
      "apresiasi": 25,
      "total": 10,
      "status": "Aman",
      "date": "14-20 Jul 2025",
    },
    {
      "periode": "Minggu ke-2 Juli 2025",
      "pelanggaran": -10,
      "apresiasi": 15,
      "total": 5,
      "status": "Aman",
      "date": "7-13 Jul 2025",
    },
    {
      "periode": "Minggu ke-1 Juli 2025",
      "pelanggaran": -8,
      "apresiasi": 20,
      "total": 12,
      "status": "Aman",
      "date": "30 Jun - 6 Jul 2025",
    },
  ];

  @override
  void initState() {
    super.initState();
    
    detailedStudent = {
      ...widget.student,
      "nis": "2023001",
      "ttl": "Bandung, 15 Mei 2007",
      "jenkel": "Laki-laki",
      "alamat": "Jl. Merdeka No. 123, Cimahi, Jawa Barat",
      "program_keahlian": "Rekayasa Perangkat Lunak",
      "kelas": "XI RPL 2",
      "tahun_masuk": "2023",
      "no_hp": "08123456789",
      "email": "ahmad.sudarji@smk.sch.id",
      "nama_ortu": "Budi Sudarji",
      "no_hp_ortu": "08129876543",
    };

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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Aman':
        return const Color(0xFF10B981);
      case 'Bermasalah':
        return const Color(0xFFEA580C);
      case 'Prioritas':
        return const Color(0xFFFF6B6D);
      default:
        return const Color(0xFF0083EE);
    }
  }

  List<Color> _getBackgroundGradient(String status) {
    if (status == 'Aman') {
      return [const Color(0xFF61B8FF), const Color(0xFF0083EE)];
    } else {
      return [const Color(0xFFFF6B6D), const Color(0xFFEA580C)];
    }
  }

  Color _getBackgroundShadowColor(String status) {
    if (status == 'Aman') {
      return const Color(0x200083EE);
    } else {
      return const Color(0x20FF6B6D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = _getBackgroundGradient(detailedStudent['status']);
    final shadowColor = _getBackgroundShadowColor(detailedStudent['status']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header dengan profil siswa
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: backgroundGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 20,
                        offset: const Offset(0, 10),
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
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            Text(
                              'Profil Siswa',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 40),
                          ],
                        ),
                        const SizedBox(height: 32),
                      
                        SlideTransition(
                          position: _slideAnimation,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Avatar
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEDBCC),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEA580C).withOpacity(0.2),
                                        blurRadius: 15,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Text(
                                      detailedStudent['name'][0].toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFFEA580C),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                
                                Text(
                                  detailedStudent['name'],
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                Text(
                                  '${detailedStudent['kelas']} - ${detailedStudent['program_keahlian']}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF374151),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(detailedStudent['status']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _getStatusColor(detailedStudent['status']).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(detailedStudent['status']),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${detailedStudent['status']}',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _getStatusColor(detailedStudent['status']),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          showPointPopup(context, detailedStudent['name']);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 14),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                                            ),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFF0083EE).withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.star_outline,
                                                color: Colors.white,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Berikan Poin',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (detailedStudent['status'] != 'Aman') ...[
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            showBKNotePopup(context, detailedStudent['name'] ?? 'Nama Siswa');
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [Color(0xFFFF6B6D), Color(0xFFEA580C)],
                                              ),
                                              borderRadius: BorderRadius.circular(16),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFF6B6D).withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.note_add_outlined,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Catatan BK',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Biodata Siswa
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Biodata Siswa',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildBiodataRow('NIS/NISN', detailedStudent['nis'], Icons.badge),
                        _buildBiodataRow('Tempat, Tanggal Lahir', detailedStudent['ttl'], Icons.cake),
                        _buildBiodataRow('Jenis Kelamin', detailedStudent['jenkel'], Icons.person),
                        _buildBiodataRow('Alamat', detailedStudent['alamat'], Icons.home),
                        _buildBiodataRow('Program Keahlian', detailedStudent['program_keahlian'], Icons.school),
                        _buildBiodataRow('Kelas', detailedStudent['kelas'], Icons.class_),
                        _buildBiodataRow('Tahun Masuk', detailedStudent['tahun_masuk'], Icons.calendar_today),
                        _buildBiodataRow('No. HP Siswa', detailedStudent['no_hp'], Icons.phone),
                        _buildBiodataRow('Email', detailedStudent['email'], Icons.email),
                        _buildBiodataRow('Nama Orang Tua', detailedStudent['nama_ortu'], Icons.family_restroom),
                        _buildBiodataRow('No. HP Orang Tua', detailedStudent['no_hp_ortu'], Icons.phone_android),
                      ],
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _buildTabButton('Pelanggaran', 0),
                        _buildTabButton('Apresiasi', 1),
                        _buildTabButton('Akumulasi', 2),
                      ],
                    ),
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: _buildTabContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBiodataRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFF0083EE).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: const Color(0xFF0083EE),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 50,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF0083EE) : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: isActive ? Colors.white : const Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTab) {
      case 0:
        return _buildPelanggaranContent();
      case 1:
        return _buildApresiasiContent();
      case 2:
        return _buildAkumulasiContent();
      default:
        return _buildPelanggaranContent();
    }
  }

  Widget _buildPelanggaranContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histori Poin Pelanggaran',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        if (pelanggaranHistory.isEmpty)
          _buildEmptyState('Belum ada riwayat pelanggaran', Icons.check_circle)
        else
          ...pelanggaranHistory.map((item) => _buildHistoryCard(item, isPelanggaran: true)).toList(),
      ],
    );
  }

  Widget _buildApresiasiContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histori Poin Apresiasi',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        if (apresiasiHistory.isEmpty)
          _buildEmptyState('Belum ada riwayat apresiasi', Icons.star)
        else
          ...apresiasiHistory.map((item) => _buildHistoryCard(item, isPelanggaran: false)).toList(),
      ],
    );
  }

  Widget _buildAkumulasiContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Histori Akumulasi Poin',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        
        ...akumulasiHistory.map((item) => _buildAkumulasiCard(item)).toList(),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, {required bool isPelanggaran}) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HistoryScreen(student: widget.student),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item['color'].withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: item['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item['icon'],
                    color: item['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Text(
                  '${item['points'] > 0 ? '+' : ''}${item['points']}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: item['color'],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: const Color(0xFF6B7280)),
                      const SizedBox(width: 8),
                      Text(
                        '${item['date']} • ${item['time']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.person, size: 16, color: const Color(0xFF6B7280)),
                      const SizedBox(width: 8),
                      Text(
                        isPelanggaran ? 'Pelapor: ${item['pelapor']}' : 'Pemberi: ${item['pemberi']}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAkumulasiCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(item['status']).withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['periode'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['date'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(item['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item['status'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(item['status']),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6D).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFF6B6D).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_down,
                        color: const Color(0xFFFF6B6D),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Pelanggaran',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFFF6B6D),
                        ),
                      ),
                      Text(
                        '${item['pelanggaran']}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFFF6B6D),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: const Color(0xFF10B981),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Apresiasi',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        '+${item['apresiasi']}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0083EE).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0083EE).withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.calculate,
                        color: const Color(0xFF0083EE),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0083EE),
                        ),
                      ),
                      Text(
                        '${item['total'] > 0 ? '+' : ''}${item['total']}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0083EE),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Stack(
              children: [
                if (item['pelanggaran'] < 0)
                  Container(
                    width: (item['pelanggaran'].abs() / (item['apresiasi'] + item['pelanggaran'].abs())) * MediaQuery.of(context).size.width,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6B6D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: (item['apresiasi'] / (item['apresiasi'] + item['pelanggaran'].abs())) * MediaQuery.of(context).size.width,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
              ),
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0083EE).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}