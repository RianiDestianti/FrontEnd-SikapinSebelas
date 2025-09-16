import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/profile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
  String? _loggedInJurusan;
  List<Map<String, dynamic>> _allStudentsData = [];
  List<Map<String, dynamic>> _kelasList = [];
  bool _isLoading = true;

  final List<String> _filterList = [
    'Semua',
    '0-50',
    '51-100',
    '101+',
    'Negatif',
  ];

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
    _loadLoggedInJurusan();
    _fetchData();
  }

  Future<void> _loadLoggedInJurusan() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _loggedInJurusan = prefs.getString('jurusan') ?? 'Semua';
      _selectedJurusan = _loggedInJurusan ?? 'Semua';
    });
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final kelasResponse = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/akumulasi'),
      );
      if (kelasResponse.statusCode == 200) {
        final data = jsonDecode(kelasResponse.body);
        setState(() {
          _kelasList =
              (data['kelas_list'] as List)
                  .map(
                    (item) => {
                      'id_kelas': item['id_kelas'],
                      'nama_kelas': item['nama_kelas'],
                      'jurusan': item['jurusan'],
                    },
                  )
                  .toList();
          _allStudentsData =
              (data['data']['data'] as List)
                  .map(
                    (item) => {
                      'nis': item['nis'],
                      'name': item['nama_siswa'],
                      'totalPoin': item['poin_total'] ?? 0,
                      'apresiasi': item['poin_apresiasi'] ?? 0,
                      'pelanggaran': item['poin_pelanggaran'] ?? 0,
                      'isPositive': (item['poin_total'] ?? 0) >= 0,
                      'color':
                          (item['poin_total'] ?? 0) >= 0
                              ? const Color(0xFF10B981)
                              : const Color(0xFFFF6B6D),
                      'avatar':
                          item['nama_siswa']
                              .split(' ')
                              .map((e) => e[0])
                              .join('')
                              .substring(0, 2)
                              .toUpperCase(),
                      'kelas':
                          _kelasList.firstWhere(
                            (k) => k['id_kelas'] == item['id_kelas'],
                            orElse: () => {'nama_kelas': 'Unknown'},
                          )['nama_kelas'],
                      'scores':
                          [], // Placeholder, can be expanded with API calls to skoring_penghargaan and skoring_pelanggaran
                    },
                  )
                  .toList();
        });
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _currentStudentsData {
    List<Map<String, dynamic>> allStudents = [];

    if (_selectedJurusan == 'Semua' && _loggedInJurusan != null) {
      allStudents =
          _allStudentsData
              .where(
                (student) =>
                    student['kelas'].toString().contains(_loggedInJurusan!),
              )
              .toList();
    } else if (_selectedJurusan != 'Semua') {
      allStudents =
          _allStudentsData
              .where(
                (student) =>
                    student['kelas'].toString().contains(_selectedJurusan),
              )
              .toList();
    } else {
      allStudents = _allStudentsData;
    }

    return allStudents;
  }

  double get _averageApresiasi {
    if (_currentStudentsData.isEmpty) return 0;
    double total = _currentStudentsData.fold(
      0,
      (sum, student) => sum + (student['apresiasi'] as num),
    );
    return total / _currentStudentsData.length;
  }

  double get _apresiasiPercentage {
    if (_currentStudentsData.isEmpty) return 0;
    int positiveCount =
        _currentStudentsData
            .where((student) => (student['apresiasi'] as num) > 50)
            .length;
    return positiveCount / _currentStudentsData.length;
  }

  double get _pelanggaranPercentage {
    if (_currentStudentsData.isEmpty) return 0;
    int lowViolationCount =
        _currentStudentsData
            .where((student) => (student['pelanggaran'] as num) < 10)
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

          bool matchesKelas =
              _selectedKelas == 'Semua' || student['kelas'] == _selectedKelas;
          if (!matchesKelas) return false;

          int poin = student['totalPoin'] as int;
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

    filtered.sort(
      (a, b) => (b['totalPoin'] as int).compareTo(a['totalPoin'] as int),
    );
    return filtered;
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: SingleChildScrollView(
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
                      runSpacing: 8,
                      children:
                          [
                            'Semua',
                            if (_loggedInJurusan != null) _loggedInJurusan!,
                          ].map((jurusan) {
                            return FilterChip(
                              label: Text(
                                jurusan,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: _selectedJurusan == jurusan,
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedJurusan = jurusan;
                                });
                                setState(() {
                                  _selectedJurusan = jurusan;
                                });
                              },
                              selectedColor: const Color(
                                0xFF0083EE,
                              ).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF0083EE),
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
                      runSpacing: 8,
                      children:
                          [
                            'Semua',
                            ..._kelasList.map((k) => k['nama_kelas'] as String),
                          ].map((kelas) {
                            return FilterChip(
                              label: Text(
                                kelas,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              selected: _selectedKelas == kelas,
                              onSelected: (selected) {
                                setModalState(() {
                                  _selectedKelas = kelas;
                                });
                                setState(() {
                                  _selectedKelas = kelas;
                                });
                              },
                              selectedColor: const Color(
                                0xFF10B981,
                              ).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF10B981),
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
                      runSpacing: 8,
                      children:
                          _filterList.map((filter) {
                            return FilterChip(
                              label: Text(
                                filter == 'Negatif'
                                    ? 'Nilai Negatif'
                                    : filter == '101+'
                                    ? '101 ke atas'
                                    : filter,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
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
                              selectedColor: const Color(
                                0xFFFF6B6D,
                              ).withOpacity(0.2),
                              checkmarkColor: const Color(0xFFFF6B6D),
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Tutup',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {});
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0083EE),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Terapkan',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Color(0xFFFF6B6D),
                ),
                title: Text('PDF', style: GoogleFonts.poppins(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _exportToPDF();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.table_chart,
                  color: Color(0xFF10B981),
                ),
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

    sheet.appendRow(['Laporan Rekap Siswa SMKN 11 Bandung']);
    sheet.appendRow([
      'Filter: Jurusan $_selectedJurusan, Kelas $_selectedKelas, Poin $_selectedFilter',
    ]);
    sheet.appendRow(['']);
    sheet.appendRow([
      'Nama',
      'Kelas',
      'Total Poin',
      'Apresiasi',
      'Pelanggaran',
    ]);

    for (var student in _filteredAndSortedStudents) {
      sheet.appendRow([
        student['name'],
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 768;
    final isDesktop = screenWidth >= 1024;

    final horizontalPadding =
        isDesktop
            ? 40.0
            : isTablet
            ? 24.0
            : 20.0;
    final cardPadding =
        isDesktop
            ? 24.0
            : isTablet
            ? 20.0
            : 16.0;
    final titleFontSize =
        isDesktop
            ? 24.0
            : isTablet
            ? 22.0
            : 20.0;
    final subtitleFontSize =
        isDesktop
            ? 16.0
            : isTablet
            ? 15.0
            : 14.0;

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
              double maxWidth = isDesktop ? 1200 : constraints.maxWidth;

              return Center(
                child: SizedBox(
                  width: maxWidth,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child:
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFF61B8FF),
                                          Color(0xFF0083EE),
                                        ],
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
                                        horizontalPadding,
                                        MediaQuery.of(context).padding.top + 20,
                                        horizontalPadding,
                                        32,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: Container(
                                                  width: isTablet ? 48 : 40,
                                                  height: isTablet ? 48 : 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          12,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons
                                                        .arrow_back_ios_new_rounded,
                                                    color: Colors.white,
                                                    size: isTablet ? 20 : 18,
                                                  ),
                                                ),
                                              ),
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
                                                  width: isTablet ? 48 : 40,
                                                  height: isTablet ? 48 : 40,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          30,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.person_rounded,
                                                    color: const Color(
                                                      0xFF0083EE,
                                                    ),
                                                    size: isTablet ? 26 : 24,
                                                  ),
                                                ),
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
                                                    fontSize: titleFontSize,
                                                    fontWeight: FontWeight.w700,
                                                    height: 1.2,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  'SMKN 11 Bandung - Semester Ganjil 2025/2026',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    fontSize: subtitleFontSize,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          Container(
                                            height: isTablet ? 56 : 50,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: isTablet ? 24 : 20,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(25),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.08),
                                                  blurRadius: 15,
                                                  offset: const Offset(0, 5),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.all(
                                                    isTablet ? 10 : 8,
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
                                                          30,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.search,
                                                    color: Colors.white,
                                                    size: isTablet ? 20 : 18,
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: TextField(
                                                    controller:
                                                        _searchController,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        _searchQuery = value;
                                                      });
                                                    },
                                                    decoration: InputDecoration(
                                                      hintText:
                                                          'Cari nama siswa...',
                                                      hintStyle:
                                                          GoogleFonts.poppins(
                                                            color: const Color(
                                                              0xFF9CA3AF,
                                                            ),
                                                            fontSize:
                                                                isTablet
                                                                    ? 16
                                                                    : 15,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                    style: GoogleFonts.poppins(
                                                      fontSize:
                                                          isTablet ? 16 : 15,
                                                      color: const Color(
                                                        0xFF1F2937,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (_searchQuery.isNotEmpty)
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        _searchController
                                                            .clear();
                                                        _searchQuery = '';
                                                      });
                                                    },
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                            4,
                                                          ),
                                                      child: Icon(
                                                        Icons.clear,
                                                        color: const Color(
                                                          0xFF9CA3AF,
                                                        ),
                                                        size:
                                                            isTablet ? 22 : 20,
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
                                    padding: EdgeInsets.all(horizontalPadding),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (isDesktop)
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
                                                  isTablet,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
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
                                                  isTablet,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
                                              Expanded(
                                                child: _buildProgressCard(
                                                  'Apresiasi Tinggi',
                                                  '${(_apresiasiPercentage * 100).toInt()}%',
                                                  _apresiasiPercentage,
                                                  const LinearGradient(
                                                    colors: [
                                                      Color(0xFF10B981),
                                                      Color(0xFF34D399),
                                                    ],
                                                  ),
                                                  isTablet,
                                                ),
                                              ),
                                              const SizedBox(width: 16),
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
                                                  isTablet,
                                                ),
                                              ),
                                            ],
                                          )
                                        else ...[
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
                                                  isTablet,
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
                                                  isTablet,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: _buildProgressCard(
                                                  'Apresiasi Tinggi',
                                                  '${(_apresiasiPercentage * 100).toInt()}%',
                                                  _apresiasiPercentage,
                                                  const LinearGradient(
                                                    colors: [
                                                      Color(0xFF10B981),
                                                      Color(0xFF34D399),
                                                    ],
                                                  ),
                                                  isTablet,
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
                                                  isTablet,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                        const SizedBox(height: 20),
                                        Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.all(cardPadding),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.06,
                                                ),
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
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                isTablet
                                                                    ? 10
                                                                    : 8,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                const LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFF61B8FF,
                                                                    ),
                                                                    Color(
                                                                      0xFF0083EE,
                                                                    ),
                                                                  ],
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  10,
                                                                ),
                                                          ),
                                                          child: Icon(
                                                            Icons.filter_list,
                                                            color: Colors.white,
                                                            size:
                                                                isTablet
                                                                    ? 22
                                                                    : 20,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width:
                                                              isTablet
                                                                  ? 16
                                                                  : 12,
                                                        ),
                                                        Expanded(
                                                          child: Text(
                                                            'Hasil Filter',
                                                            style: GoogleFonts.poppins(
                                                              fontSize:
                                                                  isTablet
                                                                      ? 20
                                                                      : 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              color:
                                                                  const Color(
                                                                    0xFF1F2937,
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      GestureDetector(
                                                        onTap:
                                                            _showFilterBottomSheet,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal:
                                                                    isTablet
                                                                        ? 20
                                                                        : 16,
                                                                vertical:
                                                                    isTablet
                                                                        ? 12
                                                                        : 8,
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
                                                              color:
                                                                  const Color(
                                                                    0xFFE5E7EB,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Row(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              Icon(
                                                                Icons.tune,
                                                                size:
                                                                    isTablet
                                                                        ? 18
                                                                        : 16,
                                                                color:
                                                                    const Color(
                                                                      0xFF6B7280,
                                                                    ),
                                                              ),
                                                              const SizedBox(
                                                                width: 8,
                                                              ),
                                                              Text(
                                                                'Filter',
                                                                style: GoogleFonts.poppins(
                                                                  fontSize:
                                                                      isTablet
                                                                          ? 15
                                                                          : 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  color: const Color(
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
                                                        onTap:
                                                            _showExportDialog,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                isTablet
                                                                    ? 12
                                                                    : 8,
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
                                                              color:
                                                                  const Color(
                                                                    0xFFE5E7EB,
                                                                  ),
                                                            ),
                                                          ),
                                                          child: Icon(
                                                            Icons
                                                                .download_rounded,
                                                            color: const Color(
                                                              0xFF374151,
                                                            ),
                                                            size:
                                                                isTablet
                                                                    ? 22
                                                                    : 20,
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
                                                    isTablet,
                                                  ),
                                                  _buildFilterChip(
                                                    'Kelas: $_selectedKelas',
                                                    isTablet,
                                                  ),
                                                  _buildFilterChip(
                                                    'Poin: $_selectedFilter',
                                                    isTablet,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (_filteredAndSortedStudents
                                                .isEmpty &&
                                            _searchQuery.isNotEmpty)
                                          _buildEmptySearchState(isTablet)
                                        else if (_filteredAndSortedStudents
                                            .isEmpty)
                                          _buildEmptyFilterState(isTablet)
                                        else if (isDesktop &&
                                            _filteredAndSortedStudents.length >
                                                1)
                                          GridView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            gridDelegate:
                                                const SliverGridDelegateWithFixedCrossAxisCount(
                                                  crossAxisCount: 2,
                                                  crossAxisSpacing: 16,
                                                  mainAxisSpacing: 16,
                                                  childAspectRatio: 3.5,
                                                ),
                                            itemCount:
                                                _filteredAndSortedStudents
                                                    .length,
                                            itemBuilder: (context, index) {
                                              return _buildStudentCard(
                                                _filteredAndSortedStudents[index],
                                                index,
                                                isTablet,
                                                isGrid: true,
                                              );
                                            },
                                          )
                                        else
                                          ...List.generate(
                                            _filteredAndSortedStudents.length,
                                            (index) {
                                              return _buildStudentCard(
                                                _filteredAndSortedStudents[index],
                                                index,
                                                isTablet,
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

  Widget _buildEmptySearchState(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 40),
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
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: isTablet ? 56 : 48,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Tidak ada siswa ditemukan',
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Coba ubah kata kunci pencarian atau filter',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 48 : 40),
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
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.filter_list_off,
              size: isTablet ? 56 : 48,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: isTablet ? 20 : 16),
          Text(
            'Tidak ada siswa dalam filter ini',
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Coba pilih filter lain',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 16 : 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0083EE).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0083EE).withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0083EE),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Gradient gradient,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
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
                  fontSize: isTablet ? 32 : 28,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: EdgeInsets.all(isTablet ? 12 : 10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: isTablet ? 24 : 20,
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 14 : 12,
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
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
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
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Text(
                percentage,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Container(
            height: isTablet ? 10 : 8,
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

  Widget _buildStudentCard(
    Map<String, dynamic> student,
    int index,
    bool isTablet, {
    bool isGrid = false,
  }) {
    double totalPoints =
        ((student['apresiasi'] as num) + (student['pelanggaran'] as num))
            .toDouble();
    double apresiasiRatio =
        totalPoints > 0 ? (student['apresiasi'] as num) / totalPoints : 0;
    double pelanggaranRatio =
        totalPoints > 0 ? (student['pelanggaran'] as num) / totalPoints : 0;

    return GestureDetector(
      onTap: () => _showStudentDetail(student, isTablet),
      child: Container(
        margin:
            isGrid
                ? EdgeInsets.zero
                : EdgeInsets.only(bottom: isTablet ? 16 : 12),
        padding: EdgeInsets.all(isTablet ? 24 : 20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isTablet ? 60 : 50,
                  height: isTablet ? 60 : 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEDBCC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      student['avatar'],
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 20 : 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFEA580C),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student['name'],
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1F2937),
                        ),
                        maxLines: isGrid ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        '${student['kelas']} | A: ${student['apresiasi']} | P: ${student['pelanggaran']}',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 13 : 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: isTablet ? 20 : 16),
                Column(
                  children: [
                    Text(
                      '${student['totalPoin']}',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.w800,
                        color: student['color'],
                      ),
                    ),
                    Text(
                      'Total Poin',
                      style: GoogleFonts.poppins(
                        fontSize: isTablet ? 12 : 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Container(
              height: isTablet ? 8 : 6,
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
    );
  }

  void _showStudentDetail(Map<String, dynamic> student, bool isTablet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: isTablet ? 80 : 60,
                    height: isTablet ? 80 : 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEDBCC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        student['name'][0].toUpperCase(),
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 28 : 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFEA580C),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 20 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'],
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${student['kelas']}',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 16 : 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, size: isTablet ? 28 : 24),
                  ),
                ],
              ),
              SizedBox(height: isTablet ? 32 : 24),
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
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
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Total Poin',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: isTablet ? 48 : 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '${student['apresiasi']}',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Apresiasi',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: isTablet ? 48 : 40,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Column(
                      children: [
                        Text(
                          '${student['pelanggaran']}',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 32 : 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Pelanggaran',
                          style: GoogleFonts.poppins(
                            fontSize: isTablet ? 14 : 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 24 : 20),
              Text(
                'Daftar Nilai',
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 20 : 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16,
                  vertical: isTablet ? 16 : 12,
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
                          fontSize: isTablet ? 14 : 12,
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
                          fontSize: isTablet ? 14 : 12,
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
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isTablet ? 12 : 8),
              Expanded(
                child: ListView.builder(
                  itemCount: student['scores'].length,
                  itemBuilder: (context, index) {
                    final score = student['scores'][index];
                    return Container(
                      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 20 : 16,
                        vertical: isTablet ? 16 : 12,
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
                                fontSize: isTablet ? 15 : 13,
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
                                fontSize: isTablet ? 14 : 12,
                                color: const Color(0xFF0083EE),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isTablet ? 12 : 8,
                                vertical: isTablet ? 6 : 4,
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
                                  fontSize: isTablet ? 14 : 12,
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
