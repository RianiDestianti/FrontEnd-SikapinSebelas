// widgets/activity_app_bar.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActivityAppBar extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedFilter;
  final List<String> filterOptions;
  final DateTime? selectedDate;
  final VoidCallback onDateTap;
  final VoidCallback onClearDate;
  final ValueChanged<String?> onFilterChanged;

  const ActivityAppBar({
    Key? key,
    required this.searchController,
    required this.selectedFilter,
    required this.filterOptions,
    required this.selectedDate,
    required this.onDateTap,
    required this.onClearDate,
    required this.onFilterChanged,
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
        boxShadow: [
          BoxShadow(color: Color(0x200083EE), blurRadius: 20, offset: Offset(0, 10)),
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
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildFilterRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
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
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Aktivitas Terkini', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              Text('Riwayat semua aktivitas sistem', style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w400)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.history, color: Colors.white, size: 24),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF61B8FF), Color(0xFF0083EE)]), borderRadius: BorderRadius.all(Radius.circular(30))),
            child: const Icon(Icons.search, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari aktivitas...',
                hintStyle: GoogleFonts.poppins(color: const Color(0xFF9CA3AF), fontSize: 15, fontWeight: FontWeight.w400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              style: GoogleFonts.poppins(fontSize: 15, color: const Color(0xFF1F2937)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(child: _buildFilterDropdown()),
        const SizedBox(width: 12),
        _buildDateButton(),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedFilter,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280)),
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF1F2937)),
          items: filterOptions.map((value) {
            return DropdownMenuItem(
              value: value,
              child: Row(
                children: [
                  Icon(
                    value == 'Semua'
                        ? Icons.all_inclusive
                        : value == 'Pencarian'
                            ? Icons.search
                            : value == 'Navigasi'
                                ? Icons.navigation_outlined
                                : Icons.settings_outlined,
                    size: 18,
                    color: const Color(0xFF0083EE),
                  ),
                  const SizedBox(width: 8),
                  Text(value),
                ],
              ),
            );
          }).toList(),
          onChanged: onFilterChanged,
        ),
      ),
    );
  }

  Widget _buildDateButton() {
    final bool hasDate = selectedDate != null;
    return GestureDetector(
      onTap: onDateTap,
      child: Container(
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hasDate ? const Color(0xFF0083EE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: hasDate ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Text(
              hasDate ? _formatDate(selectedDate!) : 'Tanggal',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: hasDate ? Colors.white : const Color(0xFF6B7280)),
            ),
            if (hasDate) ...[
              const SizedBox(width: 8),
              GestureDetector(onTap: onClearDate, child: Icon(Icons.close, size: 16, color: Colors.white.withOpacity(0.8))),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    final isYesterday = date.year == now.subtract(const Duration(days: 1)).year &&
        date.month == now.subtract(const Duration(days: 1)).month &&
        date.day == now.subtract(const Duration(days: 1)).day;

    if (isToday) return 'Hari ini';
    if (isYesterday) return 'Kemarin';

    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}