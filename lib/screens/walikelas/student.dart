import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'detail.dart';
import 'package:skoring/screens/walikelas/notification.dart';
import 'package:skoring/screens/profile.dart';
import 'package:skoring/models/api_kelas.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

class Student {
  final int nis;
  final String idKelas;
  final String namaSiswa;
  final int? poinApresiasi;
  final int? poinPelanggaran;
  final int? poinTotal;
  final String createdAt;
  final String updatedAt;

  Student({
    required this.nis,
    required this.idKelas,
    required this.namaSiswa,
    this.poinApresiasi,
    this.poinPelanggaran,
    this.poinTotal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      nis: json['nis'],
      idKelas: json['id_kelas'],
      namaSiswa: json['nama_siswa'],
      poinApresiasi: json['poin_apresiasi'],
      poinPelanggaran: json['poin_pelanggaran'],
      poinTotal: json['poin_total'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  String get status {
    int totalPoints = poinTotal ?? 0;
    if (totalPoints >= 0) {
      return 'Aman';
    } else if (totalPoints >= -20) {
      return 'Bermasalah';
    } else {
      return 'Prioritas';
    }
  }

  int get points => poinTotal ?? 0;
}

class SiswaScreen extends StatefulWidget {
  const SiswaScreen({Key? key}) : super(key: key);

  @override
  State<SiswaScreen> createState() => _SiswaScreenState();
}

class _SiswaScreenState extends State<SiswaScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  String _searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  TextEditingController _searchController = TextEditingController();
  List<Kelas> kelasList = [];
  List<Student> studentsList = [];
  Kelas? selectedKelas;
  bool isLoadingKelas = true;
  bool isLoadingSiswa = true;
  String? errorMessageKelas;
  String? errorMessageSiswa;
  String? walikelasId;
  String? idKelas; 

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
    });
  }

  Future<void> _loadWalikelasId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      walikelasId = prefs.getString('walikelas_id');
      idKelas = prefs.getString('id_kelas'); 
      print(
        'Loaded walikelasId: $walikelasId, id_kelas: $idKelas',
      ); 
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
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/kelas'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          if (data.isNotEmpty) {
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
                      : (kelasList.isNotEmpty ? kelasList.first : null);
              isLoadingKelas = false;
              if (selectedKelas == null) {
                errorMessageKelas = 'Kelas terkait tidak ditemukan';
              }
            });
          } else {
            setState(() {
              errorMessageKelas = 'Tidak ada data kelas ditemukan';
              isLoadingKelas = false;
            });
          }
        } else {
          setState(() {
            errorMessageKelas = jsonData['message'];
            isLoadingKelas = false;
          });
        }
      } else {
        setState(() {
          errorMessageKelas = 'Gagal mengambil data kelas dari server';
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
      isLoadingSiswa = true;
      errorMessageSiswa = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/siswa'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          setState(() {
            studentsList = data.map((json) => Student.fromJson(json)).toList();
            isLoadingSiswa = false;
          });
        } else {
          setState(() {
            errorMessageSiswa = jsonData['message'];
            isLoadingSiswa = false;
          });
        }
      } else {
        setState(() {
          errorMessageSiswa = 'Gagal mengambil data siswa dari server';
          isLoadingSiswa = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessageSiswa = 'Terjadi kesalahan: $e';
        isLoadingSiswa = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Student> getFilteredStudents() {
    if (selectedKelas == null) return [];

    List<Student> filtered =
        studentsList
            .where((student) => student.idKelas == selectedKelas!.idKelas)
            .toList();

    if (_selectedFilter == 1) {
      filtered = filtered.where((s) => s.status == 'Aman').toList();
    } else if (_selectedFilter == 2) {
      filtered =
          filtered
              .where((s) => s.status == 'Bermasalah' || s.status == 'Prioritas')
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (s) =>
                    s.namaSiswa.toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    s.nis.toString().contains(_searchQuery),
              )
              .toList();
    }
    return filtered;
  }

  void _navigateToDetail(Student student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => DetailScreen(
              student: {
                'name': student.namaSiswa,
                'nisn': student.nis.toString(),
                'status': student.status,
                'points': student.points,
                'absent': 0,
                'absen': student.nis,
              },
            ),
      ),
    );
  }

  void _refreshData() {
    fetchKelas();
    fetchSiswa();
  }

  Widget _buildHeaderContent() {
    final bool isLoading = isLoadingKelas || isLoadingSiswa;
    final bool hasError =
        errorMessageKelas != null || errorMessageSiswa != null;

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
                errorMessageSiswa ??
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
              .where((student) => student.idKelas == selectedKelas!.idKelas)
              .length;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Siswa ${selectedKelas!.namaKelas}',
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
    final filteredStudents = getFilteredStudents();
    final bool isLoading = isLoadingKelas || isLoadingSiswa;
    final bool hasError =
        errorMessageKelas != null || errorMessageSiswa != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: LayoutBuilder(
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
                          child: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                20,
                                24,
                                32,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
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
                                            onTap: _refreshData,
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
                                                Icons.refresh_rounded,
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
                                                    BorderRadius.circular(20),
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
                                  Container(
                                    width: double.infinity,
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
                                                    'Cari nama siswa atau NIS...',
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
                                                  _searchQuery = '';
                                                  _searchController.clear();
                                                });
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.all(
                                                  4,
                                                ),
                                                child: const Icon(
                                                  Icons.clear,
                                                  color: Color(0xFF6B7280),
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      children: [
                                        _buildActionButton('Semua', 0),
                                        const SizedBox(width: 10),
                                        _buildActionButton('Aman', 1),
                                        const SizedBox(width: 10),
                                        _buildActionButton('Bermasalah', 2),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              if (hasError)
                                _buildErrorState()
                              else if (isLoading)
                                _buildLoadingState()
                              else ...[
                                if (filteredStudents.isEmpty &&
                                    selectedKelas != null)
                                  _buildEmptyState()
                                else
                                  Column(
                                    children:
                                        filteredStudents.asMap().entries.map((
                                          entry,
                                        ) {
                                          return _buildStudentCard(
                                            entry.value,
                                            entry.key,
                                          );
                                        }).toList(),
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
            'Memuat data siswa...',
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
                errorMessageSiswa ??
                'Terjadi kesalahan tidak diketahui',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _refreshData,
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

  Widget _buildActionButton(String text, int index) {
    bool isActive = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
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
                      colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              if (isActive && index == 1)
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
              if (isActive && index == 2)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFEA580C), Color(0xFFFF6B6D)],
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              Text(
                text,
                style: GoogleFonts.poppins(
                  color:
                      isActive
                          ? (index == 0
                              ? const Color(0xFF1F2937)
                              : index == 1
                              ? const Color(0xFF10B981)
                              : const Color(0xFFEA580C))
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

  Widget _buildStudentCard(Student student, int index) {
    return GestureDetector(
      onTap: () => _navigateToDetail(student),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(student.status).withOpacity(0.2),
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
                  student.namaSiswa[0].toUpperCase(),
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
                    student.namaSiswa,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'NIS: ${student.nis}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Poin: ${student.points}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          student.points >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFF6B6D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 85,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _getStatusColor(student.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      student.status,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(student.status),
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: const Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            'Tidak ada siswa ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
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
                _selectedFilter = 0;
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
}
