import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/walikelas/notification.dart';
import 'package:skoring/screens/profile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class LaporanKaprog extends StatefulWidget {
  const LaporanKaprog({Key? key}) : super(key: key);

  @override
  State<LaporanKaprog> createState() => _LaporanKaprogState();
}

class _LaporanKaprogState extends State<LaporanKaprog>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedJurusan = 'Semua';
  String _selectedKelas = 'Semua';
  String _selectedFilter = 'Semua';
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _jurusanList = [
    'Semua',
    'RPL',
    'DKV',
    'TKJ',
    'MP',
    'AKL',
    'MLOG',
    'PM',
  ];
  final List<String> _kelasList = ['Semua', 'X', 'XI', 'XII'];
  final List<String> _filterList = [
    'Semua',
    '0-50',
    '51-100',
    '101+',
    'Negatif',
  ];

  final Map<String, List<Map<String, dynamic>>> _allStudentsData = {
    'RPL': [
      {
        'name': 'Abijalu Anggra Putra',
        'totalPoin': 27,
        'apresiasi': 30,
        'pelanggaran': 3,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'AP',
        'kelas': 'XII',
        'scores': [
          {
            'keterangan': 'Juara 1 Olimpiade',
            'tanggal': '10 Juli 2025',
            'poin': 50,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Terlambat',
            'tanggal': '12 Juli 2025',
            'poin': -5,
            'type': 'pelanggaran',
          },
        ],
      },
      {
        'name': 'Ahmad Lutfi Khairul',
        'totalPoin': -45,
        'apresiasi': 5,
        'pelanggaran': 50,
        'isPositive': false,
        'color': const Color(0xFFFF6B6D),
        'avatar': 'AL',
        'kelas': 'XI',
        'scores': [
          {
            'keterangan': 'Terlibat Tawuran',
            'tanggal': '12 Juli 2025',
            'poin': -45,
            'type': 'pelanggaran',
          },
          {
            'keterangan': 'Membantu Teman',
            'tanggal': '9 Juli 2025',
            'poin': 5,
            'type': 'apresiasi',
          },
        ],
      },
      {
        'name': 'Budi Santoso',
        'totalPoin': 75,
        'apresiasi': 80,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'BS',
        'kelas': 'X',
        'scores': [
          {
            'keterangan': 'Juara 1 Lomba Desain',
            'tanggal': '14 Juli 2025',
            'poin': 50,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Aktif di Kelas',
            'tanggal': '12 Juli 2025',
            'poin': 30,
            'type': 'apresiasi',
          },
        ],
      },
    ],
    'DKV': [
      {
        'name': 'Citra Dewi',
        'totalPoin': 85,
        'apresiasi': 90,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'CD',
        'kelas': 'XII',
        'scores': [
          {
            'keterangan': 'Juara 1 Desain Poster',
            'tanggal': '10 Juli 2025',
            'poin': 50,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Membantu Event Sekolah',
            'tanggal': '8 Juli 2025',
            'poin': 40,
            'type': 'apresiasi',
          },
        ],
      },
      {
        'name': 'Deni Ramadan',
        'totalPoin': 12,
        'apresiasi': 20,
        'pelanggaran': 8,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'DR',
        'kelas': 'XI',
        'scores': [
          {
            'keterangan': 'Kreativitas Tinggi',
            'tanggal': '13 Juli 2025',
            'poin': 20,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Terlambat',
            'tanggal': '9 Juli 2025',
            'poin': -8,
            'type': 'pelanggaran',
          },
        ],
      },
    ],
    'TKJ': [
      {
        'name': 'Eka Putri',
        'totalPoin': 120,
        'apresiasi': 125,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'EP',
        'kelas': 'XII',
        'scores': [
          {
            'keterangan': 'Juara 1 Kompetisi Jaringan',
            'tanggal': '15 Juli 2025',
            'poin': 100,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Membantu Lab',
            'tanggal': '12 Juli 2025',
            'poin': 25,
            'type': 'apresiasi',
          },
        ],
      },
      {
        'name': 'Fajar Ahmad',
        'totalPoin': 65,
        'apresiasi': 70,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'FA',
        'kelas': 'XI',
        'scores': [
          {
            'keterangan': 'Teknisi Handal',
            'tanggal': '14 Juli 2025',
            'poin': 40,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Maintenance PC',
            'tanggal': '11 Juli 2025',
            'poin': 30,
            'type': 'apresiasi',
          },
        ],
      },
    ],
    'MP': [
      {
        'name': 'Gina Sari',
        'totalPoin': 45,
        'apresiasi': 50,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'GS',
        'kelas': 'XII',
        'scores': [
          {
            'keterangan': 'Organisasi Terbaik',
            'tanggal': '10 Juli 2025',
            'poin': 30,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Dokumentasi Lengkap',
            'tanggal': '8 Juli 2025',
            'poin': 20,
            'type': 'apresiasi',
          },
        ],
      },
    ],
    'AKL': [
      {
        'name': 'Hani Kamilah',
        'totalPoin': 55,
        'apresiasi': 60,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'HK',
        'kelas': 'XII',
        'scores': [
          {
            'keterangan': 'Juara Lomba Akuntansi',
            'tanggal': '15 Juli 2025',
            'poin': 40,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Laporan Keuangan Tepat',
            'tanggal': '12 Juli 2025',
            'poin': 20,
            'type': 'apresiasi',
          },
        ],
      },
    ],
    'MLOG': [
      {
        'name': 'Indra Wijaya',
        'totalPoin': 35,
        'apresiasi': 40,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'IW',
        'kelas': 'XI',
        'scores': [
          {
            'keterangan': 'Manajemen Gudang Baik',
            'tanggal': '14 Juli 2025',
            'poin': 25,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Koordinasi Tim',
            'tanggal': '11 Juli 2025',
            'poin': 15,
            'type': 'apresiasi',
          },
        ],
      },
    ],
    'PM': [
      {
        'name': 'Joko Santoso',
        'totalPoin': 40,
        'apresiasi': 45,
        'pelanggaran': 5,
        'isPositive': true,
        'color': const Color(0xFF10B981),
        'avatar': 'JS',
        'kelas': 'XII',
        'scores': [
          {
            'keterangan': 'Presentasi Terbaik',
            'tanggal': '13 Juli 2025',
            'poin': 30,
            'type': 'apresiasi',
          },
          {
            'keterangan': 'Strategi Marketing',
            'tanggal': '10 Juli 2025',
            'poin': 15,
            'type': 'apresiasi',
          },
        ],
      },
    ],
  };

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentStudentsData {
    List<Map<String, dynamic>> allStudents = [];

    if (_selectedJurusan == 'Semua') {
      _allStudentsData.forEach((jurusan, students) {
        for (var student in students) {
          allStudents.add({...student, 'jurusan': jurusan});
        }
      });
    } else {
      allStudents =
          _allStudentsData[_selectedJurusan]
              ?.map((student) => {...student, 'jurusan': _selectedJurusan})
              .toList() ??
          [];
    }

    return allStudents;
  }

  double get _averageApresiasi {
    if (_currentStudentsData.isEmpty) return 0;
    double total = _currentStudentsData.fold(
      0,
      (sum, student) => sum + student['apresiasi'],
    );
    return total / _currentStudentsData.length;
  }

  double get _apresiasiPercentage {
    if (_currentStudentsData.isEmpty) return 0;
    int positiveCount =
        _currentStudentsData
            .where((student) => student['apresiasi'] > 50)
            .length;
    return positiveCount / _currentStudentsData.length;
  }

  double get _pelanggaranPercentage {
    if (_currentStudentsData.isEmpty) return 0;
    int lowViolationCount =
        _currentStudentsData
            .where((student) => student['pelanggaran'] < 10)
            .length;
    return lowViolationCount / _currentStudentsData.length;
  }

  List<Map<String, dynamic>> get _filteredAndSortedStudents {
    List<Map<String, dynamic>> filtered =
        _currentStudentsData.where((student) {
          bool matchesSearch = student['name'].toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
          if (!matchesSearch) return false;

          // Filter berdasarkan kelas
          bool matchesKelas =
              _selectedKelas == 'Semua' || student['kelas'] == _selectedKelas;
          if (!matchesKelas) return false;

          // Filter berdasarkan poin
          int poin = student['totalPoin'];
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

    filtered.sort((a, b) => b['totalPoin'].compareTo(a['totalPoin']));
    return filtered;
  }

  Map<String, Map<String, dynamic>> get _jurusanSummary {
    Map<String, Map<String, dynamic>> summary = {};

    _allStudentsData.forEach((jurusan, students) {
      int totalStudents = students.length;
      int positiveStudents = students.where((s) => s['totalPoin'] > 0).length;
      int negativeStudents = students.where((s) => s['totalPoin'] < 0).length;
      double avgPoints =
          totalStudents > 0
              ? (students.fold(0.0, (sum, s) => sum + s['totalPoin'])) /
                  totalStudents
              : 0.0;

      summary[jurusan] = {
        'totalStudents': totalStudents,
        'positiveStudents': positiveStudents,
        'negativeStudents': negativeStudents,
        'avgPoints': avgPoints,
        'positivePercentage': positiveStudents / totalStudents,
        'negativePercentage': negativeStudents / totalStudents,
      };
    });

    return summary;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter Data Siswa',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Jurusan:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _jurusanList.map((jurusan) {
                          return ChoiceChip(
                            label: Text(jurusan),
                            selected: _selectedJurusan == jurusan,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedJurusan = jurusan;
                              });
                              setState(() {
                                _selectedJurusan = jurusan;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Kelas:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _kelasList.map((kelas) {
                          return ChoiceChip(
                            label: Text(kelas),
                            selected: _selectedKelas == kelas,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedKelas = kelas;
                              });
                              setState(() {
                                _selectedKelas = kelas;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'Rentang Poin:',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children:
                        _filterList.map((filter) {
                          return ChoiceChip(
                            label: Text(
                              filter == 'Negatif'
                                  ? 'Nilai Negatif'
                                  : filter == '101+'
                                  ? '101 ke atas'
                                  : filter,
                            ),
                            selected: _selectedFilter == filter,
                            onSelected: (selected) {
                              setModalState(() {
                                _selectedFilter = filter;
                              });
                              setState(() {
                                _selectedFilter = filter;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Tutup'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            Navigator.pop(context);
                          },
                          child: Text('Terapkan'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
                'Pilih format ekspor untuk ${_filteredAndSortedStudents.length} siswa:',
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
                  _exportToPDF();
                },
              ),
              ListTile(
                title: Text('Excel', style: GoogleFonts.poppins(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _exportToExcel();
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

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Laporan Rekap Siswa SMKN 11 Bandung - Semester Ganjil 2025/2026',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Filter: Jurusan $_selectedJurusan, Kelas $_selectedKelas, Poin $_selectedFilter',
            ),
            pw.SizedBox(height: 10),
            pw.Table.fromTextArray(
              headers: [
                'Nama',
                'Jurusan',
                'Kelas',
                'Total Poin',
                'Apresiasi',
                'Pelanggaran',
              ],
              data:
                  _filteredAndSortedStudents
                      .map(
                        (student) => [
                          student['name'],
                          student['jurusan'] ?? '-',
                          student['kelas'] ?? '-',
                          student['totalPoin'].toString(),
                          student['apresiasi'].toString(),
                          student['pelanggaran'].toString(),
                        ],
                      )
                      .toList(),
            ),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await FileSaver.instance.saveFile(
      name: 'Laporan_Rekap_SMKN11_${DateTime.now().millisecondsSinceEpoch}.pdf',
      bytes: bytes,
      mimeType: MimeType.pdf,
    );
  }

  Future<void> _exportToExcel() async {
    final excelInstance = excel.Excel.createExcel();
    final sheet = excelInstance['Sheet1'];

    // Header
    sheet.appendRow(['Laporan Rekap Siswa SMKN 11 Bandung']);
    sheet.appendRow([
      'Filter: Jurusan $_selectedJurusan, Kelas $_selectedKelas, Poin $_selectedFilter',
    ]);
    sheet.appendRow(['']);
    sheet.appendRow([
      'Nama',
      'Jurusan',
      'Kelas',
      'Total Poin',
      'Apresiasi',
      'Pelanggaran',
    ]);

    for (var student in _filteredAndSortedStudents) {
      sheet.appendRow([
        student['name'],
        student['jurusan'] ?? '-',
        student['kelas'] ?? '-',
        student['totalPoin'].toString(),
        student['apresiasi'].toString(),
        student['pelanggaran'].toString(),
      ]);
    }

    final bytes = excelInstance.encode();
    await FileSaver.instance.saveFile(
      name:
          'Laporan_Rekap_SMKN11_${DateTime.now().millisecondsSinceEpoch}.xlsx',
      bytes: Uint8List.fromList(bytes!),
      mimeType: MimeType.microsoftExcel,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Laporan Rekap Siswa',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w700,
                                            height: 1.2,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'SMKN 11 Bandung - Semester Ganjil 2025/2026',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
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
                                            controller: _searchController,
                                            onChanged: (value) {
                                              setState(() {
                                                _searchQuery = value;
                                              });
                                            },
                                            decoration: InputDecoration(
                                              hintText: 'Cari nama siswa...',
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
                                        if (_searchQuery.isNotEmpty)
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _searchController.clear();
                                                _searchQuery = '';
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
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
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Statistik Keseluruhan
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        '${_currentStudentsData.length}',
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
                                        'Pelanggaran Rendah',
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

                                if (_selectedJurusan == 'Semua') ...[
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Ringkasan Per Jurusan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        ..._jurusanSummary.entries.map(
                                          (entry) => _buildJurusanSummaryCard(
                                            entry.key,
                                            entry.value,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                ],

                                // Header Hasil Filter
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Hasil Filter',
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
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
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
                                                      const Icon(
                                                        Icons.tune,
                                                        size: 16,
                                                        color: Color(
                                                          0xFF6B7280,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Filter',
                                                        style:
                                                            GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color:
                                                                  const Color(
                                                                    0xFF374151,
                                                                  ),
                                                            ),
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
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
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
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildFilterChip(
                                            'Jurusan: $_selectedJurusan',
                                          ),
                                          _buildFilterChip(
                                            'Kelas: $_selectedKelas',
                                          ),
                                          _buildFilterChip(
                                            'Poin: $_selectedFilter',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Daftar Siswa
                                if (_filteredAndSortedStudents.isEmpty &&
                                    _searchQuery.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.search_off,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Tidak ada siswa ditemukan',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Coba ubah kata kunci pencarian atau filter',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (_filteredAndSortedStudents.isEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(40),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.filter_list_off,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'Tidak ada siswa dalam filter ini',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Coba pilih filter lain',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  ...List.generate(
                                    _filteredAndSortedStudents.length,
                                    (index) {
                                      return _buildStudentCard(
                                        _filteredAndSortedStudents[index],
                                        index,
                                      );
                                    },
                                  ),
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

  Widget _buildJurusanSummaryCard(String jurusan, Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getJurusanColor(jurusan).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                jurusan,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _getJurusanColor(jurusan),
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
                  '${data['totalStudents']} siswa',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Positif: ${data['positiveStudents']} ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    Text(
                      '| Negatif: ${data['negativeStudents']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFFF6B6D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${data['avgPoints'].toInt()}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color:
                      data['avgPoints'] > 0
                          ? const Color(0xFF10B981)
                          : const Color(0xFFFF6B6D),
                ),
              ),
              Text(
                'Rata-rata',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0083EE).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0083EE).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0083EE),
        ),
      ),
    );
  }

  Color _getJurusanColor(String jurusan) {
    switch (jurusan) {
      case 'RPL':
        return const Color(0xFF4CAF50);
      case 'DKV':
        return const Color(0xFF9C27B0);
      case 'TKJ':
        return const Color(0xFF757575);
      case 'MP':
        return const Color(0xFF2196F3);
      case 'AKL':
        return const Color(0xFFFFEB3B);
      case 'MLOG':
        return const Color(0xFFFF9800);
      case 'PM':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF0083EE);
    }
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

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    double totalPoints =
        (student['apresiasi'] + student['pelanggaran']).toDouble();
    double apresiasiRatio =
        totalPoints > 0 ? student['apresiasi'] / totalPoints : 0;
    double pelanggaranRatio =
        totalPoints > 0 ? student['pelanggaran'] / totalPoints : 0;

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
                student['isPositive']
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
                color: _getJurusanColor(
                  student['jurusan'] ?? 'RPL',
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  student['jurusan'] ?? 'RPL',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: _getJurusanColor(student['jurusan'] ?? 'RPL'),
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
                    student['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${student['jurusan']} ${student['kelas']} | ',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      Text(
                        'A: ${student['apresiasi']} | P: ${student['pelanggaran']}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF0083EE),
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
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
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
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6D),
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
                  '${student['totalPoin']}',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: student['color'],
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

  void _showStudentDetail(Map<String, dynamic> student) {
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
                      color: _getJurusanColor(
                        student['jurusan'] ?? 'RPL',
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        student['jurusan'] ?? 'RPL',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _getJurusanColor(student['jurusan'] ?? 'RPL'),
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
                          student['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${student['jurusan']} ${student['kelas']}',
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
                      student['isPositive']
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
                          '${student['totalPoin']}',
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
                          '${student['apresiasi']}',
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
                          '${student['pelanggaran']}',
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
                  itemCount: student['scores'].length,
                  itemBuilder: (context, index) {
                    final score = student['scores'][index];
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
                              score['type'] == 'apresiasi'
                                  ? const Color(0xFF10B981).withOpacity(0.2)
                                  : const Color(0xFFFF6B6D).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              score['keterangan'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              score['tanggal'],
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
                                    score['type'] == 'apresiasi'
                                        ? const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.1)
                                        : const Color(
                                          0xFFFF6B6D,
                                        ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${score['poin']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      score['type'] == 'apresiasi'
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
