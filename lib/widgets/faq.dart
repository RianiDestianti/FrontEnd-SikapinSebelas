import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FaqWidget extends StatelessWidget {
  final Map<String, Map<String, dynamic>> faqData;
  final Map<String, bool> expandedSections;
  final String searchQuery;
  final Function(String, bool) onExpansionChanged;

  const FaqWidget({
    Key? key,
    required this.faqData,
    required this.expandedSections,
    required this.searchQuery,
    required this.onExpansionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredFaqData = _filterFaqData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filteredFaqData.isEmpty && searchQuery.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Tidak ada aturan ditemukan',
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Coba ubah kata kunci pencarian',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else ...[
          if (searchQuery.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF0083EE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF0083EE).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: const Color(0xFF0083EE), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Menampilkan ${filteredFaqData.length} hasil untuk "$searchQuery"',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF0083EE),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          _buildSectionTitle('Lembar 1 – Penghargaan dan Apresiasi'),
          ...filteredFaqData.entries
              .where((entry) => entry.key.startsWith('R'))
              .map((entry) => _buildFaqSection(
                    entry.key,
                    entry.value['title'],
                    (entry.value['items'] as List<Map<String, dynamic>>)
                        .map((item) => _buildFaqItem(item['text'], item['points']))
                        .toList(),
                  )),
          const SizedBox(height: 24),
          _buildSectionTitle('Lembar 2 – Pelanggaran dan Sanksi'),
          ...filteredFaqData.entries
              .where((entry) => entry.key.startsWith('P') || entry.key == 'Sanksi')
              .map((entry) => _buildFaqSection(
                    entry.key,
                    entry.value['title'],
                    (entry.value['items'] as List<Map<String, dynamic>>)
                        .map((item) => _buildFaqItem(item['text'], item['points']))
                        .toList(),
                  )),
          const SizedBox(height: 16),
          if (searchQuery.isEmpty) ...[
            Text(
              'Ketentuan Konversi Skor Penghargaan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Skor penghargaan dapat dikonversi ke bentuk sertifikat, hadiah, atau gelar Anugerah Waluya Utama sesuai ketentuan sekolah.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Map<String, Map<String, dynamic>> _filterFaqData() {
    if (searchQuery.isEmpty) {
      return faqData;
    }

    Map<String, Map<String, dynamic>> filtered = {};
    String searchLower = searchQuery.toLowerCase();

    faqData.forEach((key, section) {
      bool titleMatches = section['title'].toString().toLowerCase().contains(searchLower);
      
      List<Map<String, dynamic>> matchingItems = [];
      for (var item in section['items']) {
        if (item['text'].toString().toLowerCase().contains(searchLower) ||
            item['points'].toString().toLowerCase().contains(searchLower)) {
          matchingItems.add(item);
        }
      }

      if (titleMatches || matchingItems.isNotEmpty) {
        filtered[key] = {
          'title': section['title'],
          'items': titleMatches ? section['items'] : matchingItems,
        };
      }
    });

    return filtered;
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildFaqSection(String code, String title, List<Widget> items) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: expandedSections[code] ?? false,
        onExpansionChanged: (expanded) => onExpansionChanged(code, expanded),
        title: RichText(
          text: TextSpan(
            children: _highlightSearchText(
              '$code – $title',
              searchQuery,
              GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
        ),
        iconColor: const Color(0xFF0083EE),
        collapsedIconColor: const Color(0xFF6B7280),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(children: items),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                children: _highlightSearchText(
                  question,
                  searchQuery,
                  GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RichText(
              text: TextSpan(
                children: _highlightSearchText(
                  answer,
                  searchQuery,
                  GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF10B981),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _highlightSearchText(String text, String searchQuery, TextStyle baseStyle) {
    if (searchQuery.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    List<TextSpan> spans = [];
    String lowerText = text.toLowerCase();
    String lowerQuery = searchQuery.toLowerCase();
    
    int start = 0;
    int index = lowerText.indexOf(lowerQuery);
    
    while (index != -1) {
      if (index > start) {
        spans.add(TextSpan(
          text: text.substring(start, index),
          style: baseStyle,
        ));
      }
      
      spans.add(TextSpan(
        text: text.substring(index, index + searchQuery.length),
        style: baseStyle.copyWith(
          backgroundColor: const Color(0xFFFFEB3B).withOpacity(0.3),
          fontWeight: FontWeight.w700,
        ),
      ));
      
      start = index + searchQuery.length;
      index = lowerText.indexOf(lowerQuery, start);
    }
    
    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: baseStyle,
      ));
    }
    
    return spans;
  }
}