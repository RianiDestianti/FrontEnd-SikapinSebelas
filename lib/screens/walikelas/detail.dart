import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
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
  bool isLoadingViolations = true;
  bool isLoadingAppreciations = true;
  bool isLoadingStudent = true;
  String? errorMessageViolations;
  String? errorMessageAppreciations;
  String? errorMessageStudent;
  Map<String, dynamic>? kelasData;
  List<dynamic> aspekPenilaianData = [];

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
    fetchStudentData(widget.student['nisn']);
    fetchAspekPenilaian();
  }

  Future<void> fetchStudentData(String nis) async {
    setState(() {
      isLoadingStudent = true;
      errorMessageStudent = null;
    });

    try {
      final siswaResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/siswa?nis=$nis'),
      );
      final kelasResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/kelas'),
      );

      if (siswaResponse.statusCode == 200 && kelasResponse.statusCode == 200) {
        final siswaJson = jsonDecode(siswaResponse.body);
        final kelasJson = jsonDecode(kelasResponse.body);

        if (siswaJson['success'] && kelasJson['success']) {
          final siswaData = siswaJson['data'].firstWhere(
            (s) => s['nis'].toString() == nis,
            orElse: () => null,
          );
          final kelas = kelasJson['data'].firstWhere(
            (k) => k['id_kelas'] == siswaData['id_kelas'],
            orElse: () => null,
          );

          if (siswaData != null && kelas != null) {
            setState(() {
              detailedStudent = Student(
                name: siswaData['nama_siswa'],
                status:
                    siswaData['poin_total'] >= 0
                        ? 'Aman'
                        : siswaData['poin_total'] >= -20
                        ? 'Bermasalah'
                        : 'Prioritas',
                nis: siswaData['nis'].toString(),
                programKeahlian: kelas['jurusan'].toUpperCase(),
                kelas: kelas['nama_kelas'],
                poinApresiasi: siswaData['poin_apresiasi'],
                poinPelanggaran: siswaData['poin_pelanggaran'],
                poinTotal: siswaData['poin_total'],
              );
              kelasData = kelas;
              isLoadingStudent = false;
            });
            fetchViolations(nis);
            fetchAppreciations(nis);
          } else {
            setState(() {
              errorMessageStudent = 'Data siswa atau kelas tidak ditemukan';
              isLoadingStudent = false;
            });
          }
        } else {
          setState(() {
            errorMessageStudent =
                siswaJson['message'] ??
                kelasJson['message'] ??
                'Gagal mengambil data siswa/kelas';
            isLoadingStudent = false;
          });
        }
      } else {
        setState(() {
          errorMessageStudent = 'Gagal mengambil data dari server';
          isLoadingStudent = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessageStudent = 'Terjadi kesalahan: $e';
        isLoadingStudent = false;
      });
    }
  }

  Future<void> fetchAspekPenilaian() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/aspekpenilaian'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          setState(() {
            aspekPenilaianData = jsonData['data'];
          });
        }
      }
    } catch (e) {
    }
  }

  Future<void> fetchViolations(String nis) async {
    setState(() {
      isLoadingViolations = true;
      errorMessageViolations = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/peringatan'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          setState(() {
            pelanggaranHistory =
                data.map((item) {
                  final apiViolation = ApiViolation.fromJson(item);
                  final aspek = aspekPenilaianData.firstWhere(
                    (a) =>
                        a['pelanggaran_ke'] ==
                            (apiViolation.levelSp == 'SP1' ? '1' : '2') &&
                        a['jenis_poin'] == 'Pelanggaran',
                    orElse:
                        () => {
                          'indikator_poin':
                              apiViolation.levelSp == 'SP1' ? 5 : 10,
                          'uraian': apiViolation.alasan,
                          'kategori':
                              apiViolation.levelSp == 'SP1'
                                  ? 'Ringan'
                                  : 'Terlambat',
                          'pelanggaran_ke':
                              apiViolation.levelSp == 'SP1' ? '1' : '2',
                        },
                  );
                  return ViolationHistory(
                    type: apiViolation.levelSp,
                    description: aspek['uraian'],
                    date: apiViolation.tanggalSp,
                    time:
                        apiViolation.createdAt != null
                            ? DateTime.parse(
                              apiViolation.createdAt!,
                            ).toLocal().toString().substring(11, 16)
                            : "00:00",
                    points:
                        aspek['indikator_poin'] ??
                        (apiViolation.levelSp == 'SP1' ? 5 : 10),
                    icon: Icons.warning,
                    color: const Color(0xFFFF6B6D),
                    pelanggaranKe: aspek['pelanggaran_ke'],
                    kategori: aspek['kategori'],
                  );
                }).toList();
            isLoadingViolations = false;
            calculateAccumulations();
          });
        } else {
          setState(() {
            errorMessageViolations = jsonData['message'];
            isLoadingViolations = false;
            calculateAccumulations();
          });
        }
      } else {
        setState(() {
          errorMessageViolations =
              'Gagal mengambil data pelanggaran dari server';
          isLoadingViolations = false;
          calculateAccumulations();
        });
      }
    } catch (e) {
      setState(() {
        errorMessageViolations = 'Terjadi kesalahan: $e';
        isLoadingViolations = false;
        calculateAccumulations();
      });
    }
  }

  Future<void> fetchAppreciations(String nis) async {
    setState(() {
      isLoadingAppreciations = true;
      errorMessageAppreciations = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/Penghargaan'),
      );
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData['success']) {
          List<dynamic> data = jsonData['data'];
          setState(() {
            apresiasiHistory =
                data.map((item) {
                  final apiAppreciation = ApiAppreciation.fromJson(item);
                  final aspek = aspekPenilaianData.firstWhere(
                    (a) =>
                        a['jenis_poin'] == 'Apresiasi' &&
                        a['kategori'] == 'Tepat waktu',
                    orElse:
                        () => {
                          'indikator_poin':
                              apiAppreciation.levelPenghargaan == 'PH1'
                                  ? 10
                                  : 20,
                          'uraian': apiAppreciation.alasan,
                          'kategori': 'Tepat waktu',
                        },
                  );
                  return AppreciationHistory(
                    type: apiAppreciation.levelPenghargaan,
                    description: aspek['uraian'],
                    date: apiAppreciation.tanggalPenghargaan,
                    time:
                        apiAppreciation.createdAt != null
                            ? DateTime.parse(
                              apiAppreciation.createdAt!,
                            ).toLocal().toString().substring(11, 16)
                            : "00:00",
                    points:
                        aspek['indikator_poin'] ??
                        (apiAppreciation.levelPenghargaan == 'PH1' ? 10 : 20),
                    icon: Icons.star,
                    color: const Color(0xFF10B981),
                    kategori: aspek['kategori'],
                  );
                }).toList();
            isLoadingAppreciations = false;
            calculateAccumulations();
          });
        } else {
          setState(() {
            errorMessageAppreciations = jsonData['message'];
            isLoadingAppreciations = false;
            calculateAccumulations();
          });
        }
      } else {
        setState(() {
          errorMessageAppreciations =
              'Gagal mengambil data penghargaan dari server';
          isLoadingAppreciations = false;
          calculateAccumulations();
        });
      }
    } catch (e) {
      setState(() {
        errorMessageAppreciations = 'Terjadi kesalahan: $e';
        isLoadingAppreciations = false;
        calculateAccumulations();
      });
    }
  }

  void calculateAccumulations() {
    final periods = [
      {
        'periode': 'Minggu ke-1 Juli 2025',
        'startDate': DateTime(2025, 6, 30),
        'endDate': DateTime(2025, 7, 6),
        'date': '30 Jun - 6 Jul 2025',
      },
      {
        'periode': 'Minggu ke-2 Juli 2025',
        'startDate': DateTime(2025, 7, 7),
        'endDate': DateTime(2025, 7, 13),
        'date': '7-13 Jul 2025',
      },
      {
        'periode': 'Minggu ke-3 Juli 2025',
        'startDate': DateTime(2025, 7, 14),
        'endDate': DateTime(2025, 7, 20),
        'date': '14-20 Jul 2025',
      },
      {
        'periode': 'Minggu ke-4 Juli 2025',
        'startDate': DateTime(2025, 7, 21),
        'endDate': DateTime(2025, 7, 27),
        'date': '21-27 Jul 2025',
      },
    ];

    List<AccumulationHistory> tempAccumulations = [];

    for (var period in periods) {
      final startDate = period['startDate'] as DateTime;
      final endDate = period['endDate'] as DateTime;
      final periode = period['periode'] as String;
      final date = period['date'] as String;

      int pelanggaranPoints = pelanggaranHistory
          .where((item) {
            try {
              final itemDate = DateTime.parse(item.date);
              return itemDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ) &&
                  itemDate.isBefore(endDate.add(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          })
          .fold(0, (sum, item) => sum + item.points);

      int apresiasiPoints = apresiasiHistory
          .where((item) {
            try {
              final itemDate = DateTime.parse(item.date);
              return itemDate.isAfter(
                    startDate.subtract(const Duration(days: 1)),
                  ) &&
                  itemDate.isBefore(endDate.add(const Duration(days: 1)));
            } catch (e) {
              return false;
            }
          })
          .fold(0, (sum, item) => sum + item.points);

      int total = apresiasiPoints - pelanggaranPoints;

      String status;
      if (total >= 0) {
        status = 'Aman';
      } else if (total >= -20) {
        status = 'Bermasalah';
      } else {
        status = 'Prioritas';
      }

      if (pelanggaranPoints != 0 || apresiasiPoints != 0) {
        tempAccumulations.add(
          AccumulationHistory(
            periode: periode,
            pelanggaran: pelanggaranPoints,
            apresiasi: apresiasiPoints,
            total: total,
            status: status,
            date: date,
          ),
        );
      }
    }

    setState(() {
      akumulasiHistory = tempAccumulations;
    });
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
                onPressed: () => fetchStudentData(widget.student['nisn']),
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
                                  'NIS/NISN',
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
                                  '+${detailedStudent.poinPelanggaran}',
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
          _buildEmptyState('Belum ada riwayat pelanggaran', Icons.check_circle)
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
        if (isLoadingViolations || isLoadingAppreciations)
          const Center(child: CircularProgressIndicator())
        else if (errorMessageViolations != null &&
            errorMessageAppreciations != null)
          _buildEmptyState(
            'Gagal mengambil data pelanggaran dan apresiasi',
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
                      if (isPelanggaran && item.pelanggaranKe != null)
                        Text(
                          'Pelanggaran ke: ${item.pelanggaranKe}',
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
                  '+${item.points}',
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
                        '+${item.pelanggaran}',
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
