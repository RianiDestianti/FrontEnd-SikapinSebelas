import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/screens/chart.dart';

class ChartDataItem {
  final double value;
  final String label;
  final String detail;
  final DateTime? date;
  final Map<String, dynamic>? metadata;

  ChartDataItem({
    required this.value,
    required this.label,
    required this.detail,
    this.date,
    this.metadata,
  });
}

class AnalysisDetailScreen extends StatefulWidget {
  final String chartType;
  final String title;
  final String subtitle;
  final List<ChartDataItem> data;
  final String period;

  const AnalysisDetailScreen({
    Key? key,
    required this.chartType,
    required this.title,
    required this.subtitle,
    required this.data,
    required this.period,
  }) : super(key: key);

  @override
  State<AnalysisDetailScreen> createState() => _AnalysisDetailScreenState();
}

class _AnalysisDetailScreenState extends State<AnalysisDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  int _selectedFilter = 0;
  bool _showMetrics = true;
  String _sortBy = 'value';
  bool _ascending = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  List<ChartDataItem> get _filteredData {
    List<ChartDataItem> filtered = List.from(widget.data);

    // Apply filters
    if (_selectedFilter == 1) {
      double avg =
          widget.data.map((e) => e.value).reduce((a, b) => a + b) /
          widget.data.length;
      filtered = filtered.where((item) => item.value > avg).toList();
    } else if (_selectedFilter == 2) {
      double avg =
          widget.data.map((e) => e.value).reduce((a, b) => a + b) /
          widget.data.length;
      filtered = filtered.where((item) => item.value <= avg).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'value':
          comparison = a.value.compareTo(b.value);
          break;
        case 'label':
          comparison = a.label.compareTo(b.label);
          break;
        case 'date':
          if (a.date != null && b.date != null) {
            comparison = a.date!.compareTo(b.date!);
          }
          break;
      }
      return _ascending ? comparison : -comparison;
    });

    return filtered;
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
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildEnhancedAppBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        _buildInteractiveHeader(),
                        const SizedBox(height: 20),
                        _buildAdvancedMetrics(),
                        const SizedBox(height: 20),
                        _buildFilterAndSort(),
                        const SizedBox(height: 20),
                        _buildDetailedAnalysisCards(),
                        const SizedBox(height: 20),
                        _buildInsightPanel(),
                        const SizedBox(height: 20),
                        _buildActionRecommendations(),
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
  }

  Widget _buildEnhancedAppBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.chartType == 'apresiasi'
                  ? [
                    const Color(0xFF667EEA),
                    const Color(0xFF764BA2),
                    const Color(0xFF5B73E8),
                  ]
                  : [
                    const Color(0xFFFF6B6D),
                    const Color(0xFFFF8E8F),
                    const Color(0xFFFF5252),
                  ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: (widget.chartType == 'apresiasi'
                    ? const Color(0xFF667EEA)
                    : const Color(0xFFFF6B6D))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 20,
          20,
          35,
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisis Detail',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
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
                          '${widget.title} - ${widget.period}',
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    widget.chartType == 'apresiasi'
                        ? Icons.analytics_outlined
                        : Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveHeader() {
    double total = widget.data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / widget.data.length;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors:
                        widget.chartType == 'apresiasi'
                            ? [
                              const Color(0xFF667EEA).withOpacity(0.1),
                              const Color(0xFF764BA2).withOpacity(0.05),
                            ]
                            : [
                              const Color(0xFFFF6B6D).withOpacity(0.1),
                              const Color(0xFFFF8E8F).withOpacity(0.05),
                            ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.insights,
                  color:
                      widget.chartType == 'apresiasi'
                          ? const Color(0xFF667EEA)
                          : const Color(0xFFFF6B6D),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ringkasan Analisis',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Total ${widget.data.length} data point dianalisis',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showMetrics = !_showMetrics;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _showMetrics ? Icons.visibility : Icons.visibility_off,
                    color: const Color(0xFF6B7280),
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          if (_showMetrics) ...[
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildQuickMetric(
                    'Total',
                    total.toInt().toString(),
                    Icons.analytics_outlined,
                    const Color(0xFF3B82F6),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickMetric(
                    'Rata-rata',
                    average.toStringAsFixed(1),
                    Icons.trending_flat,
                    const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickMetric(
                    'Range',
                    '${(_filteredData.map((e) => e.value).reduce((a, b) => a > b ? a : b) - _filteredData.map((e) => e.value).reduce((a, b) => a < b ? a : b)).toInt()}',
                    Icons.height,
                    const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickMetric(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedMetrics() {
    List<ChartDataItem> data = _filteredData;
    if (data.isEmpty) return const SizedBox.shrink();

    double total = data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / data.length;
    double variance =
        data.fold(
          0.0,
          (sum, item) =>
              sum + ((item.value - average) * (item.value - average)),
        ) /
        data.length;
    double standardDeviation = variance > 0 ? variance : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xFF8B5CF6), const Color(0xFFA855F7)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Metrik Statistik Lanjutan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildAdvancedMetricCard(
                  'Standar Deviasi',
                  standardDeviation.toStringAsFixed(2),
                  'Mengukur variabilitas data',
                  Icons.scatter_plot,
                  const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAdvancedMetricCard(
                  'Median',
                  _calculateMedian(data).toStringAsFixed(1),
                  'Nilai tengah dataset',
                  Icons.timeline,
                  const Color(0xFF06B6D4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildAdvancedMetricCard(
                  'Q1 (25%)',
                  _calculateQuartile(data, 0.25).toStringAsFixed(1),
                  'Kuartil pertama',
                  Icons.show_chart,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildAdvancedMetricCard(
                  'Q3 (75%)',
                  _calculateQuartile(data, 0.75).toStringAsFixed(1),
                  'Kuartil ketiga',
                  Icons.trending_up,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedMetricCard(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateMedian(List<ChartDataItem> data) {
    List<double> values = data.map((e) => e.value).toList()..sort();
    int n = values.length;
    if (n % 2 == 0) {
      return (values[n ~/ 2 - 1] + values[n ~/ 2]) / 2;
    } else {
      return values[n ~/ 2];
    }
  }

  double _calculateQuartile(List<ChartDataItem> data, double percentile) {
    List<double> values = data.map((e) => e.value).toList()..sort();
    double index = percentile * (values.length - 1);
    int lower = index.floor();
    int upper = index.ceil();

    if (lower == upper) {
      return values[lower];
    } else {
      return values[lower] + (values[upper] - values[lower]) * (index - lower);
    }
  }

  Widget _buildFilterAndSort() {
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
          Text(
            'Filter & Sorting',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Data',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children:
                          [
                            'Semua',
                            'Di Atas Rata-rata',
                            'Di Bawah Rata-rata',
                          ].asMap().entries.map((entry) {
                            int index = entry.key;
                            String filter = entry.value;
                            bool isActive = _selectedFilter == index;

                            return Expanded(
                              child: GestureDetector(
                                onTap:
                                    () =>
                                        setState(() => _selectedFilter = index),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isActive
                                            ? (widget.chartType == 'apresiasi'
                                                ? const Color(0xFF667EEA)
                                                : const Color(0xFFFF6B6D))
                                            : const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    filter,
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color:
                                          isActive
                                              ? Colors.white
                                              : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Urutkan Berdasarkan',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'value',
                          child: Text(
                            'Nilai',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'label',
                          child: Text(
                            'Label',
                            style: GoogleFonts.poppins(fontSize: 14),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _sortBy = value);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => setState(() => _ascending = !_ascending),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        _ascending
                            ? const Color(0xFF10B981)
                            : const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedAnalysisCards() {
    List<ChartDataItem> data = _filteredData;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors:
                            widget.chartType == 'apresiasi'
                                ? [
                                  const Color(0xFF667EEA),
                                  const Color(0xFF764BA2),
                                ]
                                : [
                                  const Color(0xFFFF6B6D),
                                  const Color(0xFFFF8E8F),
                                ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.list_alt,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data Detail (${data.length} item)',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          'Terfilter dan terurut',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...data.asMap().entries.map((entry) {
                int index = entry.key;
                ChartDataItem item = entry.value;
                return _buildEnhancedDetailCard(item, index);
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedDetailCard(ChartDataItem item, int index) {
    double total = widget.data.fold(0.0, (sum, item) => sum + item.value);
    double percentage = (item.value / total) * 100;
    double average = total / widget.data.length;
    bool isAboveAverage = item.value > average;

    Color cardColor =
        widget.chartType == 'apresiasi'
            ? [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFF3B82F6),
              const Color(0xFF1E40AF),
              const Color(0xFF1E3A8A),
            ][index % 5]
            : [
              const Color(0xFFFF6B6D),
              const Color(0xFFFF8E8F),
              const Color(0xFFEF4444),
              const Color(0xFFDC2626),
              const Color(0xFFB91C1C),
            ][index % 5];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  cardColor.withOpacity(0.05),
                  cardColor.withOpacity(0.02),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: cardColor.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: cardColor.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardColor, cardColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: cardColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.label,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (isAboveAverage)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'TINGGI',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Performa: ${isAboveAverage ? "Di atas" : "Di bawah"} rata-rata',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color:
                                  isAboveAverage
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF6B7280),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cardColor, cardColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: cardColor.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Text(
                        '${item.value.toInt()}',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: cardColor.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: cardColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Detail Informasi',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        item.detail,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Kontribusi: ',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF9CA3AF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cardColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${percentage.toStringAsFixed(1)}%',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: cardColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: cardColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      cardColor,
                                      cardColor.withOpacity(0.7),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: cardColor.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      children: [
                        Text(
                          'vs Rata-rata',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              isAboveAverage
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color:
                                  isAboveAverage
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${((item.value - average) / average * 100).abs().toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color:
                                    isAboveAverage
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFEF4444),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: cardColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightPanel() {
    List<ChartDataItem> data = _filteredData;
    double total = data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / data.length;

    List<ChartDataItem> aboveAverage =
        data.where((item) => item.value > average).toList();
    List<ChartDataItem> belowAverage =
        data.where((item) => item.value <= average).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF1F2937), const Color(0xFF374151)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Insights & Prediksi',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Analisis cerdas berdasarkan data yang tersedia',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildInsightCard(
                  'Performa Tinggi',
                  '${aboveAverage.length}',
                  'item di atas rata-rata',
                  Icons.trending_up,
                  const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInsightCard(
                  'Perlu Perhatian',
                  '${belowAverage.length}',
                  'item di bawah rata-rata',
                  Icons.trending_down,
                  const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Insight Utama',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _generateMainInsight(
                    data,
                    average,
                    aboveAverage,
                    belowAverage,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _generateMainInsight(
    List<ChartDataItem> data,
    double average,
    List<ChartDataItem> aboveAverage,
    List<ChartDataItem> belowAverage,
  ) {
    if (data.isEmpty) return 'Tidak ada data untuk dianalisis.';

    String period = widget.period.toLowerCase();
    String type = widget.chartType;

    if (type == 'apresiasi') {
      if (aboveAverage.length > belowAverage.length) {
        return 'Performa apresiasi $period menunjukkan tren positif dengan ${aboveAverage.length} dari ${data.length} kategori berada di atas rata-rata (${average.toStringAsFixed(1)}). Ini mengindikasikan program motivasi berjalan efektif dan siswa menunjukkan antusiasme yang tinggi dalam berbagai aspek.';
      } else {
        return 'Terdapat ruang untuk peningkatan dalam program apresiasi $period. Dengan ${belowAverage.length} dari ${data.length} kategori di bawah rata-rata, perlu strategi baru untuk meningkatkan engagement siswa melalui variasi reward dan program motivasi yang lebih menarik.';
      }
    } else {
      if (belowAverage.length > aboveAverage.length) {
        return 'Kondisi kedisiplinan $period menunjukkan perbaikan yang baik dengan ${belowAverage.length} dari ${data.length} kategori berada di bawah rata-rata pelanggaran. Sistem pengawasan dan program pembinaan karakter menunjukkan hasil positif yang perlu dipertahankan.';
      } else {
        return 'Pelanggaran $period memerlukan perhatian khusus dengan ${aboveAverage.length} dari ${data.length} kategori di atas rata-rata. Diperlukan evaluasi sistem pengawasan dan implementasi program intervensi yang lebih intensif untuk meningkatkan kedisiplinan siswa.';
      }
    }
  }

  Widget _buildActionRecommendations() {
    List<ChartDataItem> data = _filteredData;
    double total = data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / data.length;

    List<ChartDataItem> topPerformers =
        data.where((item) => item.value > average * 1.2).toList();
    List<ChartDataItem> needsImprovement =
        data.where((item) => item.value < average * 0.8).toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              widget.chartType == 'apresiasi'
                  ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                  : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (widget.chartType == 'apresiasi'
                    ? const Color(0xFF667EEA)
                    : const Color(0xFFFF6B6D))
                .withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.recommend,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rekomendasi Tindakan',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Saran strategis berdasarkan analisis data',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (topPerformers.isNotEmpty) ...[
            _buildActionCard(
              'Pertahankan Performa Terbaik',
              'Focus pada ${topPerformers.map((e) => e.label).join(", ")}',
              Icons.star,
              Colors.white,
              _getTopPerformerRecommendation(topPerformers),
            ),
            const SizedBox(height: 16),
          ],
          if (needsImprovement.isNotEmpty) ...[
            _buildActionCard(
              'Area yang Memerlukan Perbaikan',
              'Prioritas pada ${needsImprovement.map((e) => e.label).join(", ")}',
              Icons.flag,
              Colors.white,
              _getImprovementRecommendation(needsImprovement),
            ),
            const SizedBox(height: 16),
          ],
          _buildActionCard(
            'Strategi Jangka Panjang',
            'Rencana berkelanjutan untuk ${widget.period}',
            Icons.timeline,
            Colors.white,
            _getLongTermStrategy(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    String description,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
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
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withOpacity(0.95),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _getTopPerformerRecommendation(List<ChartDataItem> topPerformers) {
    if (widget.chartType == 'apresiasi') {
      return 'Kategori dengan performa terbaik ini dapat dijadikan model untuk area lain. Pertimbangkan untuk menganalisis faktor sukses dan menerapkannya secara konsisten. Berikan penghargaan khusus untuk mempertahankan motivasi tinggi.';
    } else {
      return 'Area dengan pelanggaran tinggi ini memerlukan intervensi segera. Tingkatkan pengawasan, adakan program pembinaan intensif, dan libatkan orang tua dalam proses perbaikan kedisiplinan.';
    }
  }

  String _getImprovementRecommendation(List<ChartDataItem> needsImprovement) {
    if (widget.chartType == 'apresiasi') {
      return 'Area dengan apresiasi rendah memerlukan revitalisasi program. Lakukan survey kepuasan siswa, tingkatkan variasi reward, dan ciptakan kompetisi sehat untuk meningkatkan partisipasi dan antusiasme.';
    } else {
      return 'Meskipun pelanggaran rendah adalah hal positif, tetap pertahankan vigilansi. Berikan apresiasi kepada siswa yang disiplin dan gunakan sebagai contoh positif untuk mempertahankan kultur disiplin yang baik.';
    }
  }

  String _getLongTermStrategy() {
    if (widget.chartType == 'apresiasi') {
      return 'Kembangkan sistem apresiasi yang berkelanjutan dengan melibatkan siswa dalam perancangan program. Integrasikan teknologi untuk tracking yang lebih baik dan ciptakan jalur karir apresiasi yang jelas untuk motivasi jangka panjang.';
    } else {
      return 'Bangun kultur disiplin positif melalui program character building yang komprehensif. Fokus pada pencegahan daripada hukuman, dengan mengembangkan sistem mentoring dan program pengembangan kepemimpinan siswa.';
    }
  }
}
