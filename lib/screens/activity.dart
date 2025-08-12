import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class Activity {
  final int id;
  final String type;
  final IconData icon;
  final List<Color> gradient;
  final String title;
  final String subtitle;
  final String time;
  final String date;
  final DateTime fullDate;
  final String status;
  final Color statusColor;
  final String priority;
  final String details;

  Activity({
    required this.id,
    required this.type,
    required this.icon,
    required this.gradient,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.date,
    required this.fullDate,
    required this.status,
    required this.statusColor,
    required this.priority,
    required this.details,
  });
}

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'Semua';
  String _searchQuery = '';
  DateTime? _selectedDate;

  final List<String> _filterOptions = [
    'Semua',
    'Laporan',
    'Sistem'
  ];

  final List<Activity> _allActivities = [
    Activity(
      id: 1,
      type: 'laporan',
      icon: Icons.assessment_outlined,
      gradient: [Color(0xFF61B8FF), Color(0xFF0083EE)],
      title: 'Laporan Bulanan',
      subtitle: 'Laporan evaluasi siswa telah selesai dibuat untuk bulan ini',
      time: '10.30',
      date: 'Hari ini',
      fullDate: DateTime.now(),
      status: 'SELESAI',
      statusColor: Color(0xFF10B981),
      priority: 'normal',
      details: 'Laporan mencakup evaluasi 120 siswa dengan berbagai aspek penilaian',
    ),
    Activity(
      id: 4,
      type: 'sistem',
      icon: Icons.sync_outlined,
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      title: 'Sinkronisasi Data',
      subtitle: 'Data siswa berhasil disinkronkan dengan database pusat',
      time: '23.45',
      date: 'Kemarin',
      fullDate: DateTime.now().subtract(Duration(days: 1)),
      status: 'BERHASIL',
      statusColor: Color(0xFF10B981),
      priority: 'low',
      details: 'Total 850 record siswa berhasil disinkronkan tanpa error',
    ),
    Activity(
      id: 5,
      type: 'laporan',
      icon: Icons.analytics_outlined,
      gradient: [Color(0xFF61B8FF), Color(0xFF0083EE)],
      title: 'Analisis Kehadiran',
      subtitle: 'Laporan analisis kehadiran siswa minggu ini telah dibuat',
      time: '15.20',
      date: 'Kemarin',
      fullDate: DateTime.now().subtract(Duration(days: 1)),
      status: 'SELESAI',
      statusColor: Color(0xFF10B981),
      priority: 'normal',
      details: 'Tingkat kehadiran rata-rata: 92.5% dengan 15 siswa tidak hadir',
    ),
    Activity(
      id: 8,
      type: 'sistem',
      icon: Icons.backup_outlined,
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      title: 'Backup Otomatis',
      subtitle: 'Backup data harian telah selesai dilakukan',
      time: '02.00',
      date: '2 hari lalu',
      fullDate: DateTime.now().subtract(Duration(days: 2)),
      status: 'OTOMATIS',
      statusColor: Color(0xFF6B7280),
      priority: 'low',
      details: 'Backup size: 2.3GB, lokasi: cloud storage',
    ),
    Activity(
      id: 9,
      type: 'laporan',
      icon: Icons.bar_chart_outlined,
      gradient: [Color(0xFF61B8FF), Color(0xFF0083EE)],
      title: 'Laporan Mingguan',
      subtitle: 'Laporan aktivitas siswa minggu ini telah selesai dibuat',
      time: '09.15',
      date: '3 hari lalu',
      fullDate: DateTime.now().subtract(Duration(days: 3)),
      status: 'SELESAI',
      statusColor: Color(0xFF10B981),
      priority: 'normal',
      details: 'Laporan mencakup aktivitas 120 siswa selama seminggu terakhir',
    ),
    Activity(
      id: 10,
      type: 'sistem',
      icon: Icons.update_outlined,
      gradient: [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
      title: 'Update Sistem',
      subtitle: 'Sistem telah diperbarui ke versi terbaru',
      time: '14.30',
      date: '4 hari lalu',
      fullDate: DateTime.now().subtract(Duration(days: 4)),
      status: 'BERHASIL',
      statusColor: Color(0xFF10B981),
      priority: 'medium',
      details: 'Update sistem v2.1.0 dengan fitur baru dan perbaikan bug',
    ),
  ];

  List<Activity> _filteredActivities = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _filteredActivities = _allActivities;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _filterActivities() {
    setState(() {
      String selectedType = _selectedFilter.toLowerCase();

      _filteredActivities = _allActivities.where((activity) {
        bool matchesFilter = _selectedFilter == 'Semua' || activity.type == selectedType;

        bool matchesSearch = _searchQuery.isEmpty ||
            activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            activity.subtitle.toLowerCase().contains(_searchQuery.toLowerCase());

        bool matchesDate = _selectedDate == null ||
            _isSameDay(activity.fullDate, _selectedDate!);

        return matchesFilter && matchesSearch && matchesDate;
      }).toList();
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  String _formatDate(DateTime date) {
    List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF0083EE),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: const Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _filterActivities();
    }
  }

  void _clearDate() {
    setState(() {
      _selectedDate = null;
    });
    _filterActivities();
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            double maxWidth = constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: maxWidth,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildAppBar(),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: _filteredActivities.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: _filteredActivities.length,
                                  itemBuilder: (context, index) {
                                    final activity = _filteredActivities[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: index < _filteredActivities.length - 1 ? 16 : 0,
                                      ),
                                      child: _buildActivityCard(activity),
                                    );
                                  },
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

  Widget _buildAppBar() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF61B8FF), Color(0xFF0083EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
        padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 30),
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
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aktivitas Terkini',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Riwayat semua aktivitas sistem',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
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
                      onChanged: (value) {
                        _searchQuery = value;
                        _filterActivities();
                      },
                      decoration: InputDecoration(
                        hintText: 'Cari aktivitas...',
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
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedFilter,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1F2937),
                        ),
                        items: _filterOptions.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Row(
                              children: [
                                Icon(
                                  value == 'Semua' ? Icons.all_inclusive :
                                  value == 'Laporan' ? Icons.assessment_outlined :
                                  Icons.settings_outlined,
                                  size: 18,
                                  color: const Color(0xFF0083EE),
                                ),
                                const SizedBox(width: 8),
                                Text(value),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedFilter = newValue;
                            });
                            _filterActivities();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    height: 45,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: _selectedDate != null ? const Color(0xFF0083EE) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 18,
                          color: _selectedDate != null ? Colors.white : const Color(0xFF6B7280),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDate != null ? _formatDate(_selectedDate!) : 'Tanggal',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _selectedDate != null ? Colors.white : const Color(0xFF6B7280),
                          ),
                        ),
                        if (_selectedDate != null) ...[
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: _clearDate,
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(40),
            ),
            child: const Icon(
              Icons.search_off,
              color: Color(0xFF9CA3AF),
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada aktivitas ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau kata kunci pencarian',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(Activity activity) {
    return GestureDetector(
      onTap: () => _showActivityDetail(activity),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: LinearGradient(
              colors: activity.gradient,
            ).colors.first.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: activity.gradient),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: LinearGradient(colors: activity.gradient)
                            .colors
                            .first
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    activity.icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              activity.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: activity.statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: activity.statusColor.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              activity.status,
                              style: GoogleFonts.poppins(
                                color: activity.statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activity.subtitle,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6B7280),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: const Color(0xFF9CA3AF),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${activity.time} • ${activity.date}',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF9CA3AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(Activity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: activity.gradient),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: LinearGradient(colors: activity.gradient)
                                  .colors
                                  .first
                                  .withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          activity.icon,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity.title,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: activity.statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: activity.statusColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                activity.status,
                                style: GoogleFonts.poppins(
                                  color: activity.statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Waktu', '${activity.time} • ${activity.date}'),
                          const SizedBox(height: 16),
                          _buildDetailRow('Deskripsi', activity.subtitle),
                          const SizedBox(height: 16),
                          _buildDetailRow('Detail', activity.details),
                          const SizedBox(height: 16),
                          _buildDetailRow('Prioritas', activity.priority.toUpperCase()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0083EE),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}