import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = '0-50';
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _studentsData = [
    {
      'name': 'Abijalu Anggra Putra',
      'totalPoin': 27,
      'apresiasi': 30,
      'pelanggaran': 3,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'AP'
    },
    {
      'name': 'Ahmad Lutfi Khairul',
      'totalPoin': -45,
      'apresiasi': 5,
      'pelanggaran': 50,
      'isPositive': false,
      'color': const Color(0xFFFF6B6D),
      'avatar': 'AL'
    },
    {
      'name': 'Arga Teja',
      'totalPoin': -8,
      'apresiasi': 12,
      'pelanggaran': 20,
      'isPositive': false,
      'color': const Color(0xFFFF6B6D),
      'avatar': 'AT'
    },
    {
      'name': 'Budi Santoso',
      'totalPoin': 75,
      'apresiasi': 80,
      'pelanggaran': 5,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'BS'
    },
    {
      'name': 'Citra Dewi',
      'totalPoin': 12,
      'apresiasi': 20,
      'pelanggaran': 8,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'CD'
    },
    {
      'name': 'Deni Ramadan',
      'totalPoin': -15,
      'apresiasi': 10,
      'pelanggaran': 25,
      'isPositive': false,
      'color': const Color(0xFFFF6B6D),
      'avatar': 'DR'
    },
    {
      'name': 'Eka Putri',
      'totalPoin': 120,
      'apresiasi': 125,
      'pelanggaran': 5,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'EP'
    },
    {
      'name': 'Fajar Ahmad',
      'totalPoin': 65,
      'apresiasi': 70,
      'pelanggaran': 5,
      'isPositive': true,
      'color': const Color(0xFF10B981),
      'avatar': 'FA'
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
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x200083EE),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(width: 16, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1))),
                                    Positioned(top: 8, child: Container(width: 16, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)))),
                                    Positioned(top: 16, child: Container(width: 16, height: 2, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(1)))),
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Profile 1 diklik')),
                                    );
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(Icons.person, color: Color(0xFF0083EE), size: 20),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Profile 2 diklik')),
                                    );
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(Icons.person, color: Colors.white, size: 20),
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
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Semester Ganjil 2025/2026',
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
                          padding: const EdgeInsets.symmetric(horizontal: 20),
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
                                    colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
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
                    children: [
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hasil Akumulasi',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
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
                                      _selectedFilter == 'Negatif' ? 'Nilai Negatif' : 
                                      _selectedFilter == '101+' ? '101 ke atas' : _selectedFilter,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF374151),
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      if (_filteredAndSortedStudents.isEmpty && _searchQuery.isNotEmpty)
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
                                'Tidak ada siswa dalam range ini',
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
                        ...List.generate(_filteredAndSortedStudents.length, (index) {
                          return _buildStudentCard(_filteredAndSortedStudents[index], index);
                        }),
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

  Widget _buildStatCard(String value, String label, IconData icon, Gradient gradient) {
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

  Widget _buildProgressCard(String title, String percentage, double progress, Gradient gradient) {
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
    return GestureDetector(
      onTap: () {
        _showStudentDetail(student);
      },
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
                  student['avatar'],
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFEA580C),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Student Info
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
                        'Apresiasi: ${student['apresiasi']} | ',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Text(
                        'Pelanggaran: ${student['pelanggaran']}',
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
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: student['isPositive'] ? 0.7 : 0.3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: student['color'],
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Points
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
          height: MediaQuery.of(context).size.height * 0.6,
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
                        student['avatar'],
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
                          student['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'XII RPL 2',
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
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
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
                    Container(width: 1, height: 40, color: Colors.white.withOpacity(0.3)),
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
                'Aksi Cepat',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tambah apresiasi untuk ${student['name']}')),
                        );
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: Text(
                        'Tambah Apresiasi',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Tambah pelanggaran untuk ${student['name']}')),
                        );
                      },
                      icon: const Icon(Icons.warning, color: Colors.white),
                      label: Text(
                        'Tambah Pelanggaran',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B6D),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lihat detail lengkap ${student['name']}')),
                    );
                  },
                  icon: const Icon(Icons.visibility, color: Color(0xFF0083EE)),
                  label: Text(
                    'Lihat Detail Lengkap',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0083EE),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFF0083EE)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}