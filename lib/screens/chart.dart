import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class ChartDataItem {
  final double value;
  final String label;
  final String detail;

  ChartDataItem({
    required this.value,
    required this.label,
    required this.detail,
  });
}

class GrafikScreen extends StatefulWidget {
  final String chartType;
  final String title;
  final String subtitle;

  const GrafikScreen({
    Key? key,
    required this.chartType,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  State<GrafikScreen> createState() => _GrafikScreenState();
}

class _GrafikScreenState extends State<GrafikScreen> with TickerProviderStateMixin {
  int _selectedPeriod = 0;
  int _selectedChartType = 0;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final Map<String, List<ChartDataItem>> _apresiasiData = {
    'minggu': [
      ChartDataItem(value: 80.0, label: 'Sen', detail: 'Kebersihan: 30, Kedisiplinan: 25, Prestasi: 25'),
      ChartDataItem(value: 120.0, label: 'Sel', detail: 'Kebersihan: 40, Kedisiplinan: 35, Prestasi: 45'),
      ChartDataItem(value: 90.0, label: 'Rab', detail: 'Kebersihan: 35, Kedisiplinan: 30, Prestasi: 25'),
      ChartDataItem(value: 40.0, label: 'Kam', detail: 'Kebersihan: 15, Kedisiplinan: 10, Prestasi: 15'),
      ChartDataItem(value: 100.0, label: 'Jum', detail: 'Kebersihan: 35, Kedisiplinan: 30, Prestasi: 35'),
      ChartDataItem(value: 75.0, label: 'Sab', detail: 'Kebersihan: 25, Kedisiplinan: 25, Prestasi: 25'),
      ChartDataItem(value: 85.0, label: 'Min', detail: 'Kebersihan: 30, Kedisiplinan: 25, Prestasi: 30'),
    ],
    'bulan': [
      ChartDataItem(value: 320.0, label: 'Jan', detail: 'Total siswa: 85, Rata-rata: 3.8 poin'),
      ChartDataItem(value: 480.0, label: 'Feb', detail: 'Total siswa: 85, Rata-rata: 5.6 poin'),
      ChartDataItem(value: 360.0, label: 'Mar', detail: 'Total siswa: 85, Rata-rata: 4.2 poin'),
      ChartDataItem(value: 420.0, label: 'Apr', detail: 'Total siswa: 85, Rata-rata: 4.9 poin'),
      ChartDataItem(value: 380.0, label: 'Mei', detail: 'Total siswa: 85, Rata-rata: 4.5 poin'),
      ChartDataItem(value: 450.0, label: 'Jun', detail: 'Total siswa: 85, Rata-rata: 5.3 poin'),
    ],
    'tahun': [
      ChartDataItem(value: 1800.0, label: '2022', detail: 'Total: 1800 poin, Siswa aktif: 80'),
      ChartDataItem(value: 2400.0, label: '2023', detail: 'Total: 2400 poin, Siswa aktif: 85'),
      ChartDataItem(value: 1920.0, label: '2024', detail: 'Total: 1920 poin, Siswa aktif: 85'),
    ],
  };

  final Map<String, List<ChartDataItem>> _pelanggaranData = {
    'minggu': [
      ChartDataItem(value: 60.0, label: 'Sen', detail: 'Terlambat: 25, Seragam: 20, Lainnya: 15'),
      ChartDataItem(value: 25.0, label: 'Sel', detail: 'Terlambat: 10, Seragam: 8, Lainnya: 7'),
      ChartDataItem(value: 15.0, label: 'Rab', detail: 'Terlambat: 8, Seragam: 4, Lainnya: 3'),
      ChartDataItem(value: 10.0, label: 'Kam', detail: 'Terlambat: 5, Seragam: 3, Lainnya: 2'),
      ChartDataItem(value: 20.0, label: 'Jum', detail: 'Terlambat: 12, Seragam: 5, Lainnya: 3'),
      ChartDataItem(value: 18.0, label: 'Sab', detail: 'Terlambat: 10, Seragam: 5, Lainnya: 3'),
      ChartDataItem(value: 12.0, label: 'Min', detail: 'Terlambat: 8, Seragam: 2, Lainnya: 2'),
    ],
    'bulan': [
      ChartDataItem(value: 240.0, label: 'Jan', detail: 'Total kasus: 48, Rata-rata: 2.8 per siswa'),
      ChartDataItem(value: 100.0, label: 'Feb', detail: 'Total kasus: 20, Rata-rata: 1.2 per siswa'),
      ChartDataItem(value: 60.0, label: 'Mar', detail: 'Total kasus: 12, Rata-rata: 0.7 per siswa'),
      ChartDataItem(value: 45.0, label: 'Apr', detail: 'Total kasus: 9, Rata-rata: 0.5 per siswa'),
      ChartDataItem(value: 35.0, label: 'Mei', detail: 'Total kasus: 7, Rata-rata: 0.4 per siswa'),
      ChartDataItem(value: 25.0, label: 'Jun', detail: 'Total kasus: 5, Rata-rata: 0.3 per siswa'),
    ],
    'tahun': [
      ChartDataItem(value: 960.0, label: '2022', detail: 'Total: 960 kasus, Siswa terlibat: 65'),
      ChartDataItem(value: 720.0, label: '2023', detail: 'Total: 720 kasus, Siswa terlibat: 58'),
      ChartDataItem(value: 520.0, label: '2024', detail: 'Total: 520 kasus, Siswa terlibat: 45'),
    ],
  };

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
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<ChartDataItem> _getCurrentData() {
    String period = ['minggu', 'bulan', 'tahun'][_selectedPeriod];
    return widget.chartType == 'apresiasi'
        ? _apresiasiData[period]!
        : _pelanggaranData[period]!;
  }

  String _getPeriodLabel() {
    return ['Minggu Ini', 'Bulan Ini', 'Tahun Ini'][_selectedPeriod];
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
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildAppBar(),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                _buildStatisticsCards(),
                                const SizedBox(height: 20),
                                _buildPeriodSelector(),
                                const SizedBox(height: 20),
                                _buildChartTypeSelector(),
                                const SizedBox(height: 20),
                                _buildMainChart(),
                                const SizedBox(height: 20),
                                _buildDetailedAnalysis(),
                                const SizedBox(height: 20),
                                _buildTrendAnalysis(),
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

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.chartType == 'apresiasi'
              ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
              : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
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
                        widget.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.subtitle,
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
                  child: Icon(
                    widget.chartType == 'apresiasi' ? Icons.trending_up : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCards() {
    List<ChartDataItem> data = _getCurrentData();
    double total = data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / data.length;
    double max = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', total.toInt().toString(), Icons.analytics_outlined, const Color(0xFF0083EE))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Rata-rata', average.toInt().toString(), Icons.trending_up, const Color(0xFF10B981))),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Tertinggi', max.toInt().toString(), Icons.north, const Color(0xFFFFD700))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: ['Minggu', 'Bulan', 'Tahun'].asMap().entries.map((entry) {
          int index = entry.key;
          String period = entry.value;
          bool isActive = _selectedPeriod == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  gradient: isActive ? LinearGradient(
                    colors: widget.chartType == 'apresiasi'
                        ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                        : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
                  ) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  period,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: isActive ? Colors.white : const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          {'name': 'Bar', 'icon': Icons.bar_chart},
          {'name': 'Line', 'icon': Icons.show_chart},
          {'name': 'Pie', 'icon': Icons.pie_chart},
        ].asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, dynamic> chartType = entry.value;
          bool isActive = _selectedChartType == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedChartType = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFF3F4F6) : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      chartType['icon'],
                      color: isActive ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      chartType['name'],
                      style: GoogleFonts.poppins(
                        color: isActive ? const Color(0xFF1F2937) : const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMainChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              Expanded(
                child: Text(
                  'Grafik ${widget.title} - ${_getPeriodLabel()}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.chartType == 'apresiasi'
                        ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                        : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getPeriodLabel(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_selectedChartType == 0) _buildBarChart(),
          if (_selectedChartType == 1) _buildLineChart(),
          if (_selectedChartType == 2) _buildPieChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    List<ChartDataItem> data = _getCurrentData();
    double maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 40,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${maxValue.toInt()}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF))),
                      Text('${(maxValue * 0.75).toInt()}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF))),
                      Text('${(maxValue * 0.5).toInt()}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF))),
                      Text('${(maxValue * 0.25).toInt()}', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF))),
                      Text('0', style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((item) {
                      double value = item.value;
                      double height = (value / maxValue) * 150;
                      return Container(
                        width: 32,
                        height: height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.chartType == 'apresiasi'
                                ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                                : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 52),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.map((item) {
                    return Text(
                      item.label,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    List<ChartDataItem> data = _getCurrentData();
    double maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size(double.infinity, 150),
              painter: LineChartPainter(
                data: data,
                maxValue: maxValue,
                gradient: LinearGradient(
                  colors: widget.chartType == 'apresiasi'
                      ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                      : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: data.map((item) {
              return Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    List<ChartDataItem> data = _getCurrentData();
    double total = data.fold(0.0, (sum, item) => sum + item.value);

    return Container(
      height: 250,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomPaint(
              size: const Size(150, 150),
              painter: PieChartPainter(
                data: data,
                total: total,
                colors: widget.chartType == 'apresiasi'
                    ? [const Color(0xFF61B8FF), const Color(0xFF0083EE), const Color(0xFF3B82F6), const Color(0xFF1E40AF), const Color(0xFF1E3A8A)]
                    : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F), const Color(0xFFEF4444), const Color(0xFFDC2626), const Color(0xFFB91C1C)],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.asMap().entries.map((entry) {
                int index = entry.key;
                ChartDataItem item = entry.value;
                double percentage = (item.value / total) * 100;
                Color color = widget.chartType == 'apresiasi'
                    ? [const Color(0xFF61B8FF), const Color(0xFF0083EE), const Color(0xFF3B82F6), const Color(0xFF1E40AF), const Color(0xFF1E3A8A)][index % 5]
                    : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F), const Color(0xFFEF4444), const Color(0xFFDC2626), const Color(0xFFB91C1C)][index % 5];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.label,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              '${percentage.toInt()}%',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    List<ChartDataItem> data = _getCurrentData();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.chartType == 'apresiasi'
                        ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                        : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Analisis Detail',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...data.map((item) => _buildDetailItem(item)).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailItem(ChartDataItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1F2937),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: widget.chartType == 'apresiasi'
                        ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
                        : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.value.toInt()}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.detail,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    List<ChartDataItem> data = _getCurrentData();
    double total = data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / data.length;

    bool isIncreasing = data.length > 1 && data.last.value > data.first.value;
    double changePercentage = data.length > 1
        ? ((data.last.value - data.first.value) / data.first.value * 100).abs()
        : 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widget.chartType == 'apresiasi'
              ? [const Color(0xFF61B8FF), const Color(0xFF0083EE)]
              : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.insights, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Analisis Tren',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  'Status Tren',
                  isIncreasing ? 'Meningkat' : 'Menurun',
                  isIncreasing ? Icons.trending_up : Icons.trending_down,
                  Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTrendCard(
                  'Perubahan',
                  '${changePercentage.toInt()}%',
                  isIncreasing ? Icons.north : Icons.south,
                  Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.chartType == 'apresiasi'
                      ? isIncreasing
                          ? 'Tren positif! Pertahankan program apresiasi yang sedang berjalan dan tingkatkan variasi reward untuk memotivasi siswa.'
                          : 'Perlu peningkatan program apresiasi. Pertimbangkan untuk menambah kegiatan motivasi dan sistem reward yang lebih menarik.'
                      : isIncreasing
                          ? 'Perlu perhatian khusus! Tingkatkan pengawasan dan buat program pencegahan pelanggaran yang lebih efektif.'
                          : 'Tren menurun sangat baik! Pertahankan sistem pengawasan dan terus tingkatkan program kedisiplinan.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(String title, String value, IconData icon, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartDataItem> data;
  final double maxValue;
  final Gradient gradient;

  LineChartPainter({
    required this.data,
    required this.maxValue,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final pointPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      double x = (i / (data.length - 1)) * size.width;
      double y = size.height - (data[i].value / maxValue) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(Offset(x, y), 4, pointPaint);

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class PieChartPainter extends CustomPainter {
  final List<ChartDataItem> data;
  final double total;
  final List<Color> colors;

  PieChartPainter({
    required this.data,
    required this.total,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.8;
    double startAngle = -90 * (3.14159 / 180);

    for (int i = 0; i < data.length; i++) {
      double sweepAngle = (data[i].value / total) * 2 * 3.14159;

      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      startAngle += sweepAngle;
    }

    canvas.drawCircle(
      center,
      radius * 0.4,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}