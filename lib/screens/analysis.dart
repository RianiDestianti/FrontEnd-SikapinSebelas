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

class AnalysisScreen extends StatefulWidget {
  final String chartType;
  final String title;
  final String subtitle;
  final List<ChartDataItem> data;
  final String period;

  const AnalysisScreen({
    Key? key,
    required this.chartType,
    required this.title,
    required this.subtitle,
    required this.data,
    required this.period,
  }) : super(key: key);

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
            double maxWidth =
                constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
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
                                _buildOverviewCards(),
                                const SizedBox(height: 20),
                                _buildTabSelector(),
                                const SizedBox(height: 20),
                                if (_selectedTab == 0)
                                  _buildDetailedBreakdown(),
                                if (_selectedTab == 1) _buildTrendAnalysis(),
                                if (_selectedTab == 2)
                                  _buildComparativeAnalysis(),
                                if (_selectedTab == 3) _buildRecommendations(),
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
          colors:
              widget.chartType == 'apresiasi'
                  ? [const Color(0xFF667EEA), const Color(0xFF764BA2)]
                  : [const Color(0xFFFF6B6D), const Color(0xFFFF8E8F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          MediaQuery.of(context).padding.top + 20,
          20,
          30,
        ),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analisis Detail',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${widget.title} - ${widget.period}',
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
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

  Widget _buildOverviewCards() {
    double total = widget.data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / widget.data.length;
    double max = widget.data
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    double min = widget.data
        .map((e) => e.value)
        .reduce((a, b) => a < b ? a : b);

    return Row(
      children: [
        Expanded(
          child: _buildOverviewCard(
            'Total',
            total.toInt().toString(),
            Icons.analytics_outlined,
            const Color(0xFF667EEA),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Rata-rata',
            average.toInt().toString(),
            Icons.trending_up,
            const Color(0xFF10B981),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Tertinggi',
            max.toInt().toString(),
            Icons.north,
            const Color(0xFFFFD700),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildOverviewCard(
            'Terendah',
            min.toInt().toString(),
            Icons.south,
            const Color(0xFFFF6B6D),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1F2937),
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

  Widget _buildTabSelector() {
    List<Map<String, dynamic>> tabs = [
      {'name': 'Detail', 'icon': Icons.list_alt},
      {'name': 'Tren', 'icon': Icons.trending_up},
      {'name': 'Komparasi', 'icon': Icons.compare_arrows},
      {'name': 'Saran', 'icon': Icons.lightbulb_outline},
    ];

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children:
            tabs.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> tab = entry.value;
              bool isActive = _selectedTab == index;

              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTab = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient:
                          isActive
                              ? LinearGradient(
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
                              )
                              : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow:
                          isActive
                              ? [
                                BoxShadow(
                                  color: (widget.chartType == 'apresiasi'
                                          ? const Color(0xFF667EEA)
                                          : const Color(0xFFFF6B6D))
                                      .withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                              : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          tab['icon'],
                          color:
                              isActive ? Colors.white : const Color(0xFF6B7280),
                          size: 18,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tab['name'],
                          style: GoogleFonts.poppins(
                            color:
                                isActive
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
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

  Widget _buildDetailedBreakdown() {
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
                      Icons.analytics_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Rincian Data Detail',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ...widget.data.asMap().entries.map((entry) {
                int index = entry.key;
                ChartDataItem item = entry.value;
                return _buildDetailedItem(item, index);
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedItem(ChartDataItem item, int index) {
    double total = widget.data.fold(0.0, (sum, item) => sum + item.value);
    double percentage = (item.value / total) * 100;

    Color itemColor =
        widget.chartType == 'apresiasi'
            ? [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
              const Color(0xFF667EEA),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [itemColor.withOpacity(0.05), itemColor.withOpacity(0.02)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: itemColor.withOpacity(0.1), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: itemColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [itemColor, itemColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${item.value.toInt()}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.info_outline, color: itemColor, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.detail,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Kontribusi: ',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: itemColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: itemColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: percentage / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [itemColor, itemColor.withOpacity(0.7)],
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrendAnalysis() {
    double firstValue = widget.data.first.value;
    double lastValue = widget.data.last.value;
    bool isIncreasing = lastValue > firstValue;
    double changePercentage = ((lastValue - firstValue) / firstValue * 100);

    return Container(
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
                    colors: [const Color(0xFF10B981), const Color(0xFF059669)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Analisis Tren',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  'Status Tren',
                  isIncreasing ? 'Naik' : 'Turun',
                  isIncreasing ? Icons.trending_up : Icons.trending_down,
                  isIncreasing
                      ? const Color(0xFF10B981)
                      : const Color(0xFFEF4444),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTrendCard(
                  'Perubahan',
                  '${changePercentage.abs().toStringAsFixed(1)}%',
                  isIncreasing ? Icons.north : Icons.south,
                  const Color(0xFF667EEA),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.insights,
                      color: const Color(0xFF667EEA),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Insight Tren',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _getTrendInsight(isIncreasing, changePercentage),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
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
              fontSize: 12,
              color: const Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getTrendInsight(bool isIncreasing, double changePercentage) {
    if (widget.chartType == 'apresiasi') {
      if (isIncreasing) {
        if (changePercentage > 20) {
          return 'Peningkatan yang sangat signifikan dalam apresiasi siswa! Program motivasi berjalan dengan sangat baik. Ini menunjukkan antusiasme siswa yang tinggi dan efektivitas sistem reward yang diterapkan.';
        } else if (changePercentage > 10) {
          return 'Tren positif yang konsisten dalam apresiasi siswa. Program yang sedang berjalan menunjukkan hasil yang baik dan perlu dipertahankan dengan variasi kegiatan baru.';
        } else {
          return 'Peningkatan moderat dalam apresiasi. Ada potensi untuk meningkatkan program motivasi dengan strategi yang lebih inovatif dan menarik bagi siswa.';
        }
      } else {
        if (changePercentage.abs() > 20) {
          return 'Penurunan drastis dalam apresiasi siswa memerlukan perhatian segera. Perlu evaluasi menyeluruh terhadap program motivasi dan sistem reward yang ada.';
        } else {
          return 'Terjadi penurunan dalam apresiasi siswa. Perlu peningkatan engagement melalui program yang lebih menarik dan relevan dengan minat siswa.';
        }
      }
    } else {
      if (isIncreasing) {
        if (changePercentage > 20) {
          return 'Peningkatan pelanggaran yang mengkhawatirkan! Diperlukan tindakan preventif segera dan evaluasi sistem pengawasan. Perlu program intervensi khusus.';
        } else {
          return 'Terjadi peningkatan pelanggaran yang perlu diwaspadai. Tingkatkan pengawasan dan sosialisasi tata tertib sekolah kepada siswa.';
        }
      } else {
        if (changePercentage.abs() > 20) {
          return 'Penurunan pelanggaran yang sangat baik! Sistem pengawasan dan program kedisiplinan berjalan efektif. Pertahankan dan tingkatkan strategi yang ada.';
        } else {
          return 'Tren penurunan pelanggaran menunjukkan perbaikan kedisiplinan. Terus konsisten dalam menerapkan aturan dan program pembinaan karakter.';
        }
      }
    }
  }

  Widget _buildComparativeAnalysis() {
    double total = widget.data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / widget.data.length;

    return Container(
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
                    colors: [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.compare_arrows,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Analisis Komparatif',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...widget.data
              .map((item) => _buildComparisonItem(item, average))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildComparisonItem(ChartDataItem item, double average) {
    bool aboveAverage = item.value > average;
    double difference = (item.value - average).abs();
    double differencePercentage = (difference / average) * 100;

    Color comparisonColor =
        aboveAverage
            ? (widget.chartType == 'apresiasi'
                ? const Color(0xFF10B981)
                : const Color(0xFFEF4444))
            : (widget.chartType == 'apresiasi'
                ? const Color(0xFFEF4444)
                : const Color(0xFF10B981));

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            comparisonColor.withOpacity(0.05),
            comparisonColor.withOpacity(0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: comparisonColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nilai: ${item.value.toInt()}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      aboveAverage ? Icons.trending_up : Icons.trending_down,
                      color: comparisonColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      aboveAverage ? 'Di atas rata-rata' : 'Di bawah rata-rata',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: comparisonColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: comparisonColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${differencePercentage.toStringAsFixed(1)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: comparisonColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    double total = widget.data.fold(0.0, (sum, item) => sum + item.value);
    double average = total / widget.data.length;
    bool isIncreasing = widget.data.last.value > widget.data.first.value;
    double changePercentage =
        ((widget.data.last.value - widget.data.first.value) /
                widget.data.first.value *
                100)
            .abs();

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
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
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
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Rekomendasi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Saran Strategis',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _getRecommendationText(
                    isIncreasing,
                    changePercentage,
                    average,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRecommendationText(
    bool isIncreasing,
    double changePercentage,
    double average,
  ) {
    if (widget.chartType == 'apresiasi') {
      if (isIncreasing) {
        if (changePercentage > 20) {
          return 'Tren apresiasi sangat positif! Pertahankan program reward yang ada dan pertimbangkan untuk menambahkan variasi seperti penghargaan individu dan kelompok untuk meningkatkan motivasi siswa.';
        } else {
          return 'Tren apresiasi menunjukkan peningkatan yang baik. Tingkatkan engagement siswa dengan memperkenalkan kegiatan kompetitif atau gamifikasi dalam sistem reward.';
        }
      } else {
        if (changePercentage > 20) {
          return 'Penurunan signifikan dalam apresiasi perlu perhatian segera. Evaluasi efektivitas program motivasi saat ini dan pertimbangkan untuk melibatkan siswa dalam merancang sistem reward baru.';
        } else {
          return 'Tren apresiasi menurun. Tingkatkan komunikasi dengan siswa untuk memahami kebutuhan mereka dan rancang program apresiasi yang lebih relevan dan menarik.';
        }
      }
    } else {
      if (isIncreasing) {
        if (changePercentage > 20) {
          return 'Peningkatan pelanggaran signifikan! Segera lakukan intervensi dengan memperketat pengawasan, mengadakan sesi pembinaan, dan melibatkan orang tua untuk mendukung kedisiplinan.';
        } else {
          return 'Peningkatan pelanggaran terdeteksi. Tingkatkan sosialisasi aturan sekolah dan pertimbangkan untuk mengadakan workshop kedisiplinan untuk siswa.';
        }
      } else {
        if (changePercentage > 20) {
          return 'Penurunan pelanggaran yang sangat baik! Pertahankan sistem pengawasan yang ada dan tambahkan program pembinaan karakter untuk memperkuat kedisiplinan siswa.';
        } else {
          return 'Tren pelanggaran menurun, menunjukkan efektivitas sistem saat ini. Lanjutkan dengan konsistensi dalam penerapan aturan dan pertimbangkan untuk memberikan penghargaan kepada siswa yang disiplin.';
        }
      }
    }
  }
}
