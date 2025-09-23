import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/profile.dart';
import 'package:skoring/screens/kaprog/chart.dart';
import 'package:skoring/screens/kaprog/activity.dart';
import 'package:skoring/screens/kaprog/student.dart';
import 'package:skoring/screens/kaprog/report.dart';
import 'detail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class Student {
  final String name;
  final String kelas;
  final int poin;
  final String prestasi;
  final IconData avatar;
  final int rank;
  final String status;
  final String nis;
  final String ttl;
  final String jenkel;
  final String alamat;
  final String programKeahlian;
  final String tahunMasuk;
  final String noHp;
  final String email;
  final String namaOrtu;
  final String noHpOrtu;

  Student({
    required this.name,
    required this.kelas,
    required this.poin,
    required this.prestasi,
    required this.avatar,
    required this.rank,
    required this.status,
    required this.nis,
    required this.ttl,
    required this.jenkel,
    required this.alamat,
    required this.programKeahlian,
    required this.tahunMasuk,
    required this.noHp,
    required this.email,
    required this.namaOrtu,
    required this.noHpOrtu,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      name: json['nama_siswa'] as String? ?? 'Unknown',
      kelas: json['id_kelas'] as String? ?? 'Unknown',
      poin: (json['poin_total'] as int?) ?? 0,
      prestasi: json['prestasi'] as String? ?? '',
      avatar: Icons.person,
      rank: (json['rank'] as int?) ?? 0,
      status: ((json['poin_total'] as int?) ?? 0) < 0 ? 'Bermasalah' : 'Aman',
      nis: json['nis']?.toString() ?? '',
      ttl: json['ttl'] as String? ?? '',
      jenkel: json['jenkel'] as String? ?? '',
      alamat: json['alamat'] as String? ?? '',
      programKeahlian: json['program_keahlian'] as String? ?? '',
      tahunMasuk: json['tahun_masuk'] as String? ?? '',
      noHp: json['no_hp'] as String? ?? '',
      email: json['email'] as String? ?? '',
      namaOrtu: json['nama_ortu'] as String? ?? '',
      noHpOrtu: json['no_hp_ortu'] as String? ?? '',
    );
  }

  Student copyWith({
    String? name,
    String? kelas,
    int? poin,
    String? prestasi,
    IconData? avatar,
    int? rank,
    String? status,
    String? nis,
    String? ttl,
    String? jenkel,
    String? alamat,
    String? programKeahlian,
    String? tahunMasuk,
    String? noHp,
    String? email,
    String? namaOrtu,
    String? noHpOrtu,
  }) {
    return Student(
      name: name ?? this.name,
      kelas: kelas ?? this.kelas,
      poin: poin ?? this.poin,
      prestasi: prestasi ?? this.prestasi,
      avatar: avatar ?? this.avatar,
      rank: rank ?? this.rank,
      status: status ?? this.status,
      nis: nis ?? this.nis,
      ttl: ttl ?? this.ttl,
      jenkel: jenkel ?? this.jenkel,
      alamat: alamat ?? this.alamat,
      programKeahlian: programKeahlian ?? this.programKeahlian,
      tahunMasuk: tahunMasuk ?? this.tahunMasuk,
      noHp: noHp ?? this.noHp,
      email: email ?? this.email,
      namaOrtu: namaOrtu ?? this.namaOrtu,
      noHpOrtu: noHpOrtu ?? this.noHpOrtu,
    );
  }
}

class KaprogHomeScreen extends StatefulWidget {
  const KaprogHomeScreen({Key? key}) : super(key: key);

  @override
  State<KaprogHomeScreen> createState() => _KaprogHomeScreenState();
}

class _KaprogHomeScreenState extends State<KaprogHomeScreen>
    with TickerProviderStateMixin {
  int _selectedTab = 0;
  int _apresiasiChartTab = 0;
  int _pelanggaranChartTab = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _searchQuery = '';
  List<Student> _filteredSiswaTerbaik = [];
  List<Student> _filteredSiswaBerat = [];
  String _kaprogName = 'Kaprog';
  List<Student> _siswaTerbaik = [];
  List<Student> _siswaBerat = [];
  List<String> _jurusanList = [];
  List<Map<String, dynamic>> _apresiasiData = [];
  List<Map<String, dynamic>> _pelanggaranData = [];
  List<Map<String, dynamic>> _activityData = [];

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
    _loadKaprogData();
    _loadLocalActivityData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadKaprogData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _kaprogName = prefs.getString('name') ?? 'Kaprog';
    });
    await _fetchStudentData();
  }

  Future<void> _loadLocalActivityData() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activities = prefs.getStringList('kaprog_activities') ?? [];

    setState(() {
      _activityData =
          activities.asMap().entries.map((entry) {
              int index = entry.key;
              String activity = entry.value;
              List<String> parts = activity.split('|');
              return {
                'type': parts[0],
                'title': parts[1],
                'subtitle': parts[2],
                'time': parts[3],
                'timeObj': DateTime.parse(parts[3]),
                'badge': 'SELESAI',
                'badgeColor':
                    parts[0] == 'Penghargaan'
                        ? const Color(0xFF10B981)
                        : parts[0] == 'Pelanggaran'
                        ? const Color(0xFFFF6B6D)
                        : const Color(0xFF0083EE),
                'icon':
                    parts[0] == 'Penghargaan'
                        ? Icons.emoji_events_outlined
                        : parts[0] == 'Pelanggaran'
                        ? Icons.report_problem_outlined
                        : Icons.assessment_outlined,
                'gradient': LinearGradient(
                  colors:
                      parts[0] == 'Penghargaan'
                          ? [const Color(0xFF10B981), const Color(0xFF34D399)]
                          : parts[0] == 'Pelanggaran'
                          ? [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]
                          : [const Color(0xFF61B8FF), const Color(0xFF0083EE)],
                ),
              };
            }).toList()
            ..sort(
              (a, b) => (b['timeObj'] as DateTime).compareTo(
                a['timeObj'] as DateTime,
              ),
            );
    });
  }

  Future<void> _addLocalActivity(
    String type,
    String title,
    String subtitle,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> activities = prefs.getStringList('kaprog_activities') ?? [];
    String time = DateTime.now().toString().split('.')[0];
    String activity = '$type|$title|$subtitle|$time';
    activities.insert(0, activity);
    if (activities.length > 10) {
      activities = activities.sublist(0, 10);
    }
    await prefs.setStringList('kaprog_activities', activities);
    await _loadLocalActivityData();
  }

  String _formatTime(String dateStr) {
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('HH:mm').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _fetchStudentData() async {
    try {
      final response = await http.get(
        Uri.parse('http://sikapin.student.smkn11bdg.sch.id/api/akumulasi'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final studentList =
            (data['data']['data'] as List<dynamic>? ?? [])
                .map((json) => Student.fromJson(json as Map<String, dynamic>))
                .toList();
        final jurusanList =
            (data['jurusan_list'] as List<dynamic>? ?? [])
                .map((j) => j as String)
                .toList();

        _siswaTerbaik =
            studentList.where((s) => s.poin >= 0).toList()
              ..sort((a, b) => b.poin.compareTo(a.poin));
        _siswaTerbaik = _siswaTerbaik.take(4).toList();
        for (int i = 0; i < _siswaTerbaik.length; i++) {
          _siswaTerbaik[i] = _siswaTerbaik[i].copyWith(rank: i + 1);
        }

        _siswaBerat =
            studentList.where((s) => s.poin < 0).toList()
              ..sort((a, b) => a.poin.compareTo(b.poin));
        _siswaBerat = _siswaBerat.take(4).toList();
        for (int i = 0; i < _siswaBerat.length; i++) {
          _siswaBerat[i] = _siswaBerat[i].copyWith(rank: i + 1);
        }

        _jurusanList = jurusanList;
        _apresiasiData =
            _jurusanList.map((jurusan) {
              final totalPoin = studentList
                  .where((s) => s.kelas.startsWith(jurusan))
                  .fold<double>(
                    0,
                    (sum, s) =>
                        sum + ((s.poin > 0 ? s.poin : 0) as num).toDouble(),
                  );
              return {'value': totalPoin, 'label': jurusan};
            }).toList();

        _pelanggaranData =
            _jurusanList.map((jurusan) {
              final totalPoin = studentList
                  .where((s) => s.kelas.startsWith(jurusan))
                  .fold<double>(
                    0,
                    (sum, s) =>
                        sum + ((s.poin < 0 ? -s.poin : 0) as num).toDouble(),
                  );
              return {'value': totalPoin, 'label': jurusan};
            }).toList();

        setState(() {
          _filteredSiswaTerbaik = _siswaTerbaik;
          _filteredSiswaBerat = _siswaBerat;
        });

        await _addLocalActivity(
          'Sistem',
          'Data Diperbarui',
          'Melakukan refresh data siswa dan jurusan',
        );
      } else {
        throw Exception('Failed to load student data: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _filteredSiswaTerbaik = [];
        _filteredSiswaBerat = [];
        _jurusanList = [];
        _apresiasiData = [];
        _pelanggaranData = [];
      });
      print('Error fetching student data: $e');
      await _addLocalActivity(
        'Error',
        'Gagal Memuat Data',
        'Terjadi kesalahan saat memuat data: $e',
      );
    }
  }

  void _filterSiswa(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredSiswaTerbaik = _siswaTerbaik;
        _filteredSiswaBerat = _siswaBerat;
      } else {
        final searchLower = query.toLowerCase();
        _filteredSiswaTerbaik =
            _siswaTerbaik.where((siswa) {
              final namaLower = siswa.name.toLowerCase();
              final kelasLower = siswa.kelas.toLowerCase();
              final prestasiLower = siswa.prestasi.toLowerCase();
              return namaLower.contains(searchLower) ||
                  kelasLower.contains(searchLower) ||
                  prestasiLower.contains(searchLower);
            }).toList();
        _filteredSiswaBerat =
            _siswaBerat.where((siswa) {
              final namaLower = siswa.name.toLowerCase();
              final kelasLower = siswa.kelas.toLowerCase();
              final prestasiLower = siswa.prestasi.toLowerCase();
              return namaLower.contains(searchLower) ||
                  kelasLower.contains(searchLower) ||
                  prestasiLower.contains(searchLower);
            }).toList();
      }
    });

    if (query.isNotEmpty) {
      _addLocalActivity(
        'Pencarian',
        'Pencarian Siswa',
        'Melakukan pencarian: $query',
      );
    }
  }

  void _navigateToDetailScreen(Student siswa) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => KaprogDetailScreen(
              student: {
                'name': siswa.name,
                'status': siswa.status,
                'nis': siswa.nis,
                'ttl': siswa.ttl,
                'jenkel': siswa.jenkel,
                'alamat': siswa.alamat,
                'program_keahlian': siswa.programKeahlian,
                'kelas': siswa.kelas,
                'tahun_masuk': siswa.tahunMasuk,
                'no_hp': siswa.noHp,
                'email': siswa.email,
                'nama_ortu': siswa.namaOrtu,
                'no_hp_ortu': siswa.noHpOrtu,
              },
            ),
      ),
    ).then((_) {
      _addLocalActivity(
        'Navigasi',
        'Detail Siswa',
        'Mengakses detail siswa: ${siswa.name}',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 768;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth;
            if (maxWidth > 600) maxWidth = 600;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
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
                            padding: EdgeInsets.fromLTRB(
                              24,
                              MediaQuery.of(context).padding.top + 20,
                              24,
                              32,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                        _addLocalActivity(
                                          'Navigasi',
                                          'Kembali',
                                          'Kembali ke halaman sebelumnya',
                                        );
                                      },
                                      child: Container(
                                        width: isTablet ? 48 : 40,
                                        height: isTablet ? 48 : 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Colors.white,
                                          size: isTablet ? 20 : 18,
                                        ),
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await _fetchStudentData();
                                            _addLocalActivity(
                                              'Sistem',
                                              'Refresh Data',
                                              'Melakukan refresh halaman',
                                            );
                                          },
                                          child: Container(
                                            width: isTablet ? 48 : 40,
                                            height: isTablet ? 48 : 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Icon(
                                              Icons.refresh_rounded,
                                              color: Colors.white,
                                              size: isTablet ? 26 : 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder:
                                                    (context) =>
                                                        const ProfileScreen(),
                                              ),
                                            ).then((_) {
                                              _addLocalActivity(
                                                'Navigasi',
                                                'Profil',
                                                'Mengakses halaman profil',
                                              );
                                            });
                                          },
                                          child: Container(
                                            width: isTablet ? 48 : 40,
                                            height: isTablet ? 48 : 40,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.1),
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
                                  ],
                                ),
                                const SizedBox(height: 24),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hello, $_kaprogName! 👋',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Kelola semua jurusan dengan optimal',
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
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
                                            colors: [
                                              Color(0xFF61B8FF),
                                              Color(0xFF0083EE),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            30,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: TextField(
                                          onChanged: _filterSiswa,
                                          decoration: InputDecoration(
                                            hintText:
                                                'Cari siswa, kelas, atau aktivitas...',
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
                                    _buildActionButton('Terbaik', 2),
                                    const SizedBox(width: 10),
                                    _buildActionButton('Berat', 3),
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
                              if (_selectedTab == 2) ...[
                                _buildSiswaTerbaikSection(),
                                const SizedBox(height: 20),
                              ] else if (_selectedTab == 3) ...[
                                _buildSiswaBeratSection(),
                                const SizedBox(height: 20),
                              ] else ...[
                                _buildEnhancedChartCard(
                                  'Grafik Apresiasi Siswa',
                                  'Pencapaian positif per jurusan',
                                  Icons.trending_up,
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFF61B8FF),
                                      Color(0xFF0083EE),
                                    ],
                                  ),
                                  _apresiasiData.isEmpty
                                      ? _buildNoDataWidget()
                                      : _buildBarChart(
                                        _apresiasiChartTab == 0
                                            ? _apresiasiData
                                            : _apresiasiData,
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFF61B8FF),
                                            Color(0xFF0083EE),
                                          ],
                                        ),
                                      ),
                                  _apresiasiChartTab,
                                  (index) {
                                    setState(() => _apresiasiChartTab = index);
                                    _addLocalActivity(
                                      'Navigasi',
                                      'Tab Grafik Apresiasi',
                                      'Berpindah ke tab ${index == 0 ? 'Minggu' : 'Bulan'}',
                                    );
                                  },
                                  true,
                                ),
                                const SizedBox(height: 20),
                                _buildEnhancedChartCard(
                                  'Grafik Pelanggaran Siswa',
                                  'Pelanggaran per jurusan',
                                  Icons.warning_amber_rounded,
                                  const LinearGradient(
                                    colors: [
                                      Color(0xFFF2D6D7),
                                      Color(0xFFFF6B6D),
                                    ],
                                  ),
                                  _pelanggaranData.isEmpty
                                      ? _buildNoDataWidget()
                                      : _buildBarChart(
                                        _pelanggaranChartTab == 0
                                            ? _pelanggaranData
                                            : _pelanggaranData,
                                        const LinearGradient(
                                          colors: [
                                            Color(0xFFFF6B6D),
                                            Color(0xFFFF8E8F),
                                          ],
                                        ),
                                      ),
                                  _pelanggaranChartTab,
                                  (index) {
                                    setState(
                                      () => _pelanggaranChartTab = index,
                                    );
                                    _addLocalActivity(
                                      'Navigasi',
                                      'Tab Grafik Pelanggaran',
                                      'Berpindah ke tab ${index == 0 ? 'Minggu' : 'Bulan'}',
                                    );
                                  },
                                  false,
                                ),
                                const SizedBox(height: 20),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ActivityScreen(),
                                      ),
                                    ).then((_) {
                                      _addLocalActivity(
                                        'Navigasi',
                                        'Aktivitas',
                                        'Mengakses halaman aktivitas',
                                      );
                                    });
                                  },
                                  child: Container(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFF61B8FF),
                                                    Color(0xFF0083EE),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.history,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Aktivitas Terkini',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Color(0xFF1F2937),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Update terbaru dari sistem',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFF8FAFC),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.arrow_forward_ios,
                                                size: 14,
                                                color: Color(0xFF9CA3AF),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 24),
                                        ..._activityData
                                            .take(3)
                                            .map(
                                              (activity) => Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 16,
                                                ),
                                                child:
                                                    _buildEnhancedActivityItem(
                                                      activity['icon'],
                                                      activity['gradient'],
                                                      activity['title'],
                                                      activity['subtitle'],
                                                      _formatTime(
                                                        activity['time'],
                                                      ),
                                                      activity['badge'],
                                                      activity['badgeColor'],
                                                    ),
                                              ),
                                            ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSiswaTerbaikSection() {
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
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 24,
                  ),
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
                        'Top ${_filteredSiswaTerbaik.length} siswa dengan poin tertinggi',
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
            child: Column(
              children:
                  _filteredSiswaTerbaik.isEmpty
                      ? [
                        Text(
                          'Tidak ada hasil ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ]
                      : _filteredSiswaTerbaik.asMap().entries.map((entry) {
                        int index = entry.key;
                        Student siswa = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index < _filteredSiswaTerbaik.length - 1
                                    ? 16
                                    : 0,
                          ),
                          child: _buildSiswaTerbaikItem(siswa),
                        );
                      }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaBeratSection() {
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
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Siswa Berat',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Top ${_filteredSiswaBerat.length} siswa dengan pelanggaran terberat',
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
            child: Column(
              children:
                  _filteredSiswaBerat.isEmpty
                      ? [
                        Text(
                          'Tidak ada hasil ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ]
                      : _filteredSiswaBerat.asMap().entries.map((entry) {
                        int index = entry.key;
                        Student siswa = entry.value;
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom:
                                index < _filteredSiswaBerat.length - 1 ? 16 : 0,
                          ),
                          child: _buildSiswaBeratItem(siswa),
                        );
                      }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSiswaTerbaikItem(Student siswa) {
    Color rankColor = _getRankColor(siswa.rank);
    IconData rankIcon = _getRankIcon(siswa.rank);

    return GestureDetector(
      onTap: () => _navigateToDetailScreen(siswa),
      child: Container(
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
                  colors:
                      siswa.rank <= 3
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
                  const Icon(Icons.person, color: Colors.white, size: 24),
                  if (siswa.rank <= 3)
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: rankColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: rankColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#${siswa.rank}',
                          style: GoogleFonts.poppins(
                            color: rankColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          siswa.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0083EE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          siswa.kelas,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0083EE),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.star,
                        color: Color(0xFFFFD700),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${siswa.poin} poin',
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
                    siswa.prestasi,
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
              child: Icon(Icons.trending_up, color: rankColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSiswaBeratItem(Student siswa) {
    Color rankColor = _getRankColor(siswa.rank);

    return GestureDetector(
      onTap: () => _navigateToDetailScreen(siswa),
      child: Container(
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
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
                  const Icon(Icons.person, color: Colors.white, size: 24),
                  if (siswa.rank <= 3)
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
                        child: Icon(
                          _getRankIcon(siswa.rank),
                          color: Colors.white,
                          size: 10,
                        ),
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: rankColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: rankColor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '#${siswa.rank}',
                          style: GoogleFonts.poppins(
                            color: rankColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          siswa.name,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0083EE).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          siswa.kelas,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF0083EE),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B6D),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${siswa.poin} poin',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFFF6B6D),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    siswa.prestasi,
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
              child: Icon(Icons.trending_down, color: rankColor, size: 20),
            ),
          ],
        ),
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

  Widget _buildActionButton(String text, int index) {
    bool isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = index);
          _addLocalActivity('Navigasi', 'Tab $text', 'Berpindah ke tab $text');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            boxShadow:
                isActive
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
                    gradient: LinearGradient(
                      colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              if (isActive && index == 2)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              if (isActive && index == 3)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                    ),
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

  Widget _buildEnhancedChartCard(
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    Widget chart,
    int selectedTab,
    Function(int) onTabChanged,
    bool isFirst,
  ) {
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
                _buildSwipeableChartButtons(selectedTab, onTabChanged),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => GrafikScreen(
                          chartType: isFirst ? 'apresiasi' : 'pelanggaran',
                          title: title,
                          subtitle: subtitle,
                        ),
                  ),
                ).then((_) {
                  _addLocalActivity(
                    'Navigasi',
                    'Grafik ${isFirst ? 'Apresiasi' : 'Pelanggaran'}',
                    'Mengakses grafik ${isFirst ? 'apresiasi' : 'pelanggaran'}',
                  );
                });
              },
              child: chart,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeableChartButtons(
    int selectedTab,
    Function(int) onTabChanged,
  ) {
    return GestureDetector(
      onPanUpdate: (details) {
        if (details.delta.dx > 5) {
          if (selectedTab > 0) {
            onTabChanged(selectedTab - 1);
            _addLocalActivity(
              'Navigasi',
              'Tab Grafik',
              'Berpindah ke tab ${selectedTab == 0 ? 'Bulan' : 'Minggu'}',
            );
          }
        } else if (details.delta.dx < -5) {
          if (selectedTab < 1) {
            onTabChanged(selectedTab + 1);
            _addLocalActivity(
              'Navigasi',
              'Tab Grafik',
              'Berpindah ke tab ${selectedTab == 0 ? 'Bulan' : 'Minggu'}',
            );
          }
        }
      },
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildChartButton(
              'Minggu',
              selectedTab == 0,
              () => onTabChanged(0),
            ),
            _buildChartButton('Bulan', selectedTab == 1, () => onTabChanged(1)),
          ],
        ),
      ),
    );
  }

  Widget _buildChartButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
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
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      height: 160,
      alignment: Alignment.center,
      child: Text(
        'Tidak ada data tersedia',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF6B7280),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, Gradient gradient) {
    if (data.isEmpty) {
      return _buildNoDataWidget();
    }

    double maxValue = data
        .map((e) => (e['value'] as double?) ?? 0.0)
        .reduce((a, b) => a > b ? a : b);

    if (maxValue == 0) maxValue = 1.0;

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
                      Text(
                        '${maxValue.toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(maxValue * 0.75).toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(maxValue * 0.5).toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(maxValue * 0.25).toInt()}',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '0',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children:
                        data.map((item) {
                          double value = (item['value'] as double?) ?? 0.0;
                          double height =
                              maxValue > 0 ? (value / maxValue) * 120 : 0;
                          return Container(
                            width: 40,
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
                  children:
                      data.map((item) {
                        return Text(
                          (item['label'] as String?) ?? '',
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

  Widget _buildEnhancedActivityItem(
    IconData icon,
    Gradient gradient,
    String title,
    String subtitle,
    String time,
    String badge,
    Color badgeColor,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ActivityScreen()),
        ).then((_) {
          _addLocalActivity(
            'Navigasi',
            'Aktivitas',
            'Mengakses halaman aktivitas dari item',
          );
        });
      },
      child: Container(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: badgeColor.withOpacity(0.3),
                      width: 1,
                    ),
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
      ),
    );
  }
}
