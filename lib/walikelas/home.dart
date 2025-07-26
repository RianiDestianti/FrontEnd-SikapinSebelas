import 'package:flutter/material.dart';
import '../navigation/walikelas.dart';
import 'siswa.dart';
import 'laporan.dart'; // Tambahkan import untuk laporan jika ada file terpisah

class WalikelasMainScreen extends StatefulWidget {
  const WalikelasMainScreen({Key? key}) : super(key: key);

  @override
  State<WalikelasMainScreen> createState() => _WalikelasMainScreenState();
}

class _WalikelasMainScreenState extends State<WalikelasMainScreen> {
  int _currentIndex = 0;

  // Gunakan class yang diimport dari file terpisah
  final List<Widget> _screens = [
    const HomeScreen(),
    const SiswaScreen(), // Ini akan menggunakan yang dari siswa.dart
    const LaporanScreen(),
  ];

  void _onNavigationTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _screens[_currentIndex],
      bottomNavigationBar: WalikelasNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }
}

// Hanya tinggalkan HomeScreen di sini, hapus SiswaScreen yang duplikat
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF357ABD)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    children: [
                      // Top Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            child: Stack(
                              children: [
                                Container(width: 18, height: 2, color: Colors.white),
                                Positioned(top: 6, child: Container(width: 18, height: 2, color: Colors.white)),
                                Positioned(top: 12, child: Container(width: 18, height: 2, color: Colors.white)),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.notifications_outlined, color: Colors.blue, size: 20),
                              ),
                              SizedBox(width: 8),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(Icons.person, color: Colors.blue, size: 20),
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      
                      // Greeting
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Mam Euis!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Selamat Hari menyenangkan',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      
                      // Search Bar
                      Container(
                        height: 44,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Color(0xFF9CA3AF), size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Search',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Action Buttons
                      Row(
                        children: [
                          _buildActionButton('Umum', true),
                          SizedBox(width: 8),
                          _buildActionButton('Absen', false),
                          SizedBox(width: 8),
                          _buildActionButton('Penilaian', false),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Content Section
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  children: [
                    // Chart 1 - Grafik Apresiasi Siswa
                    _buildChartCard(
                      'Grafik Apresiasi Siswa',
                      'Apresiasi minggu ini',
                      _buildBarChart([
                        {'value': 80.0, 'label': 'Sen'},
                        {'value': 120.0, 'label': 'Sel'},
                        {'value': 90.0, 'label': 'Rab'},
                        {'value': 40.0, 'label': 'Kam'},
                        {'value': 100.0, 'label': 'Jum'},
                      ], Color(0xFF4A90E2)),
                      'Minggu',
                      'Bulan',
                      true,
                    ),
                    SizedBox(height: 16),
                    
                    // Chart 2 - Grafik Pelanggaran Siswa
                    _buildChartCard(
                      'Grafik Pelanggaran Siswa',
                      'Pelanggaran minggu ini',
                      _buildBarChart([
                        {'value': 60.0, 'label': 'Sen'},
                        {'value': 25.0, 'label': 'Sel'},
                        {'value': 15.0, 'label': 'Rab'},
                        {'value': 10.0, 'label': 'Kam'},
                        {'value': 20.0, 'label': 'Jum'},
                      ], Color(0xFFE74C3C)),
                      'Minggu',
                      'Bulan',
                      false,
                    ),
                    SizedBox(height: 16),
                    
                    // Activities Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aktivitas Terkini',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          _buildActivityItem(
                            Icons.description,
                            Color(0xFF4A90E2),
                            'Laporan Bulanan',
                            'Laporan lengkap',
                            '10.30',
                          ),
                          SizedBox(height: 12),
                          
                          _buildActivityItem(
                            Icons.check_circle,
                            Color(0xFF10B981),
                            'Poin Apresiasi',
                            'Poin apresiasi telah ditambahkan kepada 3 murid',
                            '08.30',
                          ),
                          SizedBox(height: 12),
                          
                          _buildActivityItem(
                            Icons.warning,
                            Color(0xFFEA580C),
                            'Pelanggaran',
                            'Ada 3 siswa',
                            '06.30',
                          ),
                        ],
                      ),
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

  Widget _buildActionButton(String text, bool isActive) {
    return Expanded(
      child: Container(
        height: 32,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isActive ? Color(0xFF4A90E2) : Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, String subtitle, Widget chart, String button1, String button2, bool isFirst) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildChartButton(button1, isFirst),
                  SizedBox(width: 6),
                  _buildChartButton(button2, !isFirst),
                ],
              ),
            ],
          ),
          SizedBox(height: 20),
          chart,
        ],
      ),
    );
  }

  Widget _buildChartButton(String text, bool isActive) {
    return Container(
      height: 24,
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isActive ? Color(0xFF4A90E2) : Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> data, Color color) {
    double maxValue = data.map((e) => e['value'] as double).reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 140,
      child: Column(
        children: [
          // Y-axis labels
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Y-axis
                Container(
                  width: 24,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${maxValue.toInt()}', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      Text('${(maxValue * 0.75).toInt()}', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      Text('${(maxValue * 0.5).toInt()}', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      Text('${(maxValue * 0.25).toInt()}', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                      Text('0', style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF))),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                // Bars
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: data.map((item) {
                      double value = item['value'];
                      double height = (value / maxValue) * 100;
                      return Container(
                        width: 18,
                        height: height,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          // X-axis labels
          Row(
            children: [
              SizedBox(width: 32),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: data.map((item) {
                    return Text(
                      item['label'],
                      style: TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
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

  Widget _buildActivityItem(IconData icon, Color iconColor, String title, String subtitle, String time) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Text(
          time,
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// Buat file terpisah untuk LaporanScreen atau definisikan di sini
class LaporanScreen extends StatelessWidget {
  const LaporanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Laporan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              'Laporan dan evaluasi siswa',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}