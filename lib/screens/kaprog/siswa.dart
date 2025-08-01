import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/navigation/kaprog.dart';
import 'package:skoring/screens/kaprog/home.dart';
import 'package:skoring/screens/profile.dart';

class ProgramKeahlianScreen extends StatefulWidget {
  const ProgramKeahlianScreen({Key? key}) : super(key: key);

  @override
  State<ProgramKeahlianScreen> createState() => _ProgramKeahlianScreenState();
}

class _ProgramKeahlianScreenState extends State<ProgramKeahlianScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _programList = [
    {
      'name': 'RPL',
      'fullName': 'Rekayasa Perangkat Lunak',
      'color': const Color(0xFF4CAF50),
      'icon': Icons.computer,
      'category': 'IT',
    },
    {
      'name': 'DKV',
      'fullName': 'Desain Komunikasi Visual',
      'color': const Color(0xFF9C27B0),
      'icon': Icons.design_services,
      'category': 'IT',
    },
    {
      'name': 'TKJ',
      'fullName': 'Teknik Komputer dan Jaringan',
      'color': const Color(0xFF757575),
      'icon': Icons.settings_ethernet,
      'category': 'IT',
    },
    {
      'name': 'MP',
      'fullName': 'Manajemen Perkantoran',
      'color': const Color(0xFF2196F3),
      'icon': Icons.business_center,
      'category': 'Bisnis',
    },
    {
      'name': 'AKL',
      'fullName': 'Akuntansi dan Keuangan Lembaga',
      'color': const Color(0xFFFFEB3B),
      'icon': Icons.account_balance,
      'category': 'Bisnis',
    },
    {
      'name': 'MLOG',
      'fullName': 'Manajemen Logistik',
      'color': const Color(0xFFFF9800),
      'icon': Icons.local_shipping,
      'category': 'Bisnis',
    },
    {
      'name': 'PM',
      'fullName': 'Pemasaran',
      'color': const Color(0xFFF44336),
      'icon': Icons.campaign,
      'category': 'Bisnis',
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  List<Map<String, dynamic>> get _filteredPrograms {
    return _programList.where((program) {
      final matchesSearch =
          program['name'].toLowerCase().contains(_searchQuery) ||
          program['fullName'].toLowerCase().contains(_searchQuery);
      final matchesFilter =
          _selectedFilter == 'Semua' || program['category'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _showClassOptions(Map<String, dynamic> program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Pilih Kelas ${program['name']}',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildClassOption(program, 'X', '1'),
            _buildClassOption(program, 'X', '2'),
            _buildClassOption(program, 'XI', '1'),
            _buildClassOption(program, 'XI', '2'),
            _buildClassOption(program, 'XII', '1'),
            _buildClassOption(program, 'XII', '2'),
          ],
        ),
      ),
    );
  }

  Widget _buildClassOption(
    Map<String, dynamic> program,
    String angkatan,
    String kelas,
  ) {
    return ListTile(
      title: Text(
        '$angkatan ${program['name']} $kelas',
        style: GoogleFonts.poppins(
          fontSize: 16,
          color: const Color(0xFF1F2937),
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClassScreen(
              programName: program['name'],
              angkatan: angkatan,
              kelas: kelas,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: _currentIndex == 0
          ? const HomeKaprogScreen()
          : SafeArea(
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
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back_ios_new_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ProfileScreen(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
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
                            const SizedBox(height: 28),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, Pak Budi! 👋',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w700,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Kelola program keahlian dengan optimal',
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
                                        colors: [
                                          Color(0xFF61B8FF),
                                          Color(0xFF0083EE),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
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
                                      decoration: InputDecoration(
                                        hintText: 'Cari program keahlian...',
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
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildFilterButton('Semua', 0),
                                const SizedBox(width: 10),
                                _buildFilterButton('IT', 1),
                                const SizedBox(width: 10),
                                _buildFilterButton('Bisnis', 2),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: _filteredPrograms.isEmpty
                            ? [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 40),
                                  child: Text(
                                    'Tidak ada program ditemukan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ]
                            : _filteredPrograms.map((program) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: GestureDetector(
                                    onTap: () => _showClassOptions(program),
                                    child: _buildProgramCard(program),
                                  ),
                                );
                              }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: KaprogNavigation(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }

  Widget _buildFilterButton(String text, int index) {
    bool isActive = _selectedFilter == text;
    Gradient dotGradient;
    if (index == 0) {
      dotGradient = const LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      );
    } else if (index == 1) {
      dotGradient = const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
      );
    } else {
      dotGradient = const LinearGradient(
        colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
      );
    }
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = text;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
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
              if (isActive)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: dotGradient,
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

  Widget _buildProgramCard(Map<String, dynamic> program) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: program['color'].withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: program['color'],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  program['name'],
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  program['fullName'],
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: program['color'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.arrow_forward_ios_rounded,
              color: program['color'],
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class ClassScreen extends StatelessWidget {
  final String programName;
  final String angkatan;
  final String kelas;

  const ClassScreen({
    Key? key,
    required this.programName,
    required this.angkatan,
    required this.kelas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$angkatan $programName $kelas',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0083EE),
      ),
      body: Center(
        child: Text(
          'Kelas: $angkatan $programName $kelas',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF1F2937),
          ),
        ),
      ),
    );
  }
}