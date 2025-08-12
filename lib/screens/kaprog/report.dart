import 'package:flutter/material.dart';
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

class _LaporanKaprogState extends State<LaporanKaprog> with TickerProviderStateMixin {
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

  final Map<String, Map<String, dynamic>> _faqData = {
    'R1': {
      'title': 'Pengembangan Keagamaan',
      'items': [
        {'text': 'Melaksanakan praktik-praktik keagamaan sesuai agama dan kepercayaannya masing-masing.', 'points': '20 poin'},
      ]
    },
    'R2': {
      'title': 'Kejujuran',
      'items': [
        {'text': 'Menyampaikan / melaporkan barang temuan.', 'points': '20 poin'},
        {'text': 'Berkata jujur dalam kesaksian.', 'points': '20 poin'},
        {'text': 'Melaporkan tindakan pelanggaran / negatif yang dilakukan orang lain kepada pihak sekolah / berwajib.', 'points': '20 poin'},
        {'text': 'Jujur dalam menyelesaikan ujian.', 'points': '10 poin'},
      ]
    },
    'R3': {
      'title': 'Prestasi Akademis',
      'items': [
        {'text': 'Berhasil menjadi peringkat pertama di kelas setiap semester.', 'points': '20 poin'},
        {'text': 'Berhasil menjadi peringkat 5 besar di kelas setiap semester.', 'points': '15 poin'},
        {'text': 'Berhasil menjadi peringkat 10 besar di kelas setiap semester.', 'points': '10 poin'},
        {'text': 'Aktif dalam kegiatan belajar.', 'points': '10 poin'},
        {'text': 'Menghasilkan karya inovatif yang menunjang proses pembelajaran.', 'points': '20 poin'},
        {'text': 'Menjadi peserta didik berprestasi di tingkat sekolah.', 'points': '10 poin'},
        {'text': 'Menjadi peserta didik berprestasi di tingkat kota.', 'points': '20 poin'},
        {'text': 'Menjadi peserta didik berprestasi di tingkat provinsi.', 'points': '30 poin'},
        {'text': 'Menjadi peserta didik berprestasi di tingkat nasional.', 'points': '40 poin'},
        {'text': 'Memperoleh beasiswa prestasi dari instansi/lembaga/yayasan.', 'points': '20 poin'},
      ]
    },
    'R4': {
      'title': 'Kedisiplinan',
      'items': [
        {'text': 'Menyimpan alat-alat pembelajaran di tempatnya.', 'points': '10 poin'},
        {'text': 'Tidak pernah melanggar tata tertib minimal 3 bulan berturut-turut.', 'points': '20 poin'},
        {'text': 'Tidak pernah melanggar tata tertib minimal 6 bulan berturut-turut.', 'points': '30 poin'},
        {'text': 'Tidak pernah melanggar tata tertib minimal 9 bulan berturut-turut.', 'points': '40 poin'},
        {'text': 'Tidak pernah melanggar tata tertib minimal 12 bulan berturut-turut.', 'points': '50 poin'},
      ]
    },
    'R5': {
      'title': 'Pengembangan Sosial',
      'items': [
        {'text': 'Membantu/menolong orang yang kena musibah.', 'points': '10 poin'},
        {'text': 'Terlibat dalam aksi sosial, seperti bakti sosial ke rumah yatim, donor darah, dan kegiatan sosial lainnya.', 'points': '15 poin'},
      ]
    },
    'R6': {
      'title': 'Kepemimpinan',
      'items': [
        {'text': 'Mengikuti kegiatan LDKS (Latihan Dasar Kepemimpinan Siswa).', 'points': '10 poin'},
        {'text': 'Menjadi ketua OSIS/MPK selama satu periode.', 'points': '20 poin'},
        {'text': 'Menjadi pengurus OSIS/MPK selama satu periode.', 'points': '10 poin'},
        {'text': 'Menjadi ketua kegiatan ekstrakurikuler.', 'points': '15 poin'},
        {'text': 'Menjadi ketua kelompok belajar.', 'points': '10 poin'},
      ]
    },
    'R7': {
      'title': 'Kebangsaan',
      'items': [
        {'text': 'Mengikuti kegiatan Pendidikan Kesadaran Bela Negara.', 'points': '10 poin'},
        {'text': 'Melaksanakan nilai-nilai Pancasila dan UUD 1945 dalam keseharian.', 'points': '10 poin'},
        {'text': 'Menjadi petugas upacara di sekolah.', 'points': '10 poin'},
        {'text': 'Menjadi petugas upacara di tingkat kota.', 'points': '20 poin'},
        {'text': 'Menjadi petugas upacara di tingkat provinsi.', 'points': '30 poin'},
        {'text': 'Menjadi petugas upacara di tingkat nasional.', 'points': '40 poin'},
        {'text': 'Menjadi duta budaya/seni/pertukaran pelajar.', 'points': '30 poin'},
      ]
    },
    'R8': {
      'title': 'Ekstrakurikuler dan Prestasi',
      'items': [
        {'text': 'Aktif dalam kegiatan ekstrakurikuler wajib.', 'points': '10 poin'},
        {'text': 'Aktif dalam kegiatan ekstrakurikuler lainnya.', 'points': '10 poin'},
        {'text': 'Menjadi peserta perlombaan/kegiatan mewakili sekolah.', 'points': '5 poin'},
        {'text': 'Menjadi juara di tingkat sekolah.', 'points': '5 poin'},
        {'text': 'Menjadi juara di tingkat kota/kabupaten.', 'points': '20 poin'},
        {'text': 'Menjadi juara di tingkat provinsi.', 'points': '30 poin'},
        {'text': 'Menjadi juara di tingkat nasional.', 'points': '40 poin'},
        {'text': 'Menjadi juara di tingkat internasional.', 'points': '50 poin'},
      ]
    },
    'R9': {
      'title': 'Peduli Lingkungan',
      'items': [
        {'text': 'Membuang dan memilah sampah pada tempatnya/sesuai jenis.', 'points': '10 poin'},
        {'text': 'Menghasilkan karya inovatif untuk pelestarian lingkungan.', 'points': '20 poin'},
        {'text': 'Memberikan ide/gagasan yang mengatasi masalah lingkungan.', 'points': '20 poin'},
        {'text': 'Menjadi motivator dan inovator dalam memelihara potensi lokal (seni dan budaya).', 'points': '20 poin'},
        {'text': 'Mengikuti kegiatan Reboisasi/menanam pohon.', 'points': '10 poin'},
      ]
    },
    'R10': {
      'title': 'Kewirausahaan',
      'items': [
        {'text': 'Memberi ide/gagasan yang dapat menambah nilai ekonomis.', 'points': '10 poin'},
        {'text': 'Aktif mengikuti kegiatan kewirausahaan sekolah.', 'points': '15 poin'},
        {'text': 'Membuat produk kreatif bernilai jual.', 'points': '20 poin'},
      ]
    },
    'P1': {
      'title': 'Terlambat',
      'items': [
        {'text': 'Terlambat hadir ke sekolah.', 'points': '5 poin per kejadian'},
      ]
    },
    'P2': {
      'title': 'Kehadiran',
      'items': [
        {'text': 'Tidak mengikuti pelajaran tanpa izin.', 'points': '10 poin per jam'},
      ]
    },
    'P3': {
      'title': 'Seragam',
      'items': [
        {'text': 'Tidak memakai seragam sesuai ketentuan.', 'points': '5 poin'},
      ]
    },
    'P4': {
      'title': 'Kerapian dan Penampilan',
      'items': [
        {'text': 'Rambut tidak rapi atau tidak sesuai ketentuan.', 'points': '10 poin'},
        {'text': 'Memakai aksesoris berlebihan.', 'points': '10 poin'},
      ]
    },
    'P5': {
      'title': 'Kedisiplinan Berat',
      'items': [
        {'text': 'Berkelahi/tawuran.', 'points': '50 poin'},
        {'text': 'Membawa senjata tajam/narkoba.', 'points': '50 poin'},
        {'text': 'Vandalisme.', 'points': '30 poin'},
      ]
    },
    'Sanksi': {
      'title': 'Ketentuan Sanksi Berdasarkan Akumulasi Poin',
      'items': [
        {'text': '25 poin', 'points': 'Teguran lisan'},
        {'text': '50 poin', 'points': 'Teguran tertulis/SP1'},
        {'text': '75 poin', 'points': 'Pemanggilan orang tua/SP2'},
        {'text': '100 poin', 'points': 'Skorsing/SP3'},
        {'text': '100 poin', 'points': 'Dikeluarkan dari sekolah'},
      ]
    },
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

  Map<String, Map<String, dynamic>> get _filteredFaqData {
    if (_searchQuery.isEmpty) {
      return _faqData;
    }

    Map<String, Map<String, dynamic>> filtered = {};
    String searchLower = _searchQuery.toLowerCase();

    _faqData.forEach((key, section) {
      bool titleMatches = section['title'].toString().toLowerCase().contains(searchLower);
      
      List<Map<String, dynamic>> matchingItems = [];
      for (var item in section['items']) {
        if (item['text'].toString().toLowerCase().contains(searchLower) ||
            item['points'].toString().toLowerCase().contains(searchLower)) {
          matchingItems.add(item);
        }
      }

      if (titleMatches || matchingItems.isNotEmpty) {
        filtered[key] = {
          'title': section['title'],
          'items': titleMatches ? section['items'] : matchingItems,
        };
      }
    });

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
                                    hintText: _selectedView == 'Rekap'
                                        ? 'Cari nama murid...'
                                        : 'Cari aturan atau poin...',
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
                        if (_filteredFaqData.isEmpty && _searchQuery.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'Tidak ada aturan ditemukan',
                                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Coba ubah kata kunci pencarian',
                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                                ),
                              ],
                            ),
                          )
                        else ...[
                          if (_searchQuery.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0083EE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF0083EE).withOpacity(0.2)),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.search, color: const Color(0xFF0083EE), size: 20),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Menampilkan ${_filteredFaqData.length} hasil untuk "$_searchQuery"',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0083EE),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          _buildSectionTitle('Lembar 1 – Penghargaan dan Apresiasi'),
                          ..._filteredFaqData.entries
                              .where((entry) => entry.key.startsWith('R'))
                              .map((entry) => _buildFaqSection(
                                    entry.key,
                                    entry.value['title'],
                                    (entry.value['items'] as List<Map<String, dynamic>>)
                                        .map((item) => _buildFaqItem(item['text'], item['points']))
                                        .toList(),
                                  )),
                          const SizedBox(height: 24),
                          _buildSectionTitle('Lembar 2 – Pelanggaran dan Sanksi'),
                          ..._filteredFaqData.entries
                              .where((entry) => entry.key.startsWith('P') || entry.key == 'Sanksi')
                              .map((entry) => _buildFaqSection(
                                    entry.key,
                                    entry.value['title'],
                                    (entry.value['items'] as List<Map<String, dynamic>>)
                                        .map((item) => _buildFaqItem(item['text'], item['points']))
                                        .toList(),
                                  )),
                          const SizedBox(height: 16),
                          if (_searchQuery.isEmpty) ...[
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
        title: RichText(
          text: TextSpan(
            children: _highlightSearchText(
              '$code – $title',
              _searchQuery,
              GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
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
            child: RichText(
              text: TextSpan(
                children: _highlightSearchText(
                  question,
                  _searchQuery,
                  GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
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
            child: RichText(
              text: TextSpan(
                children: _highlightSearchText(
                  answer,
                  _searchQuery,
                  GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _highlightSearchText(String text, String searchQuery, TextStyle baseStyle) {
    if (searchQuery.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = searchQuery.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }
      
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: baseStyle.copyWith(
          backgroundColor: const Color(0xFFFFEB3B).withOpacity(0.3),
          fontWeight: FontWeight.w700,
        ),
      ));
      
      start = index + searchQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }
    
    return spans;
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
