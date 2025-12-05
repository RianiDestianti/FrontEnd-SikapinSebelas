import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'point.dart';
import 'note.dart';
import 'history.dart';

class ApiViolation {
  final int idSp;
  final String tanggalSp;
  final String levelSp;
  final String alasan;
  final String? createdAt;
  final String? updatedAt;

  ApiViolation({
    required this.idSp,
    required this.tanggalSp,
    required this.levelSp,
    required this.alasan,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiViolation.fromJson(Map<String, dynamic> json) {
    return ApiViolation(
      idSp: json['id_sp'],
      tanggalSp: json['tanggal_sp'],
      levelSp: json['level_sp'],
      alasan: json['alasan'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class ApiAppreciation {
  final int idPenghargaan;
  final String tanggalPenghargaan;
  final String levelPenghargaan;
  final String alasan;
  final String? createdAt;
  final String? updatedAt;

  ApiAppreciation({
    required this.idPenghargaan,
    required this.tanggalPenghargaan,
    required this.levelPenghargaan,
    required this.alasan,
    this.createdAt,
    this.updatedAt,
  });

  factory ApiAppreciation.fromJson(Map<String, dynamic> json) {
    return ApiAppreciation(
      idPenghargaan: json['id_penghargaan'],
      tanggalPenghargaan: json['tanggal_penghargaan'],
      levelPenghargaan: json['level_penghargaan'],
      alasan: json['alasan'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

class Student {
  final String name;
  final String status;
  final String nis;
  final String programKeahlian;
  final String kelas;
  final int poinApresiasi;
  final int poinPelanggaran;
  final int poinTotal;

  Student({
    required this.name,
    required this.status,
    required this.nis,
    required this.programKeahlian,
    required this.kelas,
    required this.poinApresiasi,
    required this.poinPelanggaran,
    required this.poinTotal,
  });
}

class ViolationHistory {
  final String type;
  final String description;
  final String date;
  final String time;
  final int points;
  final IconData icon;
  final Color color;
  final String? pelanggaranKe;
  final String kategori;

  ViolationHistory({
    required this.type,
    required this.description,
    required this.date,
    required this.time,
    required this.points,
    required this.icon,
    required this.color,
    this.pelanggaranKe,
    required this.kategori,
  });
}

class AppreciationHistory {
  final String type;
  final String description;
  final String date;
  final String time;
  final int points;
  final IconData icon;
  final Color color;
  final String kategori;

  AppreciationHistory({
    required this.type,
    required this.description,
    required this.date,
    required this.time,
    required this.points,
    required this.icon,
    required this.color,
    required this.kategori,
  });
}

class AccumulationHistory {
  final String periode;
  final int pelanggaran;
  final int apresiasi;
  final int total;
  final String status;
  final String date;

  AccumulationHistory({
    required this.periode,
    required this.pelanggaran,
    required this.apresiasi,
    required this.total,
    required this.status,
    required this.date,
  });
}

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  const DetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedTab = 0;
  late Student detailedStudent;
  List<ViolationHistory> pelanggaranHistory = [];
  List<AppreciationHistory> apresiasiHistory = [];
  List<AccumulationHistory> akumulasiHistory = [];
  bool isLoadingAppreciations = true;
  bool isLoadingViolations = true;
  bool isLoadingStudent = true;
  String? errorMessageAppreciations;
  String? errorMessageViolations;
  String? errorMessageStudent;
  List<dynamic> aspekPenilaianData = [];

  String _nipWalikelas = '';
  String _idKelas = '';

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
    _loadUserData();
  }

Future<void> _loadUserData() async {
  final prefs = await SharedPreferences.getInstance();
  setState(() {
    _nipWalikelas = prefs.getString('walikelas_id') ?? '';
    _idKelas = prefs.getString('id_kelas') ?? '';
  });

  if (_nipWalikelas.isEmpty || _idKelas.isEmpty) {
    setState(() {
      errorMessageStudent = 'Data guru tidak lengkap. Silakan login ulang.';
      isLoadingStudent = false;
    });
    return;
  }

  await fetchAspekPenilaian();
  initializeStudentData();
}

void initializeStudentData() {
  setState(() {
    isLoadingStudent = true;
    errorMessageStudent = null;
  });

  try {
    final data = widget.student;

    detailedStudent = Student(
      name: data['name'] ?? 'Unknown',
      status: data['status'] ?? 'Unknown',
      nis: data['nis'] ?? '0',
      programKeahlian: data['programKeahlian'] ?? data['kelas'] ?? 'Unknown',
      kelas: data['kelas'] ?? 'Unknown',
      poinApresiasi: data['poinApresiasi'] ?? 0,
      poinPelanggaran: (data['poinPelanggaran'] ?? 0).abs(),
      poinTotal: data['points'] ?? 0,
    );

    setState(() => isLoadingStudent = false);
    fetchAppreciations(data['nis']);
    fetchViolations(data['nis']);
  } catch (e) {
    setState(() {
      errorMessageStudent = 'Gagal memuat detail siswa: $e';
      isLoadingStudent = false;
    });
  }
}

  Future<void> fetchAspekPenilaian() async {
    setState(() {
      errorMessageStudent = null;
    });
    try {
      final uri = Uri.parse(
        'http://127.0.0.1:3000/api/aspekpenilaian?nip=$_nipWalikelas&id_kelas=$_idKelas',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          setState(() {
            aspekPenilaianData = jsonData['data'];
          });
        } else {
          setState(() {
            errorMessageStudent = jsonData['message'] ?? 'Gagal memuat aspek penilaian';
          });
        }
      } else {
        setState(() {
          errorMessageStudent = 'Gagal mengambil data (${response.statusCode})';
        });
      }
    } catch (e) {
      setState(() {
        errorMessageStudent = 'Terjadi kesalahan: $e';
      });
    }
  }

  Future<void> fetchAppreciations(String nis) async {
    setState(() {
      isLoadingAppreciations = true;
      errorMessageAppreciations = null;
    });
    try {
      final uri = Uri.parse(
        'http://127.0.0.1:3000/api/skoring_penghargaan?nis=$nis&nip=$_nipWalikelas&id_kelas=$_idKelas',
      );
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['penilaian']['data'].isNotEmpty) {
          final appreciationsUri = Uri.parse(
            'http://127.0.0.1:3000/api/Penghargaan?nip=$_nipWalikelas&id_kelas=$_idKelas',
          );
          final appreciationsResponse = await http.get(
            appreciationsUri,
            headers: {'Accept': 'application/json'},
          );

          if (appreciationsResponse.statusCode == 200) {
            final appreciationsData = jsonDecode(appreciationsResponse.body);
            if (appreciationsData['success']) {
              List<dynamic> appreciations = appreciationsData['data'];
              List<dynamic> studentEvaluations = jsonData['penilaian']['data']
                  .where((eval) => eval['nis'].toString() == nis)
                  .toList();

              List<AppreciationHistory> filteredAppreciations = [];
              for (var eval in studentEvaluations) {
                final aspek = aspekPenilaianData.firstWhere(
                  (a) => a['id_aspekpenilaian'] == eval['id_aspekpenilaian'],
                  orElse: () => null,
                );
                if (aspek == null || aspek['jenis_poin'] != 'Apresiasi') continue;

                final appreciation = appreciations.firstWhere(
                  (a) {
                    final evalDate = DateTime.parse(eval['created_at'].substring(0, 10));
                    final appDate = DateTime.parse(a['tanggal_penghargaan']);
                    return (appDate.difference(evalDate).inDays.abs() <= 2) ||
                        a['alasan'].toLowerCase().contains(aspek['uraian'].toLowerCase());
                  },
                  orElse: () => null,
                );

                if (appreciation != null) {
                  final apiAppreciation = ApiAppreciation.fromJson(appreciation);
                  filteredAppreciations.add(
                    AppreciationHistory(
                      type: apiAppreciation.levelPenghargaan,
                      description: aspek['uraian'],
                      date: apiAppreciation.tanggalPenghargaan,
                      time: eval['created_at'].substring(11, 16),
                      points: aspek['indikator_poin'] ??
                          (apiAppreciation.levelPenghargaan == 'PH1'
                              ? 10
                              : apiAppreciation.levelPenghargaan == 'PH2'
                                  ? 20
                                  : 30),
                      icon: Icons.star,
                      color: const Color(0xFF10B981),
                      kategori: aspek['kategori'],
                    ),
                  );
                }
              }
              setState(() {
                apresiasiHistory = filteredAppreciations;
                isLoadingAppreciations = false;
                calculateAccumulations();
              });
            } else {
              setState(() {
                errorMessageAppreciations = appreciationsData['message'] ?? 'Gagal memuat penghargaan';
                isLoadingAppreciations = false;
              });
            }
          } else {
            setState(() {
              errorMessageAppreciations = 'Gagal mengambil data penghargaan (${appreciationsResponse.statusCode})';
              isLoadingAppreciations = false;
            });
          }
        } else {
          setState(() {
            errorMessageAppreciations = 'Tidak ada data penghargaan untuk siswa ini';
            isLoadingAppreciations = false;
            calculateAccumulations();
          });
        }
      } else {
        setState(() {
          errorMessageAppreciations = 'Gagal mengambil penilaian (${response.statusCode})';
          isLoadingAppreciations = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessageAppreciations = 'Terjadi kesalahan: $e';
        isLoadingAppreciations = false;
      });
    }
  }

  Future<void> fetchViolations(String nis) async {
  setState(() {
    isLoadingViolations = true;
    errorMessageViolations = null;
  });

  try {
    final uri = Uri.parse(
      'http://127.0.0.1:3000/api/skoring_pelanggaran?nis=$nis&nip=$_nipWalikelas&id_kelas=$_idKelas',
    );
    final response = await http.get(uri, headers: {'Accept': 'application/json'});

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List<dynamic> evaluations = jsonData['penilaian']['data']
          .where((e) => e['nis'].toString() == nis)
          .toList();

      List<ViolationHistory> history = [];

      for (var eval in evaluations) {
        final aspek = aspekPenilaianData.firstWhere(
          (a) => a['id_aspekpenilaian'] == eval['id_aspekpenilaian'],
          orElse: () => {'uraian': 'Unknown', 'indikator_poin': 10, 'kategori': 'Umum'},
        );

        history.add(ViolationHistory(
          type: 'Pelanggaran',
          description: aspek['uraian'],
          date: eval['created_at'].substring(0, 10),
          time: eval['created_at'].substring(11, 16),
          points: aspek['indikator_poin'] ?? 10,
          icon: Icons.warning,
          color: const Color(0xFFFF6B6D),
          pelanggaranKe: null,
          kategori: aspek['kategori'] ?? 'Umum',
        ));
      }

      setState(() {
        pelanggaranHistory = history;
        isLoadingViolations = false;
        calculateAccumulations();
      });
    }
  } catch (e) {
    setState(() {
      errorMessageViolations = 'Error: $e';
      isLoadingViolations = false;
    });
  }
}
  void calculateAccumulations() {
    setState(() {
      isLoadingAppreciations = true;
      isLoadingViolations = true;
    });

    try {
      int totalApresiasiPoints = apresiasiHistory.fold(
        0,
        (sum, item) => sum + item.points,
      );
      int totalPelanggaranPoints = detailedStudent.poinPelanggaran;

      int totalPoints = totalApresiasiPoints - totalPelanggaranPoints;

      String status;
      if (totalPoints >= 0) {
        status = 'Aman';
      } else if (totalPoints >= -20) {
        status = 'Bermasalah';
      } else {
        status = 'Prioritas';
      }

      setState(() {
        akumulasiHistory = [
          AccumulationHistory(
            periode: 'Total Keseluruhan',
            pelanggaran: totalPelanggaranPoints,
            apresiasi: totalApresiasiPoints,
            total: totalPoints,
            status: status,
            date: 'Sampai ${DateTime.now().toString().split(' ')[0]}',
          ),
        ];
        isLoadingAppreciations = false;
        isLoadingViolations = false;
      });
    } catch (e) {
      setState(() {
        errorMessageAppreciations =
            'Terjadi kesalahan dalam menghitung akumulasi: $e';
        isLoadingAppreciations = false;
        isLoadingViolations = false;
      });
    }
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
    if (isLoadingStudent) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessageStudent != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                errorMessageStudent!,
                style: GoogleFonts.poppins(color: Colors.red),
              ),
              ElevatedButton(
                onPressed: () => initializeStudentData(),
                child: Text('Coba Lagi', style: GoogleFonts.poppins()),
              ),
            ],
          ),
        ),
      );
    }

    final backgroundGradient = _getBackgroundGradient(detailedStudent.status);
    final shadowColor = _getBackgroundShadowColor(detailedStudent.status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
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
                                  height: MediaQuery.of(context).padding.top,
                                ),
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
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
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
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
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
                                              detailedStudent.name[0]
                                                  .toUpperCase(),
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
                                          detailedStudent.name,
                                          style: GoogleFonts.poppins(
                                            fontSize: 24,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '${detailedStudent.kelas} - ${detailedStudent.programKeahlian}',
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
                                              detailedStudent.status,
                                            ).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            border: Border.all(
                                              color: _getStatusColor(
                                                detailedStudent.status,
                                              ).withOpacity(0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: _getStatusColor(
                                                    detailedStudent.status,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '${detailedStudent.status}',
                                                textAlign: TextAlign.center,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: _getStatusColor(
                                                    detailedStudent.status,
                                                  ),
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
                                                  showPointPopup(
                                                    context,
                                                    detailedStudent.name,
                                                    detailedStudent.nis,
                                                    detailedStudent.kelas,
                                                  );
                                                },
                                                child: Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        vertical: 14,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                          colors: [
                                                            Color(0xFF61B8FF),
                                                            Color(0xFF0083EE),
                                                          ],
                                                        ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: const Color(
                                                          0xFF0083EE,
                                                        ).withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      const Icon(
                                                        Icons.star_outline,
                                                        color: Colors.white,
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Berikan Poin',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            if (detailedStudent.status !=
                                                'Aman') ...[
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    showBKNotePopup(
                                                      context,
                                                      detailedStudent.name,
                                                      detailedStudent.nis,
                                                      detailedStudent.kelas,
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 14,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      gradient:
                                                          const LinearGradient(
                                                            colors: [
                                                              Color(0xFFFF6B6D),
                                                              Color(0xFFEA580C),
                                                            ],
                                                          ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: const Color(
                                                            0xFFFF6B6D,
                                                          ).withOpacity(0.3),
                                                          blurRadius: 8,
                                                          offset: const Offset(
                                                            0,
                                                            4,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Icon(
                                                          Icons
                                                              .note_add_outlined,
                                                          color: Colors.white,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text(
                                                          'Catatan BK',
                                                          style:
                                                              GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color:
                                                                    Colors
                                                                        .white,
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
                                _buildBiodataRow(
                                  'NIS',
                                  detailedStudent.nis,
                                  Icons.badge,
                                ),
                                _buildBiodataRow(
                                  'Program Keahlian',
                                  detailedStudent.programKeahlian,
                                  Icons.school,
                                ),
                                _buildBiodataRow(
                                  'Kelas',
                                  detailedStudent.kelas,
                                  Icons.class_,
                                ),
                                _buildBiodataRow(
                                  'Poin Apresiasi',
                                  '+${detailedStudent.poinApresiasi}',
                                  Icons.star,
                                ),
                                _buildBiodataRow(
                                  'Poin Pelanggaran',
                                  '-${detailedStudent.poinPelanggaran.abs()}',
                                  Icons.warning,
                                ),
                                _buildBiodataRow(
                                  'Poin Total',
                                  '${detailedStudent.poinTotal > 0 ? '+' : ''}${detailedStudent.poinTotal}',
                                  Icons.calculate,
                                ),
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
          },
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
        if (isLoadingViolations)
          const Center(child: CircularProgressIndicator())
        else if (errorMessageViolations != null)
          _buildEmptyState(errorMessageViolations!, Icons.error)
        else if (pelanggaranHistory.isEmpty)
          _buildEmptyState('Belum ada riwayat pelanggaran', Icons.warning)
        else
          ...pelanggaranHistory
              .map((item) => _buildHistoryCard(item, isPelanggaran: true))
              .toList(),
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
        if (isLoadingAppreciations)
          const Center(child: CircularProgressIndicator())
        else if (errorMessageAppreciations != null)
          _buildEmptyState(errorMessageAppreciations!, Icons.error)
        else if (apresiasiHistory.isEmpty)
          _buildEmptyState('Belum ada riwayat apresiasi', Icons.star)
        else
          ...apresiasiHistory
              .map((item) => _buildHistoryCard(item, isPelanggaran: false))
              .toList(),
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
        if (isLoadingAppreciations || isLoadingViolations)
          const Center(child: CircularProgressIndicator())
        else if (errorMessageAppreciations != null ||
            errorMessageViolations != null)
          _buildEmptyState(
            (errorMessageAppreciations ?? errorMessageViolations)!,
            Icons.error,
          )
        else if (akumulasiHistory.isEmpty)
          _buildEmptyState('Belum ada riwayat akumulasi', Icons.calculate)
        else
          ...akumulasiHistory.map((item) => _buildAkumulasiCard(item)).toList(),
      ],
    );
  }

  Widget _buildHistoryCard(dynamic item, {required bool isPelanggaran}) {
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
                      Text(
                        'Kategori: ${item.kategori}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  isPelanggaran ? '-${item.points}' : '+${item.points}',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: item.color,
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
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: const Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.date} • ${item.time}',
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

  Widget _buildAkumulasiCard(AccumulationHistory item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(item.status).withOpacity(0.2),
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(item.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  item.status,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _getStatusColor(item.status),
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
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '-${item.pelanggaran}',
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
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '+${item.apresiasi}',
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
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        '${item.total > 0 ? '+' : ''}${item.total}',
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                int totalPoints = item.apresiasi + item.pelanggaran;
                double redFraction =
                    totalPoints > 0 ? item.pelanggaran / totalPoints : 0;
                double greenFraction =
                    totalPoints > 0 ? item.apresiasi / totalPoints : 0;
                return Stack(
                  children: [
                    Container(
                      width: redFraction * constraints.maxWidth,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B6D),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        width: greenFraction * constraints.maxWidth,
                        height: 8,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
