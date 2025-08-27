import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/kaprog/history.dart';

class KaprogDetailScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const KaprogDetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<KaprogDetailScreen> createState() => _KaprogDetailScreenState();
}

class _KaprogDetailScreenState extends State<KaprogDetailScreen>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  int _selectedTab = 0;
  late Map<String, dynamic> detailedStudent;

  final List<HistoryItem> pelanggaranHistory = [
    HistoryItem(
      type: "Pelanggaran Kedisiplinan",
      description: "Terlambat masuk kelas lebih dari 15 menit",
      date: "20 Jul 2025",
      time: "07:30",
      points: -10,
      icon: Icons.access_time,
      color: Color(0xFFFF6B6D),
      pelapor: "Pak Budi (Guru Piket)",
    ),
    HistoryItem(
      type: "Pelanggaran Pakaian",
      description: "Tidak memakai seragam sesuai ketentuan",
      date: "18 Jul 2025",
      time: "07:00",
      points: -5,
      icon: Icons.checkroom,
      color: Color(0xFFEA580C),
      pelapor: "Bu Sari (Guru BK)",
    ),
    HistoryItem(
      type: "Pelanggaran Tugas",
      description: "Tidak mengumpulkan tugas matematika",
      date: "15 Jul 2025",
      time: "10:30",
      points: -8,
      icon: Icons.assignment_late,
      color: Color(0xFFFF6B6D),
      pelapor: "Bu Ani (Guru Matematika)",
    ),
  ];

  final List<HistoryItem> apresiasiHistory = [
    HistoryItem(
      type: "Prestasi Akademik",
      description: "Juara 1 Olimpiade Matematika Tingkat Kota",
      date: "22 Jul 2025",
      time: "14:00",
      points: 30,
      icon: Icons.emoji_events,
      color: Color(0xFFFFD700),
      pemberi: "Kepala Sekolah",
    ),
    HistoryItem(
      type: "Prestasi Non-Akademik",
      description: "Juara 2 Lomba Coding Regional",
      date: "19 Jul 2025",
      time: "16:30",
      points: 25,
      icon: Icons.code,
      color: Color(0xFF10B981),
      pemberi: "Pak Dedi (Guru Produktif)",
    ),
    HistoryItem(
      type: "Kegiatan Sosial",
      description: "Membantu kegiatan bakti sosial sekolah",
      date: "16 Jul 2025",
      time: "08:00",
      points: 15,
      icon: Icons.volunteer_activism,
      color: Color(0xFF0EA5E9),
      pemberi: "Bu Lisa (Guru OSIS)",
    ),
    HistoryItem(
      type: "Sikap Positif",
      description: "Membantu teman yang kesulitan belajar",
      date: "14 Jul 2025",
      time: "13:15",
      points: 10,
      icon: Icons.people_alt,
      color: Color(0xFF8B5CF6),
      pemberi: "Pak Rahman (Wali Kelas)",
    ),
  ];

  final List<AkumulasiItem> akumulasiHistory = [
    AkumulasiItem(
      periode: "Minggu ke-4 Juli 2025",
      pelanggaran: -23,
      apresiasi: 80,
      total: 57,
      status: "Aman",
      date: "21-27 Jul 2025",
    ),
    AkumulasiItem(
      periode: "Minggu ke-3 Juli 2025",
      pelanggaran: -15,
      apresiasi: 25,
      total: 10,
      status: "Aman",
      date: "14-20 Jul 2025",
    ),
    AkumulasiItem(
      periode: "Minggu ke-2 Juli 2025",
      pelanggaran: -10,
      apresiasi: 15,
      total: 5,
      status: "Aman",
      date: "7-13 Jul 2025",
    ),
    AkumulasiItem(
      periode: "Minggu ke-1 Juli 2025",
      pelanggaran: -8,
      apresiasi: 20,
      total: 12,
      status: "Aman",
      date: "30 Jun - 6 Jul 2025",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeStudentData();
    _initializeAnimations();
  }

  void _initializeStudentData() {
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
  }

  void _initializeAnimations() {
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
    return status == 'Aman'
        ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
        : [const Color(0xFFFF6B6D), const Color(0xFFEA580C)];
  }

  Color _getBackgroundShadowColor(String status) {
    return status == 'Aman' ? const Color(0x200083EE) : const Color(0x20FF6B6D);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundGradient = _getBackgroundGradient(
      detailedStudent['status'],
    );
    final shadowColor = _getBackgroundShadowColor(detailedStudent['status']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
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
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).padding.top + 20,
                        ),

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
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEDBCC),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFEA580C,
                                        ).withOpacity(0.2),
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
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      detailedStudent['status'],
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _getStatusColor(
                                        detailedStudent['status'],
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(
                                            detailedStudent['status'],
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        detailedStudent['status'],
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: _getStatusColor(
                                            detailedStudent['status'],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                BiodataSection(student: detailedStudent),

                TabSection(
                  selectedTab: _selectedTab,
                  onTabSelected:
                      (index) => setState(() => _selectedTab = index),
                ),

                TabContentSection(
                  selectedTab: _selectedTab,
                  pelanggaranHistory: pelanggaranHistory,
                  apresiasiHistory: apresiasiHistory,
                  akumulasiHistory: akumulasiHistory,
                  student: detailedStudent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HistoryItem {
  final String type;
  final String description;
  final String date;
  final String time;
  final int points;
  final IconData icon;
  final Color color;
  final String? pelapor;
  final String? pemberi;

  HistoryItem({
    required this.type,
    required this.description,
    required this.date,
    required this.time,
    required this.points,
    required this.icon,
    required this.color,
    this.pelapor,
    this.pemberi,
  });
}

class AkumulasiItem {
  final String periode;
  final int pelanggaran;
  final int apresiasi;
  final int total;
  final String status;
  final String date;

  AkumulasiItem({
    required this.periode,
    required this.pelanggaran,
    required this.apresiasi,
    required this.total,
    required this.status,
    required this.date,
  });
}

class BiodataSection extends StatelessWidget {
  final Map<String, dynamic> student;

  const BiodataSection({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            BiodataRow(
              label: 'NIS/NISN',
              value: student['nis'],
              icon: Icons.badge,
            ),
            BiodataRow(
              label: 'Tempat, Tanggal Lahir',
              value: student['ttl'],
              icon: Icons.cake,
            ),
            BiodataRow(
              label: 'Jenis Kelamin',
              value: student['jenkel'],
              icon: Icons.person,
            ),
            BiodataRow(
              label: 'Alamat',
              value: student['alamat'],
              icon: Icons.home,
            ),
            BiodataRow(
              label: 'Program Keahlian',
              value: student['program_keahlian'],
              icon: Icons.school,
            ),
            BiodataRow(
              label: 'Kelas',
              value: student['kelas'],
              icon: Icons.class_,
            ),
            BiodataRow(
              label: 'Tahun Masuk',
              value: student['tahun_masuk'],
              icon: Icons.calendar_today,
            ),
            BiodataRow(
              label: 'No. HP Siswa',
              value: student['no_hp'],
              icon: Icons.phone,
            ),
            BiodataRow(
              label: 'Email',
              value: student['email'],
              icon: Icons.email,
            ),
            BiodataRow(
              label: 'Nama Orang Tua',
              value: student['nama_ortu'],
              icon: Icons.family_restroom,
            ),
            BiodataRow(
              label: 'No. HP Orang Tua',
              value: student['no_hp_ortu'],
              icon: Icons.phone_android,
            ),
          ],
        ),
      ),
    );
  }
}

class BiodataRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const BiodataRow({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, size: 16, color: const Color(0xFF0083EE)),
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
}

class TabSection extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabSelected;

  const TabSection({
    Key? key,
    required this.selectedTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
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
            TabButton(
              text: 'Pelanggaran',
              index: 0,
              isActive: selectedTab == 0,
              onTap: onTabSelected,
            ),
            TabButton(
              text: 'Apresiasi',
              index: 1,
              isActive: selectedTab == 1,
              onTap: onTabSelected,
            ),
            TabButton(
              text: 'Akumulasi',
              index: 2,
              isActive: selectedTab == 2,
              onTap: onTabSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isActive;
  final Function(int) onTap;

  const TabButton({
    Key? key,
    required this.text,
    required this.index,
    required this.isActive,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
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
}

class TabContentSection extends StatelessWidget {
  final int selectedTab;
  final List<HistoryItem> pelanggaranHistory;
  final List<HistoryItem> apresiasiHistory;
  final List<AkumulasiItem> akumulasiHistory;
  final Map<String, dynamic> student;

  const TabContentSection({
    Key? key,
    required this.selectedTab,
    required this.pelanggaranHistory,
    required this.apresiasiHistory,
    required this.akumulasiHistory,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child:
          selectedTab == 0
              ? PelanggaranContent(
                history: pelanggaranHistory,
                student: student,
              )
              : selectedTab == 1
              ? ApresiasiContent(history: apresiasiHistory, student: student)
              : AkumulasiContent(history: akumulasiHistory),
    );
  }
}

class PelanggaranContent extends StatelessWidget {
  final List<HistoryItem> history;
  final Map<String, dynamic> student;

  const PelanggaranContent({
    Key? key,
    required this.history,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        history.isEmpty
            ? const EmptyState(
              message: 'Belum ada riwayat pelanggaran',
              icon: Icons.check_circle,
            )
            : Column(
              children:
                  history
                      .map(
                        (item) => KaprogHistoryCard(
                          item: item,
                          isPelanggaran: true,
                          student: student,
                        ),
                      )
                      .toList(),
            ),
      ],
    );
  }
}

class ApresiasiContent extends StatelessWidget {
  final List<HistoryItem> history;
  final Map<String, dynamic> student;

  const ApresiasiContent({
    Key? key,
    required this.history,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        history.isEmpty
            ? const EmptyState(
              message: 'Belum ada riwayat apresiasi',
              icon: Icons.star,
            )
            : Column(
              children:
                  history
                      .map(
                        (item) => KaprogHistoryCard(
                          item: item,
                          isPelanggaran: false,
                          student: student,
                        ),
                      )
                      .toList(),
            ),
      ],
    );
  }
}

class KaprogHistoryCard extends StatelessWidget {
  final HistoryItem item;
  final bool isPelanggaran;
  final Map<String, dynamic> student;

  const KaprogHistoryCard({
    Key? key,
    required this.item,
    required this.isPelanggaran,
    required this.student,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KaprogHistoryScreen(student: student),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: item.color.withOpacity(0.2), width: 2),
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
                    color: item.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(item.icon, color: item.color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.type,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.description,
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
                  '${item.points > 0 ? '+' : ''}${item.points}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: item.color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            HistoryDetails(
              date: item.date,
              time: item.time,
              pelapor: item.pelapor,
              pemberi: item.pemberi,
              isPelanggaran: isPelanggaran,
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryDetails extends StatelessWidget {
  final String date;
  final String time;
  final String? pelapor;
  final String? pemberi;
  final bool isPelanggaran;

  const HistoryDetails({
    Key? key,
    required this.date,
    required this.time,
    this.pelapor,
    this.pemberi,
    required this.isPelanggaran,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              const Icon(
                Icons.calendar_today,
                size: 16,
                color: Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                '$date • $time',
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
              const Icon(Icons.person, size: 16, color: Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                isPelanggaran
                    ? 'Pelapor: ${pelapor ?? ''}'
                    : 'Pemberi: ${pemberi ?? ''}',
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
    );
  }
}

class AkumulasiContent extends StatelessWidget {
  final List<AkumulasiItem> history;

  const AkumulasiContent({Key? key, required this.history}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
        Column(
          children: history.map((item) => AkumulasiCard(item: item)).toList(),
        ),
      ],
    );
  }
}

class AkumulasiCard extends StatelessWidget {
  final AkumulasiItem item;

  const AkumulasiCard({Key? key, required this.item}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(item.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.2), width: 2),
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
                      item.periode,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.date,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              StatusTag(status: item.status, statusColor: statusColor),
            ],
          ),
          const SizedBox(height: 16),
          PointSummary(
            pelanggaran: item.pelanggaran,
            apresiasi: item.apresiasi,
            total: item.total,
          ),
          const SizedBox(height: 12),
          PointProgressBar(
            pelanggaran: item.pelanggaran,
            apresiasi: item.apresiasi,
          ),
        ],
      ),
    );
  }
}

class StatusTag extends StatelessWidget {
  final String status;
  final Color statusColor;

  const StatusTag({Key? key, required this.status, required this.statusColor})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: statusColor,
        ),
      ),
    );
  }
}

class PointSummary extends StatelessWidget {
  final int pelanggaran;
  final int apresiasi;
  final int total;

  const PointSummary({
    Key? key,
    required this.pelanggaran,
    required this.apresiasi,
    required this.total,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PointCard(
          title: 'Pelanggaran',
          value: '$pelanggaran',
          icon: Icons.trending_down,
          color: const Color(0xFFFF6B6D),
        ),
        const SizedBox(width: 12),
        PointCard(
          title: 'Apresiasi',
          value: '+$apresiasi',
          icon: Icons.trending_up,
          color: const Color(0xFF10B981),
        ),
        const SizedBox(width: 12),
        PointCard(
          title: 'Total',
          value: '${total > 0 ? '+' : ''}$total',
          icon: Icons.calculate,
          color: const Color(0xFF0083EE),
        ),
      ],
    );
  }
}

class PointCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const PointCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PointProgressBar extends StatelessWidget {
  final int pelanggaran;
  final int apresiasi;

  const PointProgressBar({
    Key? key,
    required this.pelanggaran,
    required this.apresiasi,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final total = pelanggaran.abs() + apresiasi;
    final pelanggaranWidth =
        total > 0
            ? (pelanggaran.abs() / total) * MediaQuery.of(context).size.width
            : 0.0;
    final apresiasiWidth =
        total > 0
            ? (apresiasi / total) * MediaQuery.of(context).size.width
            : 0.0;

    return Container(
      width: double.infinity,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Stack(
        children: [
          if (pelanggaran < 0)
            Container(
              width: pelanggaranWidth,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B6D),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: apresiasiWidth,
              height: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyState({Key? key, required this.message, required this.icon})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
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
