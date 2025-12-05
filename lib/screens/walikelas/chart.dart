// screens/grafik_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:skoring/models/api/api_chart_data.dart';
import 'package:skoring/widgets/chart/grafik_app_bar.dart';
import 'package:skoring/widgets/chart/stat_card.dart';
import 'package:skoring/widgets/chart/period_selector.dart';
import 'package:skoring/widgets/chart/chart_type_selector.dart';
import 'package:skoring/widgets/chart/bar_chart_widget.dart';
import 'package:skoring/widgets/chart/pie_chart_widget.dart';
import 'package:skoring/widgets/chart/detailed_analysis_widget.dart';
import 'package:skoring/widgets/chart/trend_analysis_widget.dart';
import 'package:skoring/widgets/chart/empty_state_chart.dart';

class GrafikScreen extends StatefulWidget {
  final String chartType;
  final String title;
  final String subtitle;

  const GrafikScreen({Key? key, required this.chartType, required this.title, required this.subtitle}) : super(key: key);

  @override
  State<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends State<GrafikScreen> with TickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  int _period = 0;
  int _chartType = 0;
  String _classId = '', _nip = '';
  List<ApiChartData> _data = [];
  bool _loading = true;
  String? _error;

  final _periods = ['Minggu Ini', 'Bulan Ini', 'Tahun Ini'];
  final _months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
    _loadData();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => {_loading = true, _error = null});
    try {
      final prefs = await SharedPreferences.getInstance();
      _classId = prefs.getString('id_kelas') ?? '';
      _nip = prefs.getString('walikelas_id') ?? '';
      if (_classId.isEmpty || _nip.isEmpty) throw 'Data guru tidak lengkap';
      await _fetch();
    } catch (e) {
      setState(() => {_error = e.toString(), _loading = false});
    }
  }

  Future<void> _fetch() async {
    final endpoint = widget.chartType == 'apresiasi' ? 'skoring_penghargaan' : 'skoring_pelanggaran';
    final uri = Uri.parse('http://127.0.0.1:3000/api/$endpoint?nip=$_nip&id_kelas=$_classId');

    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) throw 'Gagal mengambil data';

    final json = jsonDecode(res.body);
    if (!json['success']) throw json['message'] ?? 'Gagal';

    final penilaian = json['penilaian']['data'] as List;
    final siswa = json['siswa'] as List;

    final weekly = <String, double>{};
    final monthly = <String, double>{};

    for (var p in penilaian) {
      if (siswa.any((s) => s['nis'] == p['nis'] && s['id_kelas'] == _classId)) {
        final date = DateTime.parse(p['created_at']);
        final week = '${date.year}-W${((date.day + 6) / 7).ceil()}';
        final month = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        weekly[week] = (weekly[week] ?? 0) + 1;
        monthly[month] = (monthly[month] ?? 0) + 1;
      }
    }

    final map = _period == 0 ? weekly : monthly;
    final List<ApiChartData> list = map.entries.map((e) {
      final label = _period == 0 ? e.key.split('-W')[1] : _months[int.parse(e.key.split('-')[1]) - 1];
      return ApiChartData(value: e.value, label: label, detail: 'Total: ${e.value.toInt()} kasus');
    }).toList()..sort((a, b) => a.label.compareTo(b.label));

    setState(() => {_data = list, _loading = false});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: GoogleFonts.poppins(color: Colors.red)),
              ElevatedButton(onPressed: _loadData, child: Text('Coba Lagi', style: GoogleFonts.poppins())),
            ],
          ),
        ),
      );
    }

    final isApresiasi = widget.chartType == 'apresiasi';
    final total = _data.fold(0.0, (s, i) => s + i.value);
    final avg = _data.isNotEmpty ? total / _data.length : 0.0;
    final max = _data.isNotEmpty ? _data.map((e) => e.value).reduce((a, b) => a > b ? a : b) : 0.0;

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
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      children: [
                        GrafikAppBar(title: widget.title, subtitle: widget.subtitle, isApresiasi: isApresiasi, icon: isApresiasi ? Icons.trending_up : Icons.warning_amber_rounded),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: StatCard(title: 'Total', value: total.toInt().toString(), icon: Icons.analytics_outlined, color: const Color(0xFF0083EE))),
                                    const SizedBox(width: 12),
                                    Expanded(child: StatCard(title: 'Rata-rata', value: avg.toInt().toString(), icon: Icons.trending_up, color: const Color(0xFF10B981))),
                                    const SizedBox(width: 12),
                                    Expanded(child: StatCard(title: 'Tertinggi', value: max.toInt().toString(), icon: Icons.north, color: const Color(0xFFFFD700))),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                PeriodSelector(
                                  selectedIndex: _period,
                                  isApresiasi: isApresiasi,
                                  onChanged: (i) {
                                    setState(() {
                                      _period = i;
                                    });
                                    _fetch(); 
                                  },
                                ),

                                // ChartTypeSelector(
                                //   selectedIndex: _chartType,
                                //   onChanged: (i) {
                                //     setState(() {
                                //       _chartType = i;
                                //     });
                                //   },
                                // ),
                                const SizedBox(height: 20),
                                ChartTypeSelector(selectedIndex: _chartType, onChanged: (i) => setState(() => _chartType = i)),
                                const SizedBox(height: 20),
                                Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text('Grafik ${widget.title} - ${_periods[_period]}', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)))),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(gradient: LinearGradient(colors: isApresiasi ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)] : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)]), borderRadius: BorderRadius.circular(12)),
                                            child: Text(_periods[_period], style: GoogleFonts.poppins(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      _data.isEmpty
                                          ? EmptyStateChart(message: 'Tidak ada data untuk periode ini', isApresiasi: isApresiasi)
                                          : _chartType == 0
                                              ? BarChartWidget(data: _data, isApresiasi: isApresiasi)
                                              : PieChartWidget(data: _data, total: total, isApresiasi: isApresiasi),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                DetailedAnalysisWidget(data: _data, isApresiasi: isApresiasi),
                                const SizedBox(height: 20),
                                TrendAnalysisWidget(data: _data, isApresiasi: isApresiasi),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}