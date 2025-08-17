import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryItem {
  final String id;
  final String type;
  final String description;
  final String date;
  final String time;
  final int points;
  final IconData icon;
  final Color color;
  final String? pemberi;
  final String? pelapor;
  final bool isNew;
  final bool isPelanggaran;
  final DateTime createdAt;

  HistoryItem({
    required this.id,
    required this.type,
    required this.description,
    required this.date,
    required this.time,
    required this.points,
    required this.icon,
    required this.color,
    this.pemberi,
    this.pelapor,
    required this.isNew,
    required this.isPelanggaran,
    required this.createdAt,
  });
}

class KaprogHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> student;

  const KaprogHistoryScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<KaprogHistoryScreen> createState() => _KaprogHistoryScreenState();
}

class _KaprogHistoryScreenState extends State<KaprogHistoryScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedFilter = 'Semua';
  String _selectedTimeFilter = 'Semua';
  bool _showOnlyNew = false;

  // Add TextEditingController for search
  final TextEditingController searchController = TextEditingController();
  List<HistoryItem> searchResults = [];

  List<HistoryItem> allHistory = [
    HistoryItem(
      id: "apr_001",
      type: "Prestasi Akademik",
      description: "Juara 1 Olimpiade Matematika Tingkat Kota",
      date: "22 Jul 2025",
      time: "14:00",
      points: 30,
      icon: Icons.emoji_events,
      color: Color(0xFFFFD700),
      pemberi: "Kepala Sekolah",
      isNew: true,
      isPelanggaran: false,
      createdAt: DateTime.now().subtract(Duration(hours: 2)),
    ),
    HistoryItem(
      id: "pel_002",
      type: "Pelanggaran Pakaian",
      description: "Tidak memakai seragam sesuai ketentuan",
      date: "21 Jul 2025",
      time: "07:00",
      points: -5,
      icon: Icons.checkroom,
      color: Color(0xFFEA580C),
      pelapor: "Bu Sari (Guru BK)",
      isNew: true,
      isPelanggaran: true,
      createdAt: DateTime.now().subtract(Duration(hours: 5)),
    ),
    HistoryItem(
      id: "apr_004",
      type: "Sikap Positif",
      description: "Membantu teman yang kesulitan belajar",
      date: "20 Jul 2025",
      time: "13:15",
      points: 10,
      icon: Icons.people_alt,
      color: Color(0xFF8B5CF6),
      pemberi: "Pak Rahman (Wali Kelas)",
      isNew: true,
      isPelanggaran: false,
      createdAt: DateTime.now().subtract(Duration(hours: 8)),
    ),
    HistoryItem(
      id: "apr_002",
      type: "Prestasi Non-Akademik",
      description: "Juara 2 Lomba Coding Regional",
      date: "19 Jul 2025",
      time: "16:30",
      points: 25,
      icon: Icons.code,
      color: Color(0xFF10B981),
      pemberi: "Pak Dedi (Guru Produktif)",
      isNew: false,
      isPelanggaran: false,
      createdAt: DateTime.now().subtract(Duration(days: 3)),
    ),
    HistoryItem(
      id: "pel_001",
      type: "Pelanggaran Kedisiplinan",
      description: "Terlambat masuk kelas lebih dari 15 menit",
      date: "18 Jul 2025",
      time: "07:30",
      points: -10,
      icon: Icons.access_time,
      color: Color(0xFFFF6B6D),
      pelapor: "Pak Budi (Guru Piket)",
      isNew: false,
      isPelanggaran: true,
      createdAt: DateTime.now().subtract(Duration(days: 4)),
    ),
    HistoryItem(
      id: "apr_003",
      type: "Kegiatan Sosial",
      description: "Membantu kegiatan bakti sosial sekolah",
      date: "16 Jul 2025",
      time: "08:00",
      points: 15,
      icon: Icons.volunteer_activism,
      color: Color(0xFF0EA5E9),
      pemberi: "Bu Lisa (Guru OSIS)",
      isNew: false,
      isPelanggaran: false,
      createdAt: DateTime.now().subtract(Duration(days: 6)),
    ),
    HistoryItem(
      id: "pel_003",
      type: "Pelanggaran Tugas",
      description: "Tidak mengumpulkan tugas matematika",
      date: "15 Jul 2025",
      time: "10:30",
      points: -8,
      icon: Icons.assignment_late,
      color: Color(0xFFFF6B6D),
      pelapor: "Bu Ani (Guru Matematika)",
      isNew: false,
      isPelanggaran: true,
      createdAt: DateTime.now().subtract(Duration(days: 7)),
    ),
    HistoryItem(
      id: "apr_005",
      type: "Prestasi Olahraga",
      description: "Juara 1 Lomba Badminton Antar Kelas",
      date: "10 Jul 2025",
      time: "15:00",
      points: 20,
      icon: Icons.sports,
      color: Color(0xFFFF9F43),
      pemberi: "Pak Joko (Guru Olahraga)",
      isNew: false,
      isPelanggaran: false,
      createdAt: DateTime.now().subtract(Duration(days: 12)),
    ),
    HistoryItem(
      id: "pel_004",
      type: "Pelanggaran Ketertiban",
      description: "Membuat keributan di dalam kelas",
      date: "08 Jul 2025",
      time: "09:45",
      points: -15,
      icon: Icons.volume_up,
      color: Color(0xFFFF6B6D),
      pelapor: "Bu Rina (Guru Bahasa Indonesia)",
      isNew: false,
      isPelanggaran: true,
      createdAt: DateTime.now().subtract(Duration(days: 14)),
    ),
    HistoryItem(
      id: "apr_006",
      type: "Sikap Kepemimpinan",
      description: "Memimpin kegiatan gotong royong kelas",
      date: "05 Jul 2025",
      time: "14:30",
      points: 12,
      icon: Icons.supervisor_account,
      color: Color(0xFF6366F1),
      pemberi: "Bu Maya (Guru PPKn)",
      isNew: false,
      isPelanggaran: false,
      createdAt: DateTime.now().subtract(Duration(days: 17)),
    ),
  ];

  @override
  void initState() {
    super.initState();

    _sortHistory();

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
    searchController.dispose();
    super.dispose();
  }

  void _sortHistory() {
    allHistory.sort((a, b) {
      if (a.isNew != b.isNew) {
        return a.isNew ? -1 : 1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  List<HistoryItem> _getFilteredHistory() {
    List<HistoryItem> filtered = allHistory;

    if (_selectedFilter != 'Semua') {
      if (_selectedFilter == 'Apresiasi') {
        filtered = filtered.where((item) => !item.isPelanggaran).toList();
      } else if (_selectedFilter == 'Pelanggaran') {
        filtered = filtered.where((item) => item.isPelanggaran).toList();
      }
    }

    if (_selectedTimeFilter != 'Semua') {
      DateTime now = DateTime.now();
      DateTime filterDate;

      switch (_selectedTimeFilter) {
        case '7 Hari':
          filterDate = now.subtract(Duration(days: 7));
          break;
        case '30 Hari':
          filterDate = now.subtract(Duration(days: 30));
          break;
        case '3 Bulan':
          filterDate = now.subtract(Duration(days: 90));
          break;
        default:
          filterDate = DateTime.fromMillisecondsSinceEpoch(0);
      }

      filtered =
          filtered.where((item) => item.createdAt.isAfter(filterDate)).toList();
    }

    if (_showOnlyNew) {
      filtered = filtered.where((item) => item.isNew).toList();
    }

    return filtered;
  }

  Widget _buildSearchResultCard(HistoryItem item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.type,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  item.description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${item.points > 0 ? '+' : ''}${item.points}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: item.color,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Filter Riwayat',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 20),

                  Text(
                    'Jenis Data',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    children:
                        ['Semua', 'Apresiasi', 'Pelanggaran'].map((filter) {
                          bool isSelected = _selectedFilter == filter;
                          return GestureDetector(
                            onTap: () {
                              setBottomSheetState(() {
                                _selectedFilter = filter;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Color(0xFF0083EE)
                                        : Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Color(0xFF0083EE)
                                          : Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                filter,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 24),

                  Text(
                    'Periode Waktu',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF374151),
                    ),
                  ),
                  SizedBox(height: 12),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['Semua', '7 Hari', '30 Hari', '3 Bulan'].map((filter) {
                          bool isSelected = _selectedTimeFilter == filter;
                          return GestureDetector(
                            onTap: () {
                              setBottomSheetState(() {
                                _selectedTimeFilter = filter;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? Color(0xFF0083EE)
                                        : Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? Color(0xFF0083EE)
                                          : Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Text(
                                filter,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Hanya Data Terbaru',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                      Switch(
                        value: _showOnlyNew,
                        onChanged: (value) {
                          setBottomSheetState(() {
                            _showOnlyNew = value;
                          });
                        },
                        activeColor: Color(0xFF0083EE),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0083EE),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Terapkan Filter',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.8,
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),

                  Row(
                    children: [
                      Icon(Icons.search, color: Color(0xFF0083EE)),
                      SizedBox(width: 12),
                      Text(
                        'Cari Riwayat',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan jenis, deskripsi...',
                      prefixIcon: Icon(Icons.search, color: Color(0xFF6B7280)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Color(0xFF0083EE)),
                      ),
                    ),
                    onChanged: (value) {
                      setBottomSheetState(() {
                        if (value.isEmpty) {
                          searchResults = [];
                        } else {
                          searchResults =
                              allHistory
                                  .where(
                                    (item) =>
                                        item.type.toLowerCase().contains(
                                          value.toLowerCase(),
                                        ) ||
                                        item.description.toLowerCase().contains(
                                          value.toLowerCase(),
                                        ),
                                  )
                                  .toList();
                        }
                      });
                    },
                  ),
                  SizedBox(height: 20),

                  Expanded(
                    child:
                        searchResults.isEmpty &&
                                searchController.text.isNotEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search_off,
                                    size: 64,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Tidak ada hasil ditemukan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : searchResults.isEmpty
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.search,
                                    size: 64,
                                    color: Color(0xFF9CA3AF),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Mulai mengetik untuk mencari',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : ListView.builder(
                              itemCount: searchResults.length,
                              itemBuilder: (context, index) {
                                return _buildSearchResultCard(
                                  searchResults[index],
                                );
                              },
                            ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<HistoryItem> filteredHistory = _getFilteredHistory();
    List<HistoryItem> newItems =
        filteredHistory.where((item) => item.isNew).toList();
    List<HistoryItem> oldItems =
        filteredHistory.where((item) => !item.isNew).toList();

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
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24).add(
                          EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top,
                          ),
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0083EE).withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
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
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Riwayat Lengkap',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${widget.student['name']}',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white.withOpacity(0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
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
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${filteredHistory.length} Item',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20),

                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _showSearchBottomSheet,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Cari',
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
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _showFilterBottomSheet,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.filter_list,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Filter',
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
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      if (_selectedFilter != 'Semua' ||
                          _selectedTimeFilter != 'Semua' ||
                          _showOnlyNew)
                        Container(
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Color(0xFF0083EE).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Color(0xFF0083EE).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.filter_alt,
                                color: Color(0xFF0083EE),
                                size: 16,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Filter aktif: ${_selectedFilter}${_selectedTimeFilter != 'Semua' ? ', $_selectedTimeFilter' : ''}${_showOnlyNew ? ', Data Terbaru' : ''}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0083EE),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = 'Semua';
                                    _selectedTimeFilter = 'Semua';
                                    _showOnlyNew = false;
                                  });
                                },
                                child: Icon(
                                  Icons.close,
                                  color: Color(0xFF0083EE),
                                  size: 16,
                                ),
                              ),
                            ],
                          ),
                        ),

                      Expanded(
                        child:
                            filteredHistory.isEmpty
                                ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF61B8FF),
                                              Color(0xFF0083EE),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            40,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFF0083EE,
                                              ).withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.search_off,
                                          color: Colors.white,
                                          size: 40,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        'Tidak ada data yang sesuai dengan filter',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF6B7280),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Coba ubah pengaturan filter',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF9CA3AF),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                : SingleChildScrollView(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (newItems.isNotEmpty) ...[
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF0EA5E9),
                                                Color(0xFF0284C7),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF0EA5E9,
                                                ).withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.fiber_new_rounded,
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
                                                      'Data Terbaru',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                    Text(
                                                      '${newItems.length} item baru tersedia',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${newItems.length}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...newItems
                                            .map(
                                              (item) => _buildKaprogHistoryCard(item),
                                            )
                                            .toList(),
                                      ],

                                      if (oldItems.isNotEmpty) ...[
                                        if (newItems.isNotEmpty)
                                          const SizedBox(height: 24),
                                        Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF64748B),
                                                Color(0xFF475569),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(
                                                  0xFF64748B,
                                                ).withOpacity(0.3),
                                                blurRadius: 15,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.history_rounded,
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
                                                      'Data Sebelumnya',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            color: Colors.white,
                                                          ),
                                                    ),
                                                    Text(
                                                      'Riwayat data yang sudah tersimpan',
                                                      style:
                                                          GoogleFonts.poppins(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                  0.8,
                                                                ),
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  '${oldItems.length}',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w700,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        ...oldItems
                                            .map(
                                              (item) => _buildKaprogHistoryCard(item),
                                            )
                                            .toList(),
                                      ],
                                    ],
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Kaprog History Card - TANPA TOMBOL EDIT/DELETE
  Widget _buildKaprogHistoryCard(HistoryItem item) {
    bool isPelanggaran = item.isPelanggaran;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(item.icon, color: item.color, size: 28),
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
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: item.color.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${item.points > 0 ? '+' : ''}${item.points}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: item.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: const Color(0xFF9CA3AF),
                ),
                const SizedBox(width: 6),
                Text(
                  '${item.date} • ${item.time}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.person, size: 16, color: const Color(0xFF9CA3AF)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    isPelanggaran
                        ? 'Pelapor: ${item.pelapor ?? 'Tidak diketahui'}'
                        : 'Oleh: ${item.pemberi ?? 'Tidak diketahui'}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF9CA3AF),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // TIDAK ADA TOMBOL EDIT/DELETE UNTUK KAPROG
            // Hanya menampilkan informasi view-only
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7280).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6B7280).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility,
                    size: 16,
                    color: const Color(0xFF6B7280),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mode Tampil (Read-Only)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
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
}