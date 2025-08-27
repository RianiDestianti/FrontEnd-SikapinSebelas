import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/navigation/kaprog.dart';
import 'package:skoring/screens/kaprog/home.dart';
import 'package:skoring/screens/profile.dart';
import 'package:skoring/screens/kaprog/detail.dart';
import 'package:skoring/screens/kaprog/report.dart';

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
      builder:
          (context) => AlertDialog(
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
            builder:
                (context) => SiswaScreen(
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
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child:
            _currentIndex == 0
                ? const KaprogHomeScreen()
                : _currentIndex == 1
                ? SingleChildScrollView(
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
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
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
                                      'Daftar Jurusan SMKN 11 Bandung',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 20,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                          children:
                              _filteredPrograms.isEmpty
                                  ? [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 40,
                                      ),
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
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
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
                )
                : const LaporanKaprog(),
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

class SiswaScreen extends StatefulWidget {
  final String? programName;
  final String? angkatan;
  final String? kelas;

  const SiswaScreen({Key? key, this.programName, this.angkatan, this.kelas})
    : super(key: key);

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

  final List<Map<String, dynamic>> students = [
    {
      "name": "Ahmad Sudarji",
      "nisn": "23000001",
      "status": "Aman",
      "points": 20,
      "absent": 1,
    },
    {
      "name": "Agus Berto",
      "nisn": "23000002",
      "status": "Aman",
      "points": 0,
      "absent": 2,
    },
    {
      "name": "Bobby Dasta",
      "nisn": "23000003",
      "status": "Bermasalah",
      "points": -15,
      "absent": 3,
    },
    {
      "name": "Berto",
      "nisn": "23000004",
      "status": "Prioritas",
      "points": -25,
      "absent": 4,
    },
    {
      "name": "Celine Agustinus",
      "nisn": "23000006",
      "status": "Aman",
      "points": 10,
      "absent": 5,
    },
    {
      "name": "Diana Sari",
      "nisn": "23000007",
      "status": "Aman",
      "points": 15,
      "absent": 6,
    },
    {
      "name": "Eko Prasetyo",
      "nisn": "23000008",
      "status": "Bermasalah",
      "points": -10,
      "absent": 7,
    },
    {
      "name": "Fitri Handayani",
      "nisn": "23000009",
      "status": "Aman",
      "points": 25,
      "absent": 8,
    },
    {
      "name": "Gilang Ramadan",
      "nisn": "23000010",
      "status": "Prioritas",
      "points": -30,
      "absent": 9,
    },
    {
      "name": "Haniatul Kamilah",
      "nisn": "23000011",
      "status": "Aman",
      "points": 18,
      "absent": 10,
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

  List<Map<String, dynamic>> getFilteredStudents() {
    List<Map<String, dynamic>> filtered = List.from(students);

    if (_selectedFilter == 1) {
      filtered = filtered.where((s) => s['status'] == 'Aman').toList();
    } else if (_selectedFilter == 2) {
      filtered =
          filtered
              .where(
                (s) =>
                    s['status'] == 'Bermasalah' || s['status'] == 'Prioritas',
              )
              .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered =
          filtered
              .where(
                (s) =>
                    s['name'].toString().toLowerCase().contains(
                      _searchQuery.toLowerCase(),
                    ) ||
                    s['nisn'].toString().contains(_searchQuery),
              )
              .toList();
    }

    return filtered;
  }

  void _onStudentTap(Map<String, dynamic> student) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KaprogDetailScreen(student: student),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredStudents = getFilteredStudents();
    String classTitle =
        widget.programName != null &&
                widget.angkatan != null &&
                widget.kelas != null
            ? 'Daftar Siswa ${widget.angkatan} ${widget.programName} ${widget.kelas}'
            : 'Daftar Siswa XI RPL 2';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
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
                            Row(
                              children: [
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => const ProfileScreen(),
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
                          ],
                        ),
                        const SizedBox(height: 24),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                classTitle,
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
                                      _searchQuery = '';
                                      _searchController.clear();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
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
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      if (_searchQuery.isNotEmpty || _selectedFilter != 0)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
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
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: const Color(0xFF0083EE),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Ditemukan ${filteredStudents.length} siswa',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),

                      filteredStudents.isEmpty
                          ? _buildEmptyState()
                          : Column(
                            children:
                                filteredStudents.asMap().entries.map((entry) {
                                  return _buildStudentCard(
                                    entry.value,
                                    entry.key,
                                  );
                                }).toList(),
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

  Widget _buildStudentCard(Map<String, dynamic> student, int index) {
    return GestureDetector(
      onTap: () => _onStudentTap(student),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _getStatusColor(student['status']).withOpacity(0.2),
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
                  student['name'][0].toUpperCase(),
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
                    student['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Absen: ${student['absent']}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B7280),
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
                    color: _getStatusColor(student['status']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      student['status'],
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(student['status']),
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
