import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/notifikasi.dart';
import 'package:skoring/screens/profile.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:docx_template/docx_template.dart';
import 'package:excel/excel.dart' as excel;
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = '0-50';
  String _selectedView = 'Rekap'; 
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final Map<String, bool> _expandedSections = {
    'R1': false, 'R2': false, 'R3': false, 'R4': false, 'R5': false,
    'R6': false, 'R7': false, 'R8': false, 'R9': false, 'R10': false,
    'P1': false, 'P2': false, 'P3': false, 'P4': false, 'P5': false,
    'Sanksi': false,
  };

  final List<Map<String, dynamic>> _studentsData = [
    {
      'name': 'Abijalu Anggra Putra',
      'totalPoin': 27,
      'apresiasi': 30,
      'pelanggaran': 3,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'AP',
      'scores': [
        {'keterangan': 'Terlibat Tawuran', 'tanggal': '12 Juli 2025', 'poin': -45, 'type': 'pelanggaran'},
        {'keterangan': 'Juara 1 Olimpiade', 'tanggal': '10 Juli 2025', 'poin': 50, 'type': 'apresiasi'},
        {'keterangan': 'Membantu Guru', 'tanggal': '8 Juli 2025', 'poin': 22, 'type': 'apresiasi'},
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
      'scores': [
        {'keterangan': 'Terlibat Tawuran', 'tanggal': '12 Juli 2025', 'poin': -45, 'type': 'pelanggaran'},
        {'keterangan': 'Datang Terlambat', 'tanggal': '11 Juli 2025', 'poin': -5, 'type': 'pelanggaran'},
        {'keterangan': 'Membantu Teman', 'tanggal': '9 Juli 2025', 'poin': 5, 'type': 'apresiasi'},
      ],
    },
    {
      'name': 'Arga Teja',
      'totalPoin': -8,
      'apresiasi': 12,
      'pelanggaran': 20,
      'isPositive': false,
      'color': const Color(0xFFFF6B6D),
      'avatar': 'AT',
      'scores': [
        {'keterangan': 'Tidak Mengerjakan PR', 'tanggal': '13 Juli 2025', 'poin': -20, 'type': 'pelanggaran'},
        {'keterangan': 'Membantu Kebersihan', 'tanggal': '10 Juli 2025', 'poin': 12, 'type': 'apresiasi'},
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
      'scores': [
        {'keterangan': 'Juara 1 Lomba Desain', 'tanggal': '14 Juli 2025', 'poin': 50, 'type': 'apresiasi'},
        {'keterangan': 'Aktif di Kelas', 'tanggal': '12 Juli 2025', 'poin': 30, 'type': 'apresiasi'},
        {'keterangan': 'Terlambat', 'tanggal': '11 Juli 2025', 'poin': -5, 'type': 'pelanggaran'},
      ],
    },
    {
      'name': 'Citra Dewi',
      'totalPoin': 12,
      'apresiasi': 20,
      'pelanggaran': 8,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'CD',
      'scores': [
        {'keterangan': 'Terlibat Tawuran', 'tanggal': '12 Juli 2025', 'poin': -45, 'type': 'pelanggaran'},
        {'keterangan': 'Membantu Guru', 'tanggal': '10 Juli 2025', 'poin': 20, 'type': 'apresiasi'},
        {'keterangan': 'Piket Kelas', 'tanggal': '8 Juli 2025', 'poin': 15, 'type': 'apresiasi'},
      ],
    },
    {
      'name': 'Deni Ramadan',
      'totalPoin': -15,
      'apresiasi': 10,
      'pelanggaran': 25,
      'isPositive': false,
      'color': const Color(0xFFFF6B6D),
      'avatar': 'DR',
      'scores': [
        {'keterangan': 'Bolos Sekolah', 'tanggal': '13 Juli 2025', 'poin': -25, 'type': 'pelanggaran'},
        {'keterangan': 'Membantu Teman', 'tanggal': '9 Juli 2025', 'poin': 10, 'type': 'apresiasi'},
      ],
    },
    {
      'name': 'Eka Putri',
      'totalPoin': 120,
      'apresiasi': 125,
      'pelanggaran': 5,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'EP',
      'scores': [
        {'keterangan': 'Juara 1 Olimpiade Nasional', 'tanggal': '15 Juli 2025', 'poin': 100, 'type': 'apresiasi'},
        {'keterangan': 'Ketua Kelas Teladan', 'tanggal': '12 Juli 2025', 'poin': 25, 'type': 'apresiasi'},
        {'keterangan': 'Terlambat', 'tanggal': '10 Juli 2025', 'poin': -5, 'type': 'pelanggaran'},
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
      'scores': [
        {'keterangan': 'Juara 2 Lomba Programming', 'tanggal': '14 Juli 2025', 'poin': 40, 'type': 'apresiasi'},
        {'keterangan': 'Membantu Guru', 'tanggal': '11 Juli 2025', 'poin': 30, 'type': 'apresiasi'},
        {'keterangan': 'Lupa PR', 'tanggal': '9 Juli 2025', 'poin': -5, 'type': 'pelanggaran'},
      ],
    },
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
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double get _averageApresiasi {
    if (_studentsData.isEmpty) return 0;
    double total = _studentsData.fold(0, (sum, student) => sum + student['apresiasi']);
    return total / _studentsData.length;
  }

  double get _apresiasiPercentage {
    if (_studentsData.isEmpty) return 0;
    int positiveCount = _studentsData.where((student) => student['apresiasi'] > 50).length;
    return positiveCount / _studentsData.length;
  }

  double get _pelanggaranPercentage {
    if (_studentsData.isEmpty) return 0;
    int lowViolationCount = _studentsData.where((student) => student['pelanggaran'] < 10).length;
    return lowViolationCount / _studentsData.length;
  }

  List<Map<String, dynamic>> get _filteredAndSortedStudents {
    List<Map<String, dynamic>> filtered = _studentsData.where((student) {
      bool matchesSearch = student['name'].toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;

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
                      color: _selectedFilter == filter ? const Color(0xFF0083EE) : const Color(0xFF1F2937),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Ekspor Data',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pilih format ekspor untuk ${_filteredAndSortedStudents.length} siswa dengan filter $_selectedFilter:',
                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280)),
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
                title: Text('Word', style: GoogleFonts.poppins(fontSize: 15)),
                onTap: () {
                  Navigator.pop(context);
                  _exportToWord();
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
                style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF0083EE)),
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
                'Laporan Penilaian Siswa XII RPL 2 - Semester Ganjil 2025/2026',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Nama', 'Total Poin', 'Apresiasi', 'Pelanggaran'],
              data: _filteredAndSortedStudents.map((student) => [
                    student['name'],
                    student['totalPoin'].toString(),
                    student['apresiasi'].toString(),
                    student['pelanggaran'].toString(),
                  ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Detail Nilai', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ..._filteredAndSortedStudents.map((student) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 10),
                  pw.Text(student['name'], style: const pw.TextStyle(fontSize: 14)),
                  pw.Table.fromTextArray(
                    headers: ['Keterangan', 'Tanggal', 'Poin', 'Tipe'],
                    data: (student['scores'] as List<Map<String, dynamic>>)
                        .map((score) => [
                              score['keterangan'],
                              score['tanggal'],
                              score['poin'].toString(),
                              score['type'],
                            ])
                        .toList(),
                  ),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await FileSaver.instance.saveFile(
      name: 'Laporan_Siswa_XII_RPL_2.pdf',
      bytes: bytes,
      mimeType: MimeType.pdf,
    );
  }

  Future<void> _exportToWord() async {
    try {
      final templateBytes = await DefaultAssetBundle.of(context).load('assets/template.docx');
      final doc = await DocxTemplate.fromBytes(templateBytes.buffer.asUint8List());
      final content = Content();
      final rows = _filteredAndSortedStudents.map((student) {
        return RowContent({
          'name': TextContent('name', student['name']),
          'totalPoin': TextContent('totalPoin', student['totalPoin'].toString()),
          'apresiasi': TextContent('apresiasi', student['apresiasi'].toString()),
          'pelanggaran': TextContent('pelanggaran', student['pelanggaran'].toString()),
        });
      }).toList();
      content.add(TableContent('students', rows));
      final docGenerated = await doc.generate(content);

      if (docGenerated == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menghasilkan dokumen Word')));
        return;
      }

      await FileSaver.instance.saveFile(
        name: 'Laporan_Siswa_XII_RPL_2.docx',
        bytes: Uint8List.fromList(docGenerated),
        mimeType: MimeType.microsoftWord,
      );

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dokumen Word berhasil diekspor')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saat ekspor Word: $e')));
    }
  }

  Future<void> _exportToExcel() async {
    final excelInstance = excel.Excel.createExcel();
    final sheet = excelInstance['Sheet1'];
    sheet.appendRow(['Nama', 'Total Poin', 'Apresiasi', 'Pelanggaran']);
    for (var student in _filteredAndSortedStudents) {
      sheet.appendRow([
        student['name'],
        student['totalPoin'].toString(),
        student['apresiasi'].toString(),
        student['pelanggaran'].toString(),
      ]);
      sheet.appendRow(['Keterangan', 'Tanggal', 'Poin', 'Tipe']);
      for (var score in student['scores']) {
        sheet.appendRow([
          score['keterangan'],
          score['tanggal'],
          score['poin'].toString(),
          score['type'],
        ]);
      }
      sheet.appendRow(['']);
    }
    final bytes = excelInstance.encode();
    await FileSaver.instance.saveFile(
      name: 'Laporan_Siswa_XII_RPL_2.xlsx',
      bytes: Uint8List.fromList(bytes!),
      mimeType: MimeType.microsoftExcel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
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
                    boxShadow: [BoxShadow(color: Color(0x200083EE), blurRadius: 20, offset: Offset(0, 10))],
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
                                child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const NotifikasiScreen()));
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))],
                                    ),
                                    child: const Icon(Icons.person_rounded, color: Color(0xFF0083EE), size: 24),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Penilaian Siswa XII RPL 2',
                                style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700, height: 1.2),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Semester Ganjil 2025/2026',
                                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)]),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(Icons.search, color: Colors.white, size: 18),
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
                                    hintText: 'Cari nama murid...',
                                    hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 15, fontWeight: FontWeight.w400),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                  ),
                                  style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF1F2937)),
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
                                    child: const Icon(Icons.clear, color: Color(0xFF9CA3AF), size: 20),
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
                            _buildViewButton('FAQ Point', 'FAQ Point'),
                          ],
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
                      if (_selectedView == 'Rekap') ...[
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '${_studentsData.length}',
                                'Total Siswa',
                                Icons.people_outline,
                                const LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                '${_averageApresiasi.toInt()}',
                                'Rata-rata\nApresiasi',
                                Icons.check_circle_outline,
                                const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
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
                                const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildProgressCard(
                                'Pelanggaran',
                                '${(_pelanggaranPercentage * 100).toInt()}%',
                                _pelanggaranPercentage,
                                const LinearGradient(colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)]),
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
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Hasil Akumulasi',
                                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: _showFilterBottomSheet,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _selectedFilter == 'Negatif'
                                                ? 'Nilai Negatif'
                                                : _selectedFilter == '101+'
                                                    ? '101 ke atas'
                                                    : _selectedFilter,
                                            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF374151)),
                                          ),
                                          const SizedBox(width: 8),
                                          const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF6B7280)),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _showExportDialog,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFFE5E7EB)),
                                      ),
                                      child: const Icon(Icons.download_rounded, color: Color(0xFF374151), size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (_filteredAndSortedStudents.isEmpty && _searchQuery.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada siswa ditemukan',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Coba ubah kata kunci pencarian atau filter',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        else if (_filteredAndSortedStudents.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.filter_list_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada siswa dalam range ini',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Coba pilih filter lain',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        else
                          ...List.generate(_filteredAndSortedStudents.length, (index) {
                            return _buildStudentCard(_filteredAndSortedStudents[index], index);
                          }),
                      ] else ...[
                       
                        _buildSectionTitle('Lembar 1 – Penghargaan dan Apresiasi'),
                        _buildFaqSection('R1', 'Pengembangan Keagamaan', [
                          _buildFaqItem('Melaksanakan praktik-praktik keagamaan sesuai agama dan kepercayaannya masing-masing.', '20 poin'),
                        ]),
                        _buildFaqSection('R2', 'Kejujuran', [
                          _buildFaqItem('Menyampaikan / melaporkan barang temuan.', '20 poin'),
                          _buildFaqItem('Berkata jujur dalam kesaksian.', '20 poin'),
                          _buildFaqItem('Melaporkan tindakan pelanggaran / negatif yang dilakukan orang lain kepada pihak sekolah / berwajib.', '20 poin'),
                          _buildFaqItem('Jujur dalam menyelesaikan ujian.', '10 poin'),
                        ]),
                        _buildFaqSection('R3', 'Prestasi Akademis', [
                          _buildFaqItem('Berhasil menjadi peringkat pertama di kelas setiap semester.', '20 poin'),
                          _buildFaqItem('Berhasil menjadi peringkat 5 besar di kelas setiap semester.', '15 poin'),
                          _buildFaqItem('Berhasil menjadi peringkat 10 besar di kelas setiap semester.', '10 poin'),
                          _buildFaqItem('Aktif dalam kegiatan belajar.', '10 poin'),
                          _buildFaqItem('Menghasilkan karya inovatif yang menunjang proses pembelajaran.', '20 poin'),
                          _buildFaqItem('Menjadi peserta didik berprestasi di tingkat sekolah.', '10 poin'),
                          _buildFaqItem('Menjadi peserta didik berprestasi di tingkat kota.', '20 poin'),
                          _buildFaqItem('Menjadi peserta didik berprestasi di tingkat provinsi.', '30 poin'),
                          _buildFaqItem('Menjadi peserta didik berprestasi di tingkat nasional.', '40 poin'),
                          _buildFaqItem('Memperoleh beasiswa prestasi dari instansi/lembaga/yayasan.', '20 poin'),
                        ]),
                        _buildFaqSection('R4', 'Kedisiplinan', [
                          _buildFaqItem('Menyimpan alat-alat pembelajaran di tempatnya.', '10 poin'),
                          _buildFaqItem('Tidak pernah melanggar tata tertib minimal 3 bulan berturut-turut.', '20 poin'),
                          _buildFaqItem('Tidak pernah melanggar tata tertib minimal 6 bulan berturut-turut.', '30 poin'),
                          _buildFaqItem('Tidak pernah melanggar tata tertib minimal 9 bulan berturut-turut.', '40 poin'),
                          _buildFaqItem('Tidak pernah melanggar tata tertib minimal 12 bulan berturut-turut.', '50 poin'),
                        ]),
                        _buildFaqSection('R5', 'Pengembangan Sosial', [
                          _buildFaqItem('Membantu/menolong orang yang kena musibah.', '10 poin'),
                          _buildFaqItem('Terlibat dalam aksi sosial, seperti bakti sosial ke rumah yatim, donor darah, dan kegiatan sosial lainnya.', '15 poin'),
                        ]),
                        _buildFaqSection('R6', 'Kepemimpinan', [
                          _buildFaqItem('Mengikuti kegiatan LDKS (Latihan Dasar Kepemimpinan Siswa).', '10 poin'),
                          _buildFaqItem('Menjadi ketua OSIS/MPK selama satu periode.', '20 poin'),
                          _buildFaqItem('Menjadi pengurus OSIS/MPK selama satu periode.', '10 poin'),
                          _buildFaqItem('Menjadi ketua kegiatan ekstrakurikuler.', '15 poin'),
                          _buildFaqItem('Menjadi ketua kelompok belajar.', '10 poin'),
                        ]),
                        _buildFaqSection('R7', 'Kebangsaan', [
                          _buildFaqItem('Mengikuti kegiatan Pendidikan Kesadaran Bela Negara.', '10 poin'),
                          _buildFaqItem('Melaksanakan nilai-nilai Pancasila dan UUD 1945 dalam keseharian.', '10 poin'),
                          _buildFaqItem('Menjadi petugas upacara di sekolah.', '10 poin'),
                          _buildFaqItem('Menjadi petugas upacara di tingkat kota.', '20 poin'),
                          _buildFaqItem('Menjadi petugas upacara di tingkat provinsi.', '30 poin'),
                          _buildFaqItem('Menjadi petugas upacara di tingkat nasional.', '40 poin'),
                          _buildFaqItem('Menjadi duta budaya/seni/pertukaran pelajar.', '30 poin'),
                        ]),
                        _buildFaqSection('R8', 'Ekstrakurikuler dan Prestasi', [
                          _buildFaqItem('Aktif dalam kegiatan ekstrakurikuler wajib.', '10 poin'),
                          _buildFaqItem('Aktif dalam kegiatan ekstrakurikuler lainnya.', '10 poin'),
                          _buildFaqItem('Menjadi peserta perlombaan/kegiatan mewakili sekolah.', '5 poin'),
                          _buildFaqItem('Menjadi juara di tingkat sekolah.', '5 poin'),
                          _buildFaqItem('Menjadi juara di tingkat kota/kabupaten.', '20 poin'),
                          _buildFaqItem('Menjadi juara di tingkat provinsi.', '30 poin'),
                          _buildFaqItem('Menjadi juara di tingkat nasional.', '40 poin'),
                          _buildFaqItem('Menjadi juara di tingkat internasional.', '50 poin'),
                        ]),
                        _buildFaqSection('R9', 'Peduli Lingkungan', [
                          _buildFaqItem('Membuang dan memilah sampah pada tempatnya/sesuai jenis.', '10 poin'),
                          _buildFaqItem('Menghasilkan karya inovatif untuk pelestarian lingkungan.', '20 poin'),
                          _buildFaqItem('Memberikan ide/gagasan yang mengatasi masalah lingkungan.', '20 poin'),
                          _buildFaqItem('Menjadi motivator dan inovator dalam memelihara potensi lokal (seni dan budaya).', '20 poin'),
                          _buildFaqItem('Mengikuti kegiatan Reboisasi/menanam pohon.', '10 poin'),
                        ]),
                        _buildFaqSection('R10', 'Kewirausahaan', [
                          _buildFaqItem('Memberi ide/gagasan yang dapat menambah nilai ekonomis.', '10 poin'),
                          _buildFaqItem('Aktif mengikuti kegiatan kewirausahaan sekolah.', '15 poin'),
                          _buildFaqItem('Membuat produk kreatif bernilai jual.', '20 poin'),
                        ]),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Lembar 2 – Pelanggaran dan Sanksi'),
                        _buildFaqSection('P1', 'Terlambat', [
                          _buildFaqItem('Terlambat hadir ke sekolah.', '5 poin per kejadian'),
                        ]),
                        _buildFaqSection('P2', 'Kehadiran', [
                          _buildFaqItem('Tidak mengikuti pelajaran tanpa izin.', '10 poin per jam'),
                        ]),
                        _buildFaqSection('P3', 'Seragam', [
                          _buildFaqItem('Tidak memakai seragam sesuai ketentuan.', '5 poin'),
                        ]),
                        _buildFaqSection('P4', 'Kerapian dan Penampilan', [
                          _buildFaqItem('Rambut tidak rapi atau tidak sesuai ketentuan.', '10 poin'),
                          _buildFaqItem('Memakai aksesoris berlebihan.', '10 poin'),
                        ]),
                        _buildFaqSection('P5', 'Kedisiplinan Berat', [
                          _buildFaqItem('Berkelahi/tawuran.', '50 poin'),
                          _buildFaqItem('Membawa senjata tajam/narkoba.', '50 poin'),
                          _buildFaqItem('Vandalisme.', '30 poin'),
                        ]),
                        _buildFaqSection('Sanksi', 'Ketentuan Sanksi Berdasarkan Akumulasi Poin', [
                          _buildFaqItem('25 poin', 'Teguran lisan'),
                          _buildFaqItem('50 poin', 'Teguran tertulis/SP1'),
                          _buildFaqItem('75 poin', 'Pemanggilan orang tua/SP2'),
                          _buildFaqItem('100 poin', 'Skorsing/SP3'),
                          _buildFaqItem('100 poin', 'Dikeluarkan dari sekolah'),
                        ]),
                        const SizedBox(height: 16),
                        Text(
                          'Ketentuan Konversi Skor Penghargaan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Skor penghargaan dapat dikonversi ke bentuk sertifikat, hadiah, atau gelar Anugerah Waluya Utama sesuai ketentuan sekolah.',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
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
  }

  Widget _buildViewButton(String text, String view) {
    bool isActive = _selectedView == view;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedView = view);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))]
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
                    gradient: LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)]),
                    shape: BoxShape.circle,
                  ),
                ),
              if (isActive && view == 'FAQ Point')
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildFaqSection(String code, String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: _expandedSections[code] ?? false,
        onExpansionChanged: (expanded) {
          setState(() {
            _expandedSections[code] = expanded;
          });
        },
        title: Text(
          '$code – $title',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
        iconColor: const Color(0xFF0083EE),
        collapsedIconColor: const Color(0xFF6B7280),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              question,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              answer,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: const Color(0xFF1F2937)),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String percentage, double progress, Gradient gradient) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
              ),
              Text(
                percentage,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(4)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(4))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    double totalPoints = (student['apresiasi'] + student['pelanggaran']).toDouble();
    double apresiasiRatio = totalPoints > 0 ? student['apresiasi'] / totalPoints : 0;
    double pelanggaranRatio = totalPoints > 0 ? student['pelanggaran'] / totalPoints : 0;

    return GestureDetector(
      onTap: () => _showStudentDetail(student),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: student['isPositive'] ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFFF6B6D).withOpacity(0.2),
            width: 2,
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(color: const Color(0xFFFEDBCC), borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  student['avatar'],
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFFEA580C)),
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
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Apresiasi: ${student['apresiasi']} | ',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFF10B981)),
                      ),
                      Text(
                        'Pelanggaran: ${student['pelanggaran']}',
                        style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w500, color: const Color(0xFFFF6B6D)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 6,
                    decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(3)),
                    child: Row(
                      children: [
                        Expanded(
                          flex: (apresiasiRatio * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(3), bottomLeft: Radius.circular(3)),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: (pelanggaranRatio * 100).toInt(),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B6D),
                              borderRadius: BorderRadius.only(topRight: Radius.circular(3), bottomRight: Radius.circular(3)),
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
                  style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w800, color: student['color']),
                ),
                Text(
                  'Total Poin',
                  style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
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
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                    decoration: BoxDecoration(color: const Color(0xFFFEDBCC), borderRadius: BorderRadius.circular(20)),
                    child: Center(
                      child: Text(
                        student['avatar'],
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFFEA580C)),
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
                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                        ),
                        Text(
                          'XII RPL 2',
                          style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: student['isPositive']
                      ? const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)])
                      : const LinearGradient(colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text(
                          '${student['totalPoin']}',
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text(
                          'Total Poin',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                    Column(
                      children: [
                        Text(
                          '${student['apresiasi']}',
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text(
                          'Apresiasi',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
                    Column(
                      children: [
                        Text(
                          '${student['pelanggaran']}',
                          style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        Text(
                          'Pelanggaran',
                          style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Daftar Nilai',
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Tanggal',
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        'Poin',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF6B7280)),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: score['type'] == 'apresiasi' ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFFF6B6D).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              score['keterangan'],
                              style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF1F2937)),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              score['tanggal'],
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF0083EE)),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: score['type'] == 'apresiasi' ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFFF6B6D).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${score['poin']}',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: score['type'] == 'apresiasi' ? const Color(0xFF10B981) : const Color(0xFFFF6B6D),
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