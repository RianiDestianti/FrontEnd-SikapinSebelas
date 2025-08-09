import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/profile.dart';
import 'package:skoring/models/student.dart';

class HomeKaprogScreen extends StatefulWidget {
  const HomeKaprogScreen({Key? key}) : super(key: key);

  @override
  State<HomeKaprogScreen> createState() => _HomeKaprogScreenState();
}

class _HomeKaprogScreenState extends State<HomeKaprogScreen> with TickerProviderStateMixin {
  int _selectedTab = 0;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final TextEditingController _searchController;
  String _searchQuery = '';

  final List<BestStudent> _siswaTerbaik = [
    BestStudent(
      nama: 'Ahmad Zaky',
      kelas: 'XII RPL 1',
      poin: 400,
      prestasi: 'Juara 1 Hackathon Nasional',
      avatar: Icons.person,
      rank: 1,
    ),
    BestStudent(
      nama: 'Siti Aisyah',
      kelas: 'XII RPL 2',
      poin: 345,
      prestasi: 'Juara 2 Desain Poster',
      avatar: Icons.person,
      rank: 2,
    ),
    BestStudent(
      nama: 'Budi Santoso',
      kelas: 'XII RPL 1',
      poin: 300,
      prestasi: 'Ketua Tim Jaringan Berprestasi',
      avatar: Icons.person,
      rank: 3,
    ),
    BestStudent(
      nama: 'Rina Amelia',
      kelas: 'XII RPL 1',
      poin: 290,
      prestasi: 'Juara 1 Lomba Administrasi',
      avatar: Icons.person,
      rank: 4,
    ),
  ];

  final List<ViolationStudent> _siswaBerpelanggaran = [
    ViolationStudent(
      nama: 'Dedi Kurniawan',
      kelas: 'XII RPL 2',
      pelanggaran: 'Terlambat 3 kali',
      poin: 50,
      avatar: Icons.person,
      severity: 'Ringan',
    ),
    ViolationStudent(
      nama: 'Lina Sari',
      kelas: 'XII RPL 1',
      pelanggaran: 'Tidak memakai seragam lengkap',
      poin: 30,
      avatar: Icons.person,
      severity: 'Ringan',
    ),
    ViolationStudent(
      nama: 'Rudi Hartono',
      kelas: 'XII RPL 2',
      pelanggaran: 'Merokok di lingkungan sekolah',
      poin: 75,
      avatar: Icons.person,
      severity: 'Berat',
    ),
    ViolationStudent(
      nama: 'Mila Putri',
      kelas: 'XII RPL 1',
      pelanggaran: 'Melanggar tata tertib kelas',
      poin: 25,
      avatar: Icons.person,
      severity: 'Ringan',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeSearch();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  void _initializeSearch() {
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<BestStudent> _getFilteredSiswaTerbaik() {
    if (_searchQuery.isEmpty) return _siswaTerbaik;
    return _siswaTerbaik
        .where((siswa) =>
            siswa.nama.toLowerCase().contains(_searchQuery) ||
            siswa.kelas.toLowerCase().contains(_searchQuery))
        .toList();
  }

  List<ViolationStudent> _getFilteredSiswaBerpelanggaran() {
    if (_searchQuery.isEmpty) return _siswaBerpelanggaran;
    return _siswaBerpelanggaran
        .where((siswa) =>
            siswa.nama.toLowerCase().contains(_searchQuery) ||
            siswa.kelas.toLowerCase().contains(_searchQuery))
        .toList();
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
                HeaderSection(
                  onBack: () => Navigator.pop(context),
                  onProfile: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  ),
                  searchController: _searchController,
                  selectedTab: _selectedTab,
                  onTabSelected: (index) => setState(() => _selectedTab = index),
                ),
                ContentSection(
                  selectedTab: _selectedTab,
                  siswaTerbaik: _getFilteredSiswaTerbaik(),
                  siswaBerpelanggaran: _getFilteredSiswaBerpelanggaran(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onProfile;
  final TextEditingController searchController;
  final int selectedTab;
  final Function(int) onTabSelected;

  const HeaderSection({
    Key? key,
    required this.onBack,
    required this.onProfile,
    required this.searchController,
    required this.selectedTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
                BackButtonWidget(onTap: onBack),
                ProfileButtonWidget(onTap: onProfile),
              ],
            ),
            const SizedBox(height: 28),
            const GreetingWidget(),
            const SizedBox(height: 24),
            SearchBarWidget(controller: searchController),
            const SizedBox(height: 20),
            TabSelector(
              selectedTab: selectedTab,
              onTabSelected: onTabSelected,
            ),
          ],
        ),
      ),
    );
  }
}

class BackButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const BackButtonWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class ProfileButtonWidget extends StatelessWidget {
  final VoidCallback onTap;

  const ProfileButtonWidget({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
    );
  }
}

class GreetingWidget extends StatelessWidget {
  const GreetingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
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
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;

  const SearchBarWidget({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.search, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Cari siswa, kelas, atau aktivitas...',
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
    );
  }
}

class TabSelector extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabSelected;

  const TabSelector({
    Key? key,
    required this.selectedTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TabButton(
          text: 'Siswa Terbaik',
          index: 0,
          isActive: selectedTab == 0,
          onTap: onTabSelected,
          activeGradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFFA500)]),
        ),
        const SizedBox(width: 10),
        TabButton(
          text: 'Siswa Berpelanggaran',
          index: 1,
          isActive: selectedTab == 1,
          onTap: onTabSelected,
          activeGradient: const LinearGradient(colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)]),
        ),
      ],
    );
  }
}

class TabButton extends StatelessWidget {
  final String text;
  final int index;
  final bool isActive;
  final Function(int) onTap;
  final LinearGradient activeGradient;

  const TabButton({
    Key? key,
    required this.text,
    required this.index,
    required this.isActive,
    required this.onTap,
    required this.activeGradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
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
                    gradient: activeGradient,
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
}

class ContentSection extends StatelessWidget {
  final int selectedTab;
  final List<BestStudent> siswaTerbaik;
  final List<ViolationStudent> siswaBerpelanggaran;

  const ContentSection({
    Key? key,
    required this.selectedTab,
    required this.siswaTerbaik,
    required this.siswaBerpelanggaran,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: selectedTab == 0
          ? BestStudentSection(students: siswaTerbaik)
          : ViolationStudentSection(students: siswaBerpelanggaran),
    );
  }
}

class BestStudentSection extends StatelessWidget {
  final List<BestStudent> students;

  const BestStudentSection({Key? key, required this.students}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const BestStudentHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: students.isEmpty
                ? EmptyStateWidget(message: 'Tidak ada siswa ditemukan')
                : Column(
                    children: students.asMap().entries.map((entry) {
                      final index = entry.key;
                      final student = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < students.length - 1 ? 16 : 0),
                        child: BestStudentCard(student: student),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class BestStudentHeader extends StatelessWidget {
  const BestStudentHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siswa Terbaik',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Top ${context.findAncestorWidgetOfExactType<BestStudentSection>()!.students.length} siswa dengan poin tertinggi',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BestStudentCard extends StatelessWidget {
  final BestStudent student;

  const BestStudentCard({Key? key, required this.student}) : super(key: key);

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1: return const Color(0xFFFFD700);
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return const Color(0xFF0083EE);
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1: return Icons.looks_one;
      case 2: return Icons.looks_two;
      case 3: return Icons.looks_3;
      default: return Icons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = _getRankColor(student.rank);
    final rankIcon = _getRankIcon(student.rank);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rankColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          StudentAvatar(
            rank: student.rank,
            avatar: student.avatar,
            rankColor: rankColor,
            rankIcon: rankIcon,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: StudentDetails(
              rank: student.rank,
              nama: student.nama,
              kelas: student.kelas,
              poin: student.poin,
              prestasi: student.prestasi,
              rankColor: rankColor,
            ),
          ),
          const SizedBox(width: 12),
          TrendIcon(icon: Icons.trending_up, color: rankColor),
        ],
      ),
    );
  }
}

class ViolationStudentSection extends StatelessWidget {
  final List<ViolationStudent> students;

  const ViolationStudentSection({Key? key, required this.students}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const ViolationStudentHeader(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: students.isEmpty
                ? EmptyStateWidget(message: 'Tidak ada siswa ditemukan')
                : Column(
                    children: students.asMap().entries.map((entry) {
                      final index = entry.key;
                      final student = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: index < students.length - 1 ? 16 : 0),
                        child: ViolationStudentCard(student: student),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class ViolationStudentHeader extends StatelessWidget {
  const ViolationStudentHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Siswa Berpelanggaran',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Daftar ${context.findAncestorWidgetOfExactType<ViolationStudentSection>()!.students.length} siswa dengan pelanggaran',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ViolationStudentCard extends StatelessWidget {
  final ViolationStudent student;

  const ViolationStudentCard({Key? key, required this.student}) : super(key: key);

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'Berat': return const Color(0xFFFF6B6D);
      case 'Ringan': return const Color(0xFFEA580C);
      default: return const Color(0xFFEA580C);
    }
  }

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(student.severity);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: severityColor.withOpacity(0.2), width: 2),
        boxShadow: [
          BoxShadow(
            color: severityColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          StudentAvatar(
            rank: null,
            avatar: student.avatar,
            rankColor: severityColor,
            rankIcon: Icons.warning_amber_rounded,
            gradient: const LinearGradient(colors: [Color(0xFFFF6B6D), Color(0xFFFF8E8F)]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ViolationStudentDetails(
              severity: student.severity,
              nama: student.nama,
              kelas: student.kelas,
              poin: student.poin,
              pelanggaran: student.pelanggaran,
              severityColor: severityColor,
            ),
          ),
          const SizedBox(width: 12),
          TrendIcon(icon: Icons.warning, color: severityColor),
        ],
      ),
    );
  }
}

class StudentAvatar extends StatelessWidget {
  final int? rank;
  final IconData avatar;
  final Color rankColor;
  final IconData rankIcon;
  final LinearGradient? gradient;

  const StudentAvatar({
    Key? key,
    this.rank,
    required this.avatar,
    required this.rankColor,
    required this.rankIcon,
    this.gradient,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: gradient ??
            LinearGradient(
              colors: rank != null && rank! <= 3
                  ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                  : [const Color(0xFF61B8FF), const Color(0xFF0083EE)],
            ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(avatar, color: Colors.white, size: 24),
          if (rank != null && rank! <= 3)
            Positioned(
              top: -2,
              right: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(rankIcon, color: Colors.white, size: 10),
              ),
            ),
        ],
      ),
    );
  }
}

class StudentDetails extends StatelessWidget {
  final int rank;
  final String nama;
  final String kelas;
  final int poin;
  final String prestasi;
  final Color rankColor;

  const StudentDetails({
    Key? key,
    required this.rank,
    required this.nama,
    required this.kelas,
    required this.poin,
    required this.prestasi,
    required this.rankColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            RankTag(rank: rank, rankColor: rankColor),
            const SizedBox(width: 8),
            Text(
              nama,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            ClassTag(kelas: kelas),
            const SizedBox(width: 8),
            const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
            const SizedBox(width: 4),
            Text(
              '$poin poin',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          prestasi,
          style: GoogleFonts.poppins(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class ViolationStudentDetails extends StatelessWidget {
  final String severity;
  final String nama;
  final String kelas;
  final int poin;
  final String pelanggaran;
  final Color severityColor;

  const ViolationStudentDetails({
    Key? key,
    required this.severity,
    required this.nama,
    required this.kelas,
    required this.poin,
    required this.pelanggaran,
    required this.severityColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SeverityTag(severity: severity, severityColor: severityColor),
            const SizedBox(width: 8),
            Text(
              nama,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: const Color(0xFF1F2937),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            ClassTag(kelas: kelas),
            const SizedBox(width: 8),
            Icon(Icons.warning_amber_rounded, color: severityColor, size: 14),
            const SizedBox(width: 4),
            Text(
              '$poin poin',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          pelanggaran,
          style: GoogleFonts.poppins(
            color: const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class RankTag extends StatelessWidget {
  final int rank;
  final Color rankColor;

  const RankTag({Key? key, required this.rank, required this.rankColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rankColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rankColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        '#$rank',
        style: GoogleFonts.poppins(
          color: rankColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class SeverityTag extends StatelessWidget {
  final String severity;
  final Color severityColor;

  const SeverityTag({Key? key, required this.severity, required this.severityColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: severityColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: severityColor.withOpacity(0.3), width: 1),
      ),
      child: Text(
        severity,
        style: GoogleFonts.poppins(
          color: severityColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class ClassTag extends StatelessWidget {
  final String kelas;

  const ClassTag({Key? key, required this.kelas}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF0083EE).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        kelas,
        style: GoogleFonts.poppins(
          color: const Color(0xFF0083EE),
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class TrendIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const TrendIcon({Key? key, required this.icon, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;

  const EmptyStateWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: GoogleFonts.poppins(
        color: const Color(0xFF6B7280),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}