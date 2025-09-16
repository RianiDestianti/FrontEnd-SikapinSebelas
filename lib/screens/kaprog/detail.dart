import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  List<HistoryItem> pelanggaranHistory = [];
  List<HistoryItem> apresiasiHistory = [];
  List<AkumulasiItem> akumulasiHistory = [];
  bool _isLoading = true;
  List<dynamic> aspekPenilaianData = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _fetchStudentDetails();
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

  Future<void> _fetchStudentDetails() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final aspekResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/aspekpenilaian'),
      );
      if (aspekResponse.statusCode == 200) {
        final aspekJson = jsonDecode(aspekResponse.body);
        if (aspekJson['success']) {
          aspekPenilaianData = aspekJson['data'];
        }
      } else {
        throw Exception('Failed to load aspek penilaian');
      }

      final nis = widget.student['nis'].toString();
      final skoringPelanggaranResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/skoring_pelanggaran?nis=$nis'),
      );
      final skoringPenghargaanResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/skoring_penghargaan?nis=$nis'),
      );
      final peringatanResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/peringatan'),
      );
      final penghargaanResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/Penghargaan'),
      );
      final akumulasiResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/akumulasi'),
      );

      if (skoringPelanggaranResponse.statusCode == 200 &&
          skoringPenghargaanResponse.statusCode == 200 &&
          peringatanResponse.statusCode == 200 &&
          penghargaanResponse.statusCode == 200 &&
          akumulasiResponse.statusCode == 200) {
        final pelanggaranData = jsonDecode(skoringPelanggaranResponse.body);
        final penghargaanData = jsonDecode(skoringPenghargaanResponse.body);
        final peringatanData = jsonDecode(peringatanResponse.body);
        final penghargaanList = jsonDecode(penghargaanResponse.body);
        final akumulasiData = jsonDecode(akumulasiResponse.body);

        final pelanggaranList = pelanggaranData['penilaian']['data'] as List;
        final penghargaanPenilaianList =
            penghargaanData['penilaian']['data'] as List;
        final peringatanList = peringatanData['data'] as List;
        final penghargaanItems = penghargaanList['data'] as List;
        final siswaList = akumulasiData['data']['data'] as List;

        final studentData = siswaList.firstWhere(
          (s) => s['nis'].toString() == nis,
          orElse: () => widget.student,
        );

        pelanggaranHistory =
            pelanggaranList
                .where((p) => p['nis'].toString() == nis)
                .map((p) {
                  final aspek = aspekPenilaianData.firstWhere(
                    (a) => a['id_aspekpenilaian'] == p['id_aspekpenilaian'],
                    orElse: () => {},
                  );
                  if (aspek['jenis_poin'] != 'Pelanggaran') return null;

                  final evalDate = DateTime.parse(
                    p['created_at'].substring(0, 10),
                  );
                  final matchingPeringatan = peringatanList.firstWhere((v) {
                    final violationDate = DateTime.parse(v['tanggal_sp']);
                    return (violationDate.difference(evalDate).inDays.abs() <=
                            2) ||
                        v['alasan'].toLowerCase().contains(
                          aspek['uraian']?.toLowerCase() ?? '',
                        );
                  }, orElse: () => null);

                  if (matchingPeringatan == null) return null;

                  return HistoryItem(
                    type: matchingPeringatan['level_sp'],
                    description:
                        aspek['uraian'] ??
                        matchingPeringatan['alasan'] ??
                        'Tidak ada deskripsi',
                    date: matchingPeringatan['tanggal_sp'],
                    time: p['created_at'].split(' ')[1].substring(0, 5),
                    points:
                        -(aspek['indikator_poin'] ??
                            (matchingPeringatan['level_sp'] == 'SP1'
                                ? 10
                                : matchingPeringatan['level_sp'] == 'SP2'
                                ? 20
                                : 30)),
                    icon: Icons.warning,
                    color: const Color(0xFFFF6B6D),
                  );
                })
                .whereType<HistoryItem>()
                .toList();

        apresiasiHistory =
            penghargaanPenilaianList
                .where((p) => p['nis'].toString() == nis)
                .map((p) {
                  final aspek = aspekPenilaianData.firstWhere(
                    (a) => a['id_aspekpenilaian'] == p['id_aspekpenilaian'],
                    orElse: () => {},
                  );
                  if (aspek['jenis_poin'] != 'Apresiasi') return null;

                  final evalDate = DateTime.parse(
                    p['created_at'].substring(0, 10),
                  );
                  final matchingPenghargaan = penghargaanItems.firstWhere((a) {
                    final appreciationDate = DateTime.parse(
                      a['tanggal_penghargaan'],
                    );
                    return (appreciationDate
                                .difference(evalDate)
                                .inDays
                                .abs() <=
                            2) ||
                        a['alasan'].toLowerCase().contains(
                          aspek['uraian']?.toLowerCase() ?? '',
                        );
                  }, orElse: () => null);

                  if (matchingPenghargaan == null) return null;

                  return HistoryItem(
                    type: matchingPenghargaan['level_penghargaan'],
                    description:
                        aspek['uraian'] ??
                        matchingPenghargaan['alasan'] ??
                        'Tidak ada deskripsi',
                    date: matchingPenghargaan['tanggal_penghargaan'],
                    time: p['created_at'].split(' ')[1].substring(0, 5),
                    points:
                        aspek['indikator_poin'] ??
                        (matchingPenghargaan['level_penghargaan'] == 'PH1'
                            ? 10
                            : matchingPenghargaan['level_penghargaan'] == 'PH2'
                            ? 20
                            : 30),
                    icon: Icons.star,
                    color: const Color(0xFF10B981),
                  );
                })
                .whereType<HistoryItem>()
                .toList();

        int totalApresiasiPoints = studentData['poin_apresiasi'] ?? 0;
        int totalPelanggaranPoints =
            studentData['poin_pelanggaran']?.abs() ?? 0;
        int totalPoints = studentData['poin_total'] ?? 0;
        String status =
            totalPoints >= 0
                ? 'Aman'
                : totalPoints >= -20
                ? 'Bermasalah'
                : 'Prioritas';

        akumulasiHistory = [
          AkumulasiItem(
            periode: 'Semester Ganjil 2025/2026',
            pelanggaran: totalPelanggaranPoints,
            apresiasi: totalApresiasiPoints,
            total: totalPoints,
            status: status,
            date: '2025-09-01 - 2025-12-31',
          ),
        ];

        setState(() {
          detailedStudent = {
            'nis': studentData['nis'].toString(),
            'name': studentData['nama_siswa'] ?? widget.student['name'],
            'id_kelas': studentData['id_kelas'] ?? widget.student['id_kelas'],
            'status': status,
            'poin_apresiasi': totalApresiasiPoints,
            'poin_pelanggaran': totalPelanggaranPoints,
            'poin_total': totalPoints,
            'program_keahlian': _getJurusanFullName(studentData['id_kelas']),
            'kelas':
                (akumulasiData['kelas_list'] as List).firstWhere(
                  (k) => k['id_kelas'] == studentData['id_kelas'],
                  orElse:
                      () => {
                        'nama_kelas':
                            widget.student['kelas'] ?? 'Tidak diketahui',
                      },
                )['nama_kelas'],
          };
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching student details: $e');
      setState(() {
        detailedStudent = {
          ...widget.student,
          'nis': widget.student['nis'].toString(),
          'poin_apresiasi': widget.student['poinApresiasi'] ?? 0,
          'poin_pelanggaran': widget.student['poinPelanggaran']?.abs() ?? 0,
          'poin_total': widget.student['points'] ?? 0,
          'program_keahlian': _getJurusanFullName(widget.student['id_kelas']),
          'kelas': widget.student['kelas'] ?? 'Tidak diketahui',
        };
        _isLoading = false;
      });
    }
  }

  String _getJurusanFullName(String? idKelas) {
    const jurusanNames = {
      'RPL': 'Rekayasa Perangkat Lunak',
      'DKV': 'Desain Komunikasi Visual',
      'TKJ': 'Teknik Komputer dan Jaringan',
    };
    if (idKelas == null) return 'Tidak diketahui';
    final jurusan = idKelas.substring(0, 3);
    return jurusanNames[jurusan] ?? jurusan;
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
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final backgroundGradient = _getBackgroundGradient(
      detailedStudent['status'],
    );
    final shadowColor = _getBackgroundShadowColor(detailedStudent['status']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
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
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Profil Siswa',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _fetchStudentDetails,
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.refresh,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  HistoryItem({
    required this.type,
    required this.description,
    required this.date,
    required this.time,
    required this.points,
    required this.icon,
    required this.color,
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
              label: 'Nama Siswa',
              value: student['name'],
              icon: Icons.person,
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
              label: 'Poin Apresiasi',
              value: student['poin_apresiasi'].toString(),
              icon: Icons.star,
            ),
            BiodataRow(
              label: 'Poin Pelanggaran',
              value: student['poin_pelanggaran'].toString(),
              icon: Icons.warning,
            ),
            BiodataRow(
              label: 'Poin Total',
              value: student['poin_total'].toString(),
              icon: Icons.calculate,
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
  final bool isPelanggaran;

  const HistoryDetails({
    Key? key,
    required this.date,
    required this.time,
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
            ? (pelanggaran.abs() / total) *
                (MediaQuery.of(context).size.width - 80)
            : 0.0;
    final apresiasiWidth =
        total > 0
            ? (apresiasi / total) * (MediaQuery.of(context).size.width - 80)
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
          if (pelanggaran > 0)
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
