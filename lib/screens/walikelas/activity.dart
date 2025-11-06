// screens/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import 'package:skoring/models/api/api_activity.dart';
import 'package:skoring/widgets/activity/activity_app_bar.dart';
import 'package:skoring/widgets/activity/activity_card.dart';
import 'package:skoring/widgets/activity/empty_state_widget.dart';
import 'package:skoring/widgets/activity/activity_detail_bottom_sheet.dart';


class ActivityScreen extends StatefulWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  final _searchController = TextEditingController();

  String _filter = 'Semua';
  DateTime? _selectedDate;
  List<ApiActivity> _all = [];
  List<ApiActivity> _filtered = [];

  final _filters = ['Semua', 'Pencarian', 'Navigasi', 'Sistem'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 400), vsync: this);
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
    _loadActivities();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('user_activities') ?? [];

    final activities = raw.asMap().entries.map((e) {
      final parts = e.value.split('|');
      final type = parts[0];
      final fullDate = DateTime.parse(parts[3]);
      final time = DateFormat('HH:mm').format(fullDate);
      final date = _formatDate(fullDate);

      final isReward = type == 'Penghargaan';
      final isViolation = type == 'Pelanggaran';

      return ApiActivity(
        id: e.key + 1,
        type: type.toLowerCase(),
        icon: isReward ? Icons.emoji_events_outlined : isViolation ? Icons.report_problem_outlined : Icons.settings_outlined,
        gradient: isReward
            ? [const Color(0xFF10B981), const Color(0xFF34D399)]
            : isViolation
                ? [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]
                : [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
        title: parts[1],
        subtitle: parts[2],
        time: time,
        date: date,
        fullDate: fullDate,
        status: 'SELESAI',
        statusColor: isReward ? const Color(0xFF10B981) : isViolation ? const Color(0xFFFF6B6D) : const Color(0xFF10B981),
        details: '${parts[2]} pada ${DateFormat('dd MMM yyyy HH:mm').format(fullDate)}',
      );
    }).toList()
      ..sort((a, b) => b.fullDate.compareTo(a.fullDate));

    setState(() {
      _all = activities;
      _filtered = activities;
    });
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();
    final type = _filter.toLowerCase();

    setState(() {
      _filtered = _all.where((a) {
        final matchFilter = _filter == 'Semua' || a.type == type;
        final matchSearch = query.isEmpty || a.title.toLowerCase().contains(query) || a.subtitle.toLowerCase().contains(query);
        final matchDate = _selectedDate == null || (a.fullDate.year == _selectedDate!.year && a.fullDate.month == _selectedDate!.month && a.fullDate.day == _selectedDate!.day);
        return matchFilter && matchSearch && matchDate;
      }).toList();
    });
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final today = now.year == d.year && now.month == d.month && now.day == d.day;
    final yesterday = now.subtract(const Duration(days: 1)).year == d.year &&
        now.subtract(const Duration(days: 1)).month == d.month &&
        now.subtract(const Duration(days: 1)).day == d.day;

    return today ? 'Hari ini' : yesterday ? 'Kemarin' : '${d.day} ${_months[d.month - 1]} ${d.year}';
  }

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFF0083EE), onPrimary: Colors.white, surface: Colors.white, onSurface: Color(0xFF1F2937))),
        child: child!,
      ),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
      _applyFilter();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.light),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
            return Center(
              child: SizedBox(
                width: width,
                child: FadeTransition(
                  opacity: _fade,
                  child: Column(
                    children: [
                      ActivityAppBar(
                        searchController: _searchController,
                        selectedFilter: _filter,
                        filterOptions: _filters,
                        selectedDate: _selectedDate,
                        onDateTap: _pickDate,
                        onClearDate: () {
                          setState(() => _selectedDate = null);
                          _applyFilter();
                        },
                        onFilterChanged: (v) {
                          _filter = v!;
                          _applyFilter();
                        },
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: _filtered.isEmpty
                              ? const EmptyStateWidget()
                              : ListView.builder(
                                  itemCount: _filtered.length,
                                  itemBuilder: (context, i) => Padding(
                                    padding: EdgeInsets.only(bottom: i < _filtered.length - 1 ? 16 : 0),
                                    child: ActivityCard(activity: _filtered[i], onTap: () => _showDetail(_filtered[i])),
                                  ),
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

  void _showDetail(ApiActivity activity) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ActivityDetailBottomSheet(activity: activity),
    );
  }
}