import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'Semua';

  final List<Map<String, dynamic>> _notificationsData = [
    {
      'id': '1',
      'title': 'Bos Warning 3/3',
      'subtitle': 'Pelanggaran berulang dideteksi',
      'message':
          'Ahmad Lutfi Khairul telah melakukan pelanggaran berulang sebanyak 3 kali. Segera lakukan tindakan.',
      'time': '2 menit yang lalu',
      'type': 'warning',
      'isRead': false,
      'student': 'Ahmad Lutfi Khairul',
      'action': 'Pelanggaran Berulang',
    },
    {
      'id': '2',
      'title': 'Bos Ext 5/5',
      'subtitle': 'Prestasi luar biasa dicapai',
      'message':
          'Eka Putri telah mencapai 5 prestasi ekstrakurikuler. Berikan apresiasi khusus!',
      'time': '15 menit yang lalu',
      'type': 'achievement',
      'isRead': false,
      'student': 'Eka Putri',
      'action': 'Prestasi Ekstrakurikuler',
    },
    {
      'id': '3',
      'title': 'Laporan Mingguan',
      'subtitle': 'Ringkasan penilaian siswa',
      'message':
          'Laporan penilaian siswa minggu ini telah tersedia. Total 8 siswa dengan peningkatan positif.',
      'time': '1 jam yang lalu',
      'type': 'report',
      'isRead': true,
      'student': 'Sistem',
      'action': 'Laporan Mingguan',
    },
    {
      'id': '4',
      'title': 'Apresiasi Baru',
      'subtitle': 'Siswa mendapat apresiasi',
      'message':
          'Budi Santoso mendapat apresiasi atas partisipasi aktif dalam kegiatan kelas.',
      'time': '2 jam yang lalu',
      'type': 'appreciation',
      'isRead': true,
      'student': 'Budi Santoso',
      'action': 'Apresiasi Kelas',
    },
    {
      'id': '5',
      'title': 'Peringatan Sistem',
      'subtitle': 'Update aplikasi tersedia',
      'message':
          'Versi baru aplikasi telah tersedia dengan fitur-fitur menarik. Silakan update untuk pengalaman terbaik.',
      'time': '1 hari yang lalu',
      'type': 'system',
      'isRead': true,
      'student': 'Sistem',
      'action': 'Update Aplikasi',
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
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    return _selectedFilter == 'Semua'
        ? _notificationsData
        : _notificationsData
            .where(
              (notif) =>
                  _selectedFilter == 'Belum Dibaca'
                      ? !notif['isRead']
                      : notif['isRead'],
            )
            .toList();
  }

  int get _unreadCount =>
      _notificationsData.where((notif) => !notif['isRead']).length;

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notificationsData.indexWhere(
        (notif) => notif['id'] == notificationId,
      );
      if (index != -1) _notificationsData[index]['isRead'] = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notif in _notificationsData) {
        notif['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Semua notifikasi telah ditandai sebagai dibaca',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxWidth =
                  constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
              final padding = maxWidth * 0.05;
              final fontSize = maxWidth * 0.04;
              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
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
                              padding,
                              MediaQuery.of(context).padding.top +
                                  padding * 0.5,
                              padding,
                              padding * 1.5,
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
                                          color: Colors.white.withOpacity(0.2),
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
                                    if (_unreadCount > 0)
                                      GestureDetector(
                                        onTap: _markAllAsRead,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: padding * 0.8,
                                            vertical: padding * 0.4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.done_all_rounded,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                              SizedBox(width: padding * 0.3),
                                              Text(
                                                'Tandai Semua',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontSize: fontSize * 0.8,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: padding * 1.2),
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(padding * 0.6),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Icon(
                                        Icons.notifications_active_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                    SizedBox(width: padding * 0.8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Notifikasi',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white,
                                              fontSize: fontSize * 1.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Text(
                                            _unreadCount > 0
                                                ? '$_unreadCount belum dibaca'
                                                : 'Semua sudah dibaca',
                                            style: GoogleFonts.poppins(
                                              color: Colors.white.withOpacity(
                                                0.9,
                                              ),
                                              fontSize: fontSize * 0.9,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(padding),
                            child: ContentWidget(
                              filteredNotifications: _filteredNotifications,
                              selectedFilter: _selectedFilter,
                              onFilterChanged:
                                  (filter) =>
                                      setState(() => _selectedFilter = filter),
                              onNotificationTap: (notif) {
                                if (!notif['isRead']) _markAsRead(notif['id']);
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder:
                                      (context) => NotificationDetailWidget(
                                        notification: notif,
                                        padding: padding,
                                        fontSize: fontSize,
                                      ),
                                );
                              },
                              padding: padding,
                              fontSize: fontSize,
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
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  final List<Map<String, dynamic>> filteredNotifications;
  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;
  final Function(Map<String, dynamic>) onNotificationTap;
  final double padding;
  final double fontSize;

  const ContentWidget({
    super.key,
    required this.filteredNotifications,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onNotificationTap,
    required this.padding,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${filteredNotifications.length} Notifikasi',
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            GestureDetector(
              onTap:
                  () => showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder:
                        (context) => FilterBottomSheet(
                          selectedFilter: selectedFilter,
                          onFilterSelected: onFilterChanged,
                          fontSize: fontSize,
                        ),
                  ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: padding * 0.8,
                  vertical: padding * 0.4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.filter_list_rounded,
                      size: fontSize,
                      color: const Color(0xFF6B7280),
                    ),
                    SizedBox(width: padding * 0.4),
                    Text(
                      selectedFilter,
                      style: GoogleFonts.poppins(
                        fontSize: fontSize * 0.8,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF374151),
                      ),
                    ),
                    SizedBox(width: padding * 0.2),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: fontSize,
                      color: const Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: padding),
        Expanded(
          child:
              filteredNotifications.isEmpty
                  ? EmptyStateWidget(fontSize: fontSize)
                  : ListView.builder(
                    itemCount: filteredNotifications.length,
                    itemBuilder:
                        (context, index) => NotificationCardWidget(
                          notification: filteredNotifications[index],
                          onTap:
                              () => onNotificationTap(
                                filteredNotifications[index],
                              ),
                          padding: padding,
                          fontSize: fontSize,
                        ),
                  ),
        ),
      ],
    );
  }
}

class FilterBottomSheet extends StatelessWidget {
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;
  final double fontSize;

  const FilterBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(fontSize),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filter Notifikasi',
            style: GoogleFonts.poppins(
              fontSize: fontSize * 1.1,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: fontSize),
          ...['Semua', 'Belum Dibaca', 'Sudah Dibaca'].map(
            (filter) => ListTile(
              title: Text(
                filter,
                style: GoogleFonts.poppins(
                  fontSize: fontSize * 0.9,
                  fontWeight: FontWeight.w500,
                  color:
                      selectedFilter == filter
                          ? const Color(0xFF0083EE)
                          : const Color(0xFF1F2937),
                ),
              ),
              leading: Radio<String>(
                value: filter,
                groupValue: selectedFilter,
                onChanged: (value) {
                  onFilterSelected(value!);
                  Navigator.pop(context);
                },
                activeColor: const Color(0xFF0083EE),
              ),
              onTap: () {
                onFilterSelected(filter);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final double fontSize;

  const EmptyStateWidget({super.key, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: fontSize * 7.5,
            height: fontSize * 7.5,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(fontSize * 3.75),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: fontSize * 3.75,
              color: Colors.grey[400],
            ),
          ),
          SizedBox(height: fontSize * 1.5),
          Text(
            'Tidak ada notifikasi',
            style: GoogleFonts.poppins(
              fontSize: fontSize * 1.1,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: fontSize * 0.5),
          Text(
            'Semua notifikasi akan muncul di sini',
            style: GoogleFonts.poppins(
              fontSize: fontSize * 0.9,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onTap;
  final double padding;
  final double fontSize;

  const NotificationCardWidget({
    super.key,
    required this.notification,
    required this.onTap,
    required this.padding,
    required this.fontSize,
  });

  Color _getTypeColor(String type) {
    return switch (type) {
      'warning' => const Color(0xFFFF6B6D),
      'achievement' => const Color(0xFF10B981),
      'appreciation' => const Color(0xFF3B82F6),
      'report' => const Color(0xFF8B5CF6),
      _ => const Color(0xFF6B7280),
    };
  }

  IconData _getTypeIcon(String type) {
    return switch (type) {
      'warning' => Icons.warning_rounded,
      'achievement' => Icons.emoji_events_rounded,
      'appreciation' => Icons.thumb_up_rounded,
      'report' => Icons.assessment_rounded,
      _ => Icons.settings_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification['isRead'];
    final type = notification['type'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: padding * 0.6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isRead
                    ? const Color(0xFFE5E7EB)
                    : _getTypeColor(type).withOpacity(0.3),
            width: isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(padding * 0.8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: fontSize * 3,
                height: fontSize * 3,
                decoration: BoxDecoration(
                  color: _getTypeColor(type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _getTypeIcon(type),
                  color: _getTypeColor(type),
                  size: fontSize * 1.5,
                ),
              ),
              SizedBox(width: padding * 0.8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: GoogleFonts.poppins(
                              fontSize: fontSize,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: fontSize * 0.5,
                            height: fontSize * 0.5,
                            decoration: BoxDecoration(
                              color: _getTypeColor(type),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: padding * 0.2),
                    Text(
                      notification['subtitle'],
                      style: GoogleFonts.poppins(
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: padding * 0.4),
                    Text(
                      notification['message'],
                      style: GoogleFonts.poppins(
                        fontSize: fontSize * 0.8,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: padding * 0.4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: fontSize * 0.75,
                          color: const Color(0xFF9CA3AF),
                        ),
                        SizedBox(width: padding * 0.2),
                        Text(
                          notification['time'],
                          style: GoogleFonts.poppins(
                            fontSize: fontSize * 0.7,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationDetailWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final double padding;
  final double fontSize;

  const NotificationDetailWidget({
    super.key,
    required this.notification,
    required this.padding,
    required this.fontSize,
  });

  Color _getTypeColor(String type) {
    return switch (type) {
      'warning' => const Color(0xFFFF6B6D),
      'achievement' => const Color(0xFF10B981),
      'appreciation' => const Color(0xFF3B82F6),
      'report' => const Color(0xFF8B5CF6),
      _ => const Color(0xFF6B7280),
    };
  }

  IconData _getTypeIcon(String type) {
    return switch (type) {
      'warning' => Icons.warning_rounded,
      'achievement' => Icons.emoji_events_rounded,
      'appreciation' => Icons.thumb_up_rounded,
      'report' => Icons.assessment_rounded,
      _ => Icons.settings_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding * 1.2),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: fontSize * 3.75,
                height: fontSize * 3.75,
                decoration: BoxDecoration(
                  color: _getTypeColor(notification['type']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getTypeIcon(notification['type']),
                  color: _getTypeColor(notification['type']),
                  size: fontSize * 1.9,
                ),
              ),
              SizedBox(width: padding * 0.8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification['title'],
                      style: GoogleFonts.poppins(
                        fontSize: fontSize * 1.3,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      notification['time'],
                      style: GoogleFonts.poppins(
                        fontSize: fontSize * 0.9,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close_rounded, size: fontSize * 1.5),
              ),
            ],
          ),
          SizedBox(height: padding * 1.2),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      color: _getTypeColor(
                        notification['type'],
                      ).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getTypeColor(
                          notification['type'],
                        ).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Detail Notifikasi',
                          style: GoogleFonts.poppins(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        SizedBox(height: padding * 0.6),
                        Text(
                          notification['message'],
                          style: GoogleFonts.poppins(
                            fontSize: fontSize * 0.9,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF374151),
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: padding),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(padding * 0.8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Siswa',
                                style: GoogleFonts.poppins(
                                  fontSize: fontSize * 0.75,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: padding * 0.2),
                              Text(
                                notification['student'],
                                style: GoogleFonts.poppins(
                                  fontSize: fontSize * 0.9,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: padding * 0.6),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(padding * 0.8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Aksi',
                                style: GoogleFonts.poppins(
                                  fontSize: fontSize * 0.75,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF6B7280),
                                ),
                              ),
                              SizedBox(height: padding * 0.2),
                              Text(
                                notification['action'],
                                style: GoogleFonts.poppins(
                                  fontSize: fontSize * 0.9,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (notification['type'] == 'warning' ||
              notification['type'] == 'achievement') ...[
            SizedBox(height: padding),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menuju halaman detail ${notification['student']}',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.9,
                            ),
                          ),
                          backgroundColor: const Color(0xFF0083EE),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Lihat Siswa',
                      style: GoogleFonts.poppins(
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0083EE),
                      padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: padding * 0.6),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menuju halaman aksi untuk ${notification['student']}',
                            style: GoogleFonts.poppins(
                              fontSize: fontSize * 0.9,
                            ),
                          ),
                          backgroundColor: _getTypeColor(notification['type']),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                    icon: Icon(
                      _getTypeIcon(notification['type']),
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      'Ambil Aksi',
                      style: GoogleFonts.poppins(
                        fontSize: fontSize * 0.9,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getTypeColor(notification['type']),
                      padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
