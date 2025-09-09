import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:skoring/screens/walikelas/notification.dart';
import 'package:skoring/screens/profile.dart';
import 'package:skoring/widgets/exports/excel.dart';
import 'package:skoring/widgets/exports/pdf.dart';
import 'package:skoring/widgets/faq.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FAQItem {
  final String title;
  final List<Map<String, String>> items;

  FAQItem({required this.title, required this.items});

  factory FAQItem.fromJson(Map<String, dynamic> json) {
    return FAQItem(
      title: json['kategori'] ?? 'Unknown',
      items: [
        {
          'text': json['uraian'] ?? 'No description',
          'points': '${json['indikator_poin'] ?? 0} poin',
        },
      ],
    );
  }
}

class StudentScore {
  final String keterangan;
  final String tanggal;
  final int poin;
  final String type;

  StudentScore({
    required this.keterangan,
    required this.tanggal,
    required this.poin,
    required this.type,
  });

  factory StudentScore.fromPenghargaan(Map<String, dynamic> json) {
    return StudentScore(
      keterangan: json['alasan'] ?? 'Unknown',
      tanggal: json['tanggal_penghargaan'] ?? 'Unknown',
      poin: 0,
      type: 'apresiasi',
    );
  }

  factory StudentScore.fromPeringatan(Map<String, dynamic> json) {
    return StudentScore(
      keterangan: json['alasan'] ?? 'Unknown',
      tanggal: json['tanggal_sp'] ?? 'Unknown',
      poin: 0,
      type: 'pelanggaran',
    );
  }
}

class Student {
  final String name;
  final int totalPoin;
  final int apresiasi;
  final int pelanggaran;
  final bool isPositive;
  final Color color;
  final String avatar;
  final List<StudentScore> scores;

  Student({
    required this.name,
    required this.totalPoin,
    required this.apresiasi,
    required this.pelanggaran,
    required this.isPositive,
    required this.color,
    required this.avatar,
    required this.scores,
  });

  factory Student.fromJson(
    Map<String, dynamic> json,
    List<StudentScore> scores,
  ) {
    final totalPoin = json['poin_total'] ?? 0;
    return Student(
      name: json['nama_siswa'] ?? 'Unknown',
      totalPoin: totalPoin,
      apresiasi: json['poin_apresiasi'] ?? 0,
      pelanggaran: json['poin_pelanggaran'] ?? 0,
      isPositive: totalPoin >= 0,
      color: totalPoin >= 0 ? const Color(0xFF10B981) : const Color(0xFFFF6B6D),
      avatar: (json['nama_siswa'] ?? 'U').substring(0, 2).toUpperCase(),
      scores: scores,
    );
  }
}

class Kelas {
  final String idKelas;
  final String namaKelas;
  final String jurusan;

  Kelas({
    required this.idKelas,
    required this.namaKelas,
    required this.jurusan,
  });

  factory Kelas.fromJson(Map<String, dynamic> json) {
    return Kelas(
      idKelas: json['id_kelas'] ?? '',
      namaKelas: json['nama_kelas'] ?? 'Unknown',
      jurusan: json['jurusan'] ?? 'Unknown',
    );
  }
}

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'Semua';
  String _selectedView = 'Rekap';
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<Student> studentsList = [];
  List<Kelas> kelasList = [];
  Map<String, FAQItem> faqData = {};
  Kelas? selectedKelas;
  bool isLoadingStudents = true;
  bool isLoadingKelas = true;
  bool isLoadingAspek = true;
  String? errorMessageStudents;
  String? errorMessageKelas;
  String? errorMessageAspek;
  String? walikelasId;
  String? idKelas;

  final Map<String, bool> _expandedSections = {};

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
    _animationController.forward();

    _loadWalikelasId().then((_) {
      fetchKelas();
      fetchSiswa();
      fetchAspekPenilaian();
    });
  }

  Future<void> _loadWalikelasId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      walikelasId = prefs.getString('walikelas_id');
      idKelas = prefs.getString('id_kelas');
    });
  }

  Future<void> fetchKelas() async {
    if (walikelasId == null) {
      setState(() {
        errorMessageKelas = 'ID walikelas tidak ditemukan';
        isLoadingKelas = false;
      });
      return;
    }

    setState(() {
      isLoadingKelas = true;
      errorMessageKelas = null;
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/kelas'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          setState(() {
            kelasList = data.map((json) => Kelas.fromJson(json)).toList();
            selectedKelas =
                idKelas != null
                    ? kelasList.firstWhere(
                      (kelas) => kelas.idKelas == idKelas,
                      orElse:
                          () =>
                              kelasList.isNotEmpty
                                  ? kelasList.first
                                  : throw Exception('No valid class found'),
                    )
                    : kelasList.isNotEmpty
                    ? kelasList.first
                    : null;
            isLoadingKelas = false;
            if (selectedKelas == null) {
              errorMessageKelas = 'Kelas terkait tidak ditemukan';
            }
          });
        } else {
          setState(() {
            errorMessageKelas = jsonData['message'];
            isLoadingKelas = false;
          });
        }
      } else {
        setState(() {
          errorMessageKelas =
              'Gagal mengambil data kelas: ${response.statusCode}';
          isLoadingKelas = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessageKelas = 'Terjadi kesalahan: $e';
        isLoadingKelas = false;
      });
    }
  }

  Future<void> fetchSiswa() async {
    setState(() {
      isLoadingStudents = true;
      errorMessageStudents = null;
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/siswa'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          List<Student> students = [];
          for (var studentJson in data) {
            final scores = await _fetchStudentScores(
              studentJson['nis'].toString(),
            );
            students.add(Student.fromJson(studentJson, scores));
          }
          setState(() {
            studentsList = students;
            isLoadingStudents = false;
          });
        } else {
          setState(() {
            errorMessageStudents = jsonData['message'];
            isLoadingStudents = false;
          });
        }
      } else {
        setState(() {
          errorMessageStudents =
              'Gagal mengambil data siswa: ${response.statusCode}';
          isLoadingStudents = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessageStudents = 'Terjadi kesalahan: $e';
        isLoadingStudents = false;
      });
    }
  }

  Future<List<StudentScore>> _fetchStudentScores(String nis) async {
    List<StudentScore> scores = [];
    try {
      final penghargaanResponse = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/penghargaan'))
          .timeout(Duration(seconds: 10));
      if (penghargaanResponse.statusCode == 200) {
        final jsonData = jsonDecode(penghargaanResponse.body);
        if (jsonData['success']) {
          scores.addAll(
            (jsonData['data'] as List)
                .map((json) => StudentScore.fromPenghargaan(json))
                .toList(),
          );
        }
      }

      final peringatanResponse = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/peringatan'))
          .timeout(Duration(seconds: 10));
      if (peringatanResponse.statusCode == 200) {
        final jsonData = jsonDecode(peringatanResponse.body);
        if (jsonData['success']) {
          scores.addAll(
            (jsonData['data'] as List)
                .map((json) => StudentScore.fromPeringatan(json))
                .toList(),
          );
        }
      }
    } catch (e) {
      // Handle errors silently for scores, as they are supplementary
    }
    return scores;
  }

  Future<void> fetchAspekPenilaian() async {
    setState(() {
      isLoadingAspek = true;
      errorMessageAspek = null;
    });

    try {
      final response = await http
          .get(Uri.parse('http://10.0.2.2:8000/api/aspekpenilaian'))
          .timeout(Duration(seconds: 10));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          Map<String, FAQItem> tempFaqData = {};
          for (var i = 0; i < data.length; i++) {
            String key = data[i]['id_aspekpenilaian'] ?? 'A$i';
            tempFaqData[key] = FAQItem.fromJson(data[i]);
            _expandedSections[key] = false;
          }
          setState(() {
            faqData = tempFaqData;
            isLoadingAspek = false;
          });
        } else {
          setState(() {
            errorMessageAspek = jsonData['message'];
            isLoadingAspek = false;
          });
        }
      } else {
        setState(() {
          errorMessageAspek =
              'Gagal mengambil data aspek penilaian: ${response.statusCode}';
          isLoadingAspek = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessageAspek = 'Terjadi kesalahan: $e';
        isLoadingAspek = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double get _averageApresiasi {
    if (studentsList.isEmpty) return 0;
    double total = studentsList.fold(
      0,
      (sum, student) => sum + student.apresiasi,
    );
    return total / studentsList.length;
  }

  double get _apresiasiPercentage {
    if (studentsList.isEmpty) return 0;
    int positiveCount =
        studentsList.where((student) => student.apresiasi > 50).length;
    return positiveCount / studentsList.length;
  }

  double get _pelanggaranPercentage {
    if (studentsList.isEmpty) return 0;
    int lowViolationCount =
        studentsList.where((student) => student.pelanggaran < 10).length;
    return lowViolationCount / studentsList.length;
  }

  List<Student> get _filteredAndSortedStudents {
    if (selectedKelas == null) return [];

    List<Student> filtered =
        studentsList.where((student) {
          bool matchesSearch = student.name.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          if (!matchesSearch) return false;

          int poin = student.totalPoin;
          switch (_selectedFilter) {
            case '0-50':
              return poin >= 0 && poin <= 50;
            case '51-100':
              return poin >= 51 && poin <= 100;
            case '101+':
              return poin > 100;
            case 'Negatif':
              return poin < 0;
            case 'Semua':
            default:
              return true;
          }
        }).toList();

    filtered.sort((a, b) => b.totalPoin.compareTo(a.totalPoin));
    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Berdasarkan Nilai',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ...['Semua', '0-50', '51-100', '101+', 'Negatif'].map((filter) {
                String displayText = filter;
                if (filter == 'Negatif') displayText = 'Nilai Negatif';
                if (filter == '101+') displayText = '101 ke atas';

                return ListTile(
                  title: Text(
                    displayText,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color:
                          _selectedFilter == filter
                              ? const Color(0xFF0083EE)
                              : const Color(0xFF1F2937),
                    ),
                  ),
                  leading: Radio<String>(
                    value: filter,
                    groupValue: _selectedFilter,
                    onChanged: (value) {
                      setState(() {
                        _selectedFilter = value!;
                      });
                      Navigator.pop(context);
                    },
                    activeColor: const Color(0xFF0083EE),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Ekspor Data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih format ekspor untuk ${_filteredAndSortedStudents.length} siswa dengan filter $_selectedFilter:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: Text('PDF', style: GoogleFonts.poppins(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  PdfExport.exportToPDF(
                    _filteredAndSortedStudents
                        .map(
                          (s) => {
                            'name': s.name,
                            'totalPoin': s.totalPoin,
                            'apresiasi': s.apresiasi,
                            'pelanggaran': s.pelanggaran,
                            'isPositive': s.isPositive,
                            'color': s.color,
                            'avatar': s.avatar,
                            'scores':
                                s.scores
                                    .map(
                                      (score) => {
                                        'keterangan': score.keterangan,
                                        'tanggal': score.tanggal,
                                        'poin': score.poin,
                                        'type': score.type,
                                      },
                                    )
                                    .toList(),
                          },
                        )
                        .toList(),
                    'Laporan_Siswa_${selectedKelas?.namaKelas ?? 'Unknown'}.pdf',
                  );
                },
              ),
              ListTile(
                title: Text('Excel', style: GoogleFonts.poppins(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  ExcelExport.exportToExcel(
                    _filteredAndSortedStudents
                        .map(
                          (s) => {
                            'name': s.name,
                            'totalPoin': s.totalPoin,
                            'apresiasi': s.apresiasi,
                            'pelanggaran': s.pelanggaran,
                            'isPositive': s.isPositive,
                            'color': s.color,
                            'avatar': s.avatar,
                            'scores':
                                s.scores
                                    .map(
                                      (score) => {
                                        'keterangan': score.keterangan,
                                        'tanggal': score.tanggal,
                                        'poin': score.poin,
                                        'type': score.type,
                                      },
                                    )
                                    .toList(),
                          },
                        )
                        .toList(),
                    'Laporan_Siswa_${selectedKelas?.namaKelas ?? 'Unknown'}.xlsx',
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Batal',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF0083EE),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderContent() {
    final bool isLoading =
        isLoadingKelas || isLoadingStudents || isLoadingAspek;
    final bool hasError =
        errorMessageKelas != null ||
        errorMessageStudents != null ||
        errorMessageAspek != null;

    if (isLoading) {
      return Row(
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'Memuat data...',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    if (hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Terjadi Kesalahan',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessageKelas ??
                errorMessageStudents ??
                errorMessageAspek ??
                'Gagal memuat data dari server',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }

    if (selectedKelas != null) {
      final studentsInClass =
          studentsList
              .where(
                (student) => student.scores.any(
                  (score) =>
                      score.type == 'apresiasi' || score.type == 'pelanggaran',
                ),
              )
              .length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Penilaian Siswa ${selectedKelas!.namaKelas}',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Jurusan: ${selectedKelas!.jurusan.toUpperCase()}',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Total Siswa: $studentsInClass • Semester Ganjil 2025/2026',
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return Text(
      'Tidak ada kelas terkait',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoading =
        isLoadingKelas || isLoadingStudents || isLoadingAspek;
    final bool hasError =
        errorMessageKelas != null ||
        errorMessageStudents != null ||
        errorMessageAspek != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              double maxWidth =
                  constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
              return Center(
                child: SizedBox(
                  width: maxWidth,
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
                                        onTap: () => Navigator.pop(context),
                                        child: Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.arrow_back_ios_new_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder:
                                                      (context) =>
                                                          const NotifikasiScreen(),
                                                ),
                                              );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: const Icon(
                                                Icons.notifications_rounded,
                                                color: Colors.white,
                                                size: 24,
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
                                              );
                                            },
                                            child: Container(
                                              width: 40,
                                              height: 40,
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
                                    child: _buildHeaderContent(),
                                  ),
                                  if (!isLoading && !hasError) ...[
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
                                            color: Colors.black.withOpacity(
                                              0.08,
                                            ),
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
                                              borderRadius:
                                                  BorderRadius.circular(30),
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
                                              controller: _searchController,
                                              onChanged: (value) {
                                                setState(() {
                                                  _searchQuery = value;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                hintText:
                                                    _selectedView == 'Rekap'
                                                        ? 'Cari nama murid...'
                                                        : 'Cari aturan atau poin...',
                                                hintStyle: GoogleFonts.poppins(
                                                  color: const Color(
                                                    0xFF9CA3AF,
                                                  ),
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
                                          if (_searchQuery.isNotEmpty)
                                            GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _searchController.clear();
                                                  _searchQuery = '';
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.clear,
                                                  color: Color(0xFF9CA3AF),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        _buildViewButton('Rekap', 'Rekap'),
                                        const SizedBox(width: 10),
                                        _buildViewButton(
                                          'FAQ Point',
                                          'FAQ Point',
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (hasError)
                                  _buildErrorState()
                                else if (isLoading)
                                  _buildLoadingState()
                                else if (_selectedView == 'Rekap') ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildStatCard(
                                          '${_filteredAndSortedStudents.length}',
                                          'Total Siswa',
                                          Icons.people_outline,
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFF61B8FF),
                                              Color(0xFF0083EE),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildStatCard(
                                          '${_averageApresiasi.toInt()}',
                                          'Rata-rata\nApresiasi',
                                          Icons.check_circle_outline,
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFF10B981),
                                              Color(0xFF34D399),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildProgressCard(
                                          'Apresiasi',
                                          '${(_apresiasiPercentage * 100).toInt()}%',
                                          _apresiasiPercentage,
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFF10B981),
                                              Color(0xFF34D399),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildProgressCard(
                                          'Pelanggaran',
                                          '${(_pelanggaranPercentage * 100).toInt()}%',
                                          _pelanggaranPercentage,
                                          const LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B6D),
                                              Color(0xFFFF8E8F),
                                            ],
                                          ),
                                        ),
                                      ),
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
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Hasil Akumulasi',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            GestureDetector(
                                              onTap: _showFilterBottomSheet,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 8,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF3F4F6,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE5E7EB,
                                                    ),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      _selectedFilter ==
                                                              'Negatif'
                                                          ? 'Nilai Negatif'
                                                          : _selectedFilter ==
                                                              '101+'
                                                          ? '101 ke atas'
                                                          : _selectedFilter,
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color: const Color(
                                                              0xFF374151,
                                                            ),
                                                          ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.keyboard_arrow_down,
                                                      size: 16,
                                                      color: Color(0xFF6B7280),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            GestureDetector(
                                              onTap: _showExportDialog,
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(
                                                    0xFFF3F4F6,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: const Color(
                                                      0xFFE5E7EB,
                                                    ),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.download_rounded,
                                                  color: Color(0xFF374151),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (_filteredAndSortedStudents.isEmpty &&
                                      _searchQuery.isNotEmpty)
                                    _buildEmptyState(
                                      'Tidak ada siswa ditemukan',
                                      'Coba ubah kata kunci pencarian atau filter',
                                    )
                                  else if (_filteredAndSortedStudents.isEmpty)
                                    _buildEmptyState(
                                      'Tidak ada siswa dalam range ini',
                                      'Coba pilih filter lain',
                                    )
                                  else
                                    ...List.generate(
                                      _filteredAndSortedStudents.length,
                                      (index) => _buildStudentCard(
                                        _filteredAndSortedStudents[index],
                                        index,
                                      ),
                                    ),
                                ] else ...[
                                  FaqWidget(
                                    faqData: faqData.map(
                                      (key, value) => MapEntry(key, {
                                        'title': value.title,
                                        'items': value.items,
                                      }),
                                    ),
                                    expandedSections: _expandedSections,
                                    searchQuery: _searchQuery,
                                    onExpansionChanged: (code, expanded) {
                                      setState(() {
                                        _expandedSections[code] = expanded;
                                      });
                                    },
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
      ),
    );
  }

  Widget _buildViewButton(String text, String view) {
    bool isActive = _selectedView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedView = view;
            _searchController.clear();
            _searchQuery = '';
          });
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
              if (isActive && view == 'Rekap')
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
              if (isActive && view == 'FAQ Point')
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF34D399)],
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

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Gradient gradient,
  ) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    String percentage,
    double progress,
    Gradient gradient,
  ) {
    return Container(
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Text(
                percentage,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Student student, int index) {
    double totalPoints = (student.apresiasi + student.pelanggaran).toDouble();
    double apresiasiRatio =
        totalPoints > 0 ? student.apresiasi / totalPoints : 0;
    double pelanggaranRatio =
        totalPoints > 0 ? student.pelanggaran / totalPoints : 0;

    return GestureDetector(
      onTap: () => _showStudentDetail(student),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                student.isPositive
                    ? const Color(0xFF10B981).withOpacity(0.2)
                    : const Color(0xFFFF6B6D).withOpacity(0.2),
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFEDBCC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  student.avatar,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    student.name,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Apresiasi: ${student.apresiasi} | ',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        'Pelanggaran: ${student.pelanggaran}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFFF6B6D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: (apresiasiRatio * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(3),
                                bottomLeft: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: (pelanggaranRatio * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6D),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(3),
                                bottomRight: Radius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Text(
                  '${student.totalPoin}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: student.color,
                  ),
                ),
                Text(
                  'Total Poin',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0083EE)),
          ),
          const SizedBox(height: 24),
          Text(
            'Memuat data...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6D).withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const Icon(
              Icons.error_outline,
              color: Color(0xFFFF6B6D),
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessageKelas ??
                errorMessageStudents ??
                errorMessageAspek ??
                'Terjadi kesalahan tidak diketahui',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              fetchKelas();
              fetchSiswa();
              fetchAspekPenilaian();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF0083EE).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.refresh, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Coba Lagi',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0083EE).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.search_off, color: Colors.white, size: 50),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
                _selectedFilter = 'Semua';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0083EE).withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Reset Filter',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentDetail(Student student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEDBCC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        student.avatar,
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEA580C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Text(
                          selectedKelas?.namaKelas ?? 'Unknown',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient:
                      student.isPositive
                          ? const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF34D399)],
                          )
                          : const LinearGradient(
                            colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                          ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${student.totalPoin}',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Total Poin',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '${student.apresiasi}',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Apresiasi',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '${student.pelanggaran}',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Pelanggaran',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Daftar Nilai',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Keterangan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Tanggal',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Poin',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: student.scores.length,
                  itemBuilder: (context, index) {
                    final score = student.scores[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              score.type == 'apresiasi'
                                  ? const Color(0xFF10B981).withOpacity(0.2)
                                  : const Color(0xFFFF6B6D).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              score.keterangan,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1F2937),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              score.tanggal,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF0083EE),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    score.type == 'apresiasi'
                                        ? const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.1)
                                        : const Color(
                                          0xFFFF6B6D,
                                        ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${score.poin}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      score.type == 'apresiasi'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFFF6B6D),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
