import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skoring/config/api.dart';
import 'package:skoring/models/types/history.dart';

// ─── Constants ────────────────────────────────────────────────────────────────

const _kBlue        = Color(0xFF378ADD);
const _kBlueBg      = Color(0xFFE6F1FB);
const _kBlueDark    = Color(0xFF0C447C);
const _kGreen       = Color(0xFF639922);
const _kGreenBg     = Color(0xFFC0DD97);
const _kGreenDark   = Color(0xFF27500A);
const _kRed         = Color(0xFFE24B4A);
const _kRedBg       = Color(0xFFF7C1C1);
const _kRedDark     = Color(0xFF791F1F);
const _kGray        = Color(0xFF888780);
const _kGrayBg      = Color(0xFFF1EFE8);
const _kSurface     = Color(0xFFF8FAFC);
const _kBorder      = Color(0xFFE5E7EB);
const _kText1       = Color(0xFF111827);
const _kText2       = Color(0xFF6B7280);
const _kText3       = Color(0xFF9CA3AF);

// ─── Screen ───────────────────────────────────────────────────────────────────

class HistoryScreen extends StatefulWidget {
  final Map<String, dynamic> student;
  const HistoryScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<HistoryScreen> createState() => HistoryScreenState();
}

class HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  static const int _academicYearStartMonth = 7;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  // ── Filter state ──────────────────────────────────────────────────────────
  String _typeFilter    = 'Semua';
  String _timeFilter    = 'Semua';
  bool   _onlyNew       = false;
  DateTimeRange? _customRange;

  // ── Data state ────────────────────────────────────────────────────────────
  List<HistoryItem>  allHistory        = [];
  List<dynamic>      aspekPenilaianData = [];
  bool               isLoading         = true;
  String?            errorMessage;

  String nipWalikelas = '';
  String idKelas      = '';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadUserData();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ─── Auth ──────────────────────────────────────────────────────────────────

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('sanctum_token') ?? '';
    return {
      'Accept':        'application/json',
      'Content-Type':  'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Data loading ──────────────────────────────────────────────────────────

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nipWalikelas = prefs.getString('walikelas_id') ?? '';
      idKelas      = prefs.getString('id_kelas')     ?? '';
    });
    if (nipWalikelas.isEmpty || idKelas.isEmpty) {
      setState(() {
        errorMessage = 'Data guru tidak lengkap. Silakan login ulang.';
        isLoading    = false;
      });
      return;
    }
    _fetchAspekPenilaian();
  }

  Future<void> _fetchAspekPenilaian() async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final uri     = Uri.parse('${ApiConfig.baseUrl}/aspekpenilaian?nip=$nipWalikelas&id_kelas=$idKelas');
      final headers = await _authHeaders();
      final res     = await http.get(uri, headers: headers);

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true) {
          setState(() => aspekPenilaianData = json['data']);
          await _fetchHistory(widget.student['nis']);
        } else {
          _setError(json['message'] ?? 'Gagal mengambil aspek penilaian');
        }
      } else if (res.statusCode == 401) {
        _setError('Sesi habis. Silakan login ulang.');
      } else {
        _setError('Gagal mengambil data (${res.statusCode})');
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    }
  }

  Future<void> _fetchHistory(String nis) async {
    setState(() { isLoading = true; errorMessage = null; });
    try {
      final headers = await _authHeaders();

      final penghargaanUri = Uri.parse(
        '${ApiConfig.baseUrl}/skoring_penghargaan?nis=$nis&nip=$nipWalikelas&id_kelas=$idKelas',
      );
      var pelanggaranUri = Uri.parse(
        '${ApiConfig.baseUrl}/skoring_pelanggaran?nis=$nis&nip=$nipWalikelas&id_kelas=$idKelas',
      );

      final penghargaanRes  = await http.get(penghargaanUri,  headers: headers);
      var   pelanggaranRes  = await http.get(pelanggaranUri,  headers: headers);

      if (pelanggaranRes.statusCode == 401 || penghargaanRes.statusCode == 401) {
        _setError('Sesi habis. Silakan login ulang.'); return;
      }

      if (pelanggaranRes.statusCode != 200) {
        pelanggaranUri = Uri.parse(
          '${ApiConfig.baseUrl}/skoring_2pelanggaran?nis=$nis&nip=$nipWalikelas&id_kelas=$idKelas',
        );
        pelanggaranRes = await http.get(pelanggaranUri, headers: headers);
      }

      if (penghargaanRes.statusCode == 200 && pelanggaranRes.statusCode == 200) {
        final penghargaanData = jsonDecode(penghargaanRes.body);
        final pelanggaranData = jsonDecode(pelanggaranRes.body);
        final List<HistoryItem> list = [];

        // Apresiasi
        final apresiasiList =
            (penghargaanData['penilaian']?['data'] as List<dynamic>? ?? [])
                .where((e) => e['nis'].toString() == nis)
                .toList();

        for (final eval in apresiasiList) {
          final aspek = aspekPenilaianData.firstWhere(
            (a) => a['id_aspekpenilaian'].toString() == eval['id_aspekpenilaian'].toString(),
            orElse: () => null,
          );
          if (aspek == null) continue;
          final dt = DateTime.tryParse(eval['created_at'] ?? '') ?? DateTime.now();
          list.add(HistoryItem(
            id:           'apr_${eval['id_penilaian'] ?? dt.millisecondsSinceEpoch}',
            type:         (aspek['kategori'] ?? 'Apresiasi').toString(),
            description:  aspek['uraian']?.toString() ?? 'Apresiasi',
            date:         dt.toIso8601String().substring(0, 10),
            time:         dt.toIso8601String().substring(11, 16),
            points:       ((aspek['indikator_poin'] as num? ?? 0).abs()).toInt(),
            icon:         Icons.star_rounded,
            color:        _kGreen,
            pemberi:      _resolveRole(eval),
            isNew:        DateTime.now().difference(dt).inDays < 7,
            isPelanggaran: false,
            createdAt:    dt,
            pelanggaranKe: aspek['pelanggaran_ke'],
            kategori:     aspek['kategori'] ?? 'Umum',
          ));
        }

        // Pelanggaran
        final pelanggaranList =
            (pelanggaranData['penilaian']?['data'] as List<dynamic>? ?? [])
                .where((e) => e['nis'].toString() == nis)
                .toList();

        for (final eval in pelanggaranList) {
          final aspek = aspekPenilaianData.firstWhere(
            (a) => a['id_aspekpenilaian'].toString() == eval['id_aspekpenilaian'].toString(),
            orElse: () => null,
          );
          if (aspek == null) continue;
          final dt = DateTime.tryParse(eval['created_at'] ?? '') ?? DateTime.now();
          list.add(HistoryItem(
            id:           'pel_${eval['id_penilaian'] ?? dt.millisecondsSinceEpoch}',
            type:         (aspek['kategori'] ?? 'Pelanggaran').toString(),
            description:  aspek['uraian']?.toString() ?? 'Pelanggaran',
            date:         dt.toIso8601String().substring(0, 10),
            time:         dt.toIso8601String().substring(11, 16),
            points:       ((aspek['indikator_poin'] as num? ?? 0).abs()).toInt(),
            icon:         Icons.warning_rounded,
            color:        _kRed,
            pelapor:      _resolveRole(eval),
            isNew:        DateTime.now().difference(dt).inDays < 7,
            isPelanggaran: true,
            createdAt:    dt,
            pelanggaranKe: aspek['pelanggaran_ke'],
            kategori:     aspek['kategori'] ?? 'Umum',
          ));
        }

        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        setState(() { allHistory = list; isLoading = false; });
      } else {
        _setError('Gagal mengambil data dari server');
      }
    } catch (e) {
      _setError('Terjadi kesalahan: $e');
    }
  }

  void _setError(String msg) =>
      setState(() { errorMessage = msg; isLoading = false; });

  String _resolveRole(Map e) =>
      e['nip_wakasek'] != null ? 'Wakasek'
      : e['nip_walikelas'] != null ? 'Walikelas'
      : e['nip_bk'] != null ? 'BK'
      : 'Tidak diketahui';

  Future<void> refreshData() => _fetchAspekPenilaian();

  // ─── Filtering ─────────────────────────────────────────────────────────────

  List<HistoryItem> get _filtered {
    var list = List<HistoryItem>.from(allHistory);

    if (_typeFilter == 'Apresiasi')   list = list.where((i) => !i.isPelanggaran).toList();
    if (_typeFilter == 'Pelanggaran') list = list.where((i) =>  i.isPelanggaran).toList();

    final now   = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _DateRange? range;

    switch (_timeFilter) {
      case 'Minggu ini':
        final start = today.subtract(Duration(days: today.weekday - 1));
        range = _DateRange(start, start.add(const Duration(days: 7)));
        break;
      case 'Bulan ini':
        range = _DateRange(DateTime(today.year, today.month), DateTime(today.year, today.month + 1));
        break;
      case 'Semester':
        final ys = today.month >= _academicYearStartMonth ? today.year : today.year - 1;
        final s1 = DateTime(ys, _academicYearStartMonth);
        final s2 = DateTime(ys + 1, 1);
        final s3 = DateTime(ys + 1, _academicYearStartMonth);
        range = today.isBefore(s2) ? _DateRange(s1, s2) : _DateRange(s2, s3);
        break;
      case 'Tahun ini':
        final ys = today.month >= _academicYearStartMonth ? today.year : today.year - 1;
        range = _DateRange(DateTime(ys, _academicYearStartMonth), DateTime(ys + 1, _academicYearStartMonth));
        break;
      case 'Rentang':
        if (_customRange != null) {
          range = _DateRange(
            DateTime(_customRange!.start.year, _customRange!.start.month, _customRange!.start.day),
            DateTime(_customRange!.end.year, _customRange!.end.month, _customRange!.end.day)
                .add(const Duration(days: 1)),
          );
        }
        break;
    }

    if (range != null) {
      list = list.where((i) =>
          !i.createdAt.isBefore(range!.start) && i.createdAt.isBefore(range.end)
      ).toList();
    }

    if (_onlyNew) list = list.where((i) => i.isNew).toList();
    return list;
  }

  // ─── Stats ─────────────────────────────────────────────────────────────────

  int get _totalPoints {
    int total = 0;
    for (final i in allHistory) {
      total += i.isPelanggaran ? -i.points : i.points;
    }
    return total;
  }

  int get _totalApr => allHistory.where((i) => !i.isPelanggaran).fold(0, (s, i) => s + i.points);
  int get _totalPel => allHistory.where((i) =>  i.isPelanggaran).fold(0, (s, i) => s + i.points);

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: _kSurface,
        body: isLoading
            ? _buildLoading()
            : errorMessage != null
                ? _buildError()
                : FadeTransition(opacity: _fadeAnim, child: _buildContent()),
      ),
    );
  }

  Widget _buildLoading() => const Center(
    child: CircularProgressIndicator(color: _kBlue, strokeWidth: 2),
  );

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off_rounded, size: 48, color: _kText3),
        const SizedBox(height: 16),
        Text(errorMessage!,
            style: GoogleFonts.poppins(fontSize: 14, color: _kText2),
            textAlign: TextAlign.center),
        const SizedBox(height: 20),
        TextButton(
          onPressed: _fetchAspekPenilaian,
          child: Text('Coba lagi', style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w600, color: _kBlue)),
        ),
      ]),
    ),
  );

  Widget _buildContent() {
    final filtered = _filtered;
    final newItems = filtered.where((i) => i.isNew).toList();
    final oldItems = filtered.where((i) => !i.isNew).toList();

    return RefreshIndicator(
      color: _kBlue,
      onRefresh: refreshData,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildHeader(filtered.length)),

          // ── Filters ─────────────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildFilterChips()),

          // ── Active filter banner ─────────────────────────────────────────
          if (_typeFilter != 'Semua' || _timeFilter != 'Semua' || _onlyNew)
            SliverToBoxAdapter(child: _buildActiveBanner()),

          // ── Empty state ──────────────────────────────────────────────────
          if (filtered.isEmpty)
            SliverFillRemaining(child: _buildEmpty()),

          // ── New items ────────────────────────────────────────────────────
          if (newItems.isNotEmpty) ...[
            SliverToBoxAdapter(child: _sectionLabel('Terbaru — 7 hari ini', newItems.length)),
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _buildCard(newItems[i]),
              childCount: newItems.length,
            )),
          ],

          // ── Old items ────────────────────────────────────────────────────
          if (oldItems.isNotEmpty) ...[
            SliverToBoxAdapter(child: _sectionLabel('Sebelumnya', oldItems.length)),
            SliverList(delegate: SliverChildBuilderDelegate(
              (_, i) => _buildCard(oldItems[i]),
              childCount: oldItems.length,
            )),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(int count) {
    final name = widget.student['name']?.toString() ?? '';
    final initials = name.trim().split(' ')
        .take(2).map((w) => w.isNotEmpty ? w[0].toUpperCase() : '').join();
    final net = _totalPoints;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 20, 20, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Title row
        Row(children: [
          // Avatar
          Container(
            width: 40, height: 40,
            decoration: const BoxDecoration(color: _kBlueBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initials,
                style: GoogleFonts.poppins(
                    fontSize: 14, fontWeight: FontWeight.w600, color: _kBlueDark)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name,
                style: GoogleFonts.poppins(
                    fontSize: 15, fontWeight: FontWeight.w600, color: _kText1),
                overflow: TextOverflow.ellipsis),
            Text('Riwayat poin lengkap',
                style: GoogleFonts.poppins(fontSize: 12, color: _kText2)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _kGrayBg, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _kBorder, width: 0.5),
            ),
            child: Text('$count catatan',
                style: GoogleFonts.poppins(
                    fontSize: 12, fontWeight: FontWeight.w500, color: _kGray)),
          ),
        ]),

        const SizedBox(height: 16),

        // Stats row
        Row(children: [
          _statCard('Total poin', net >= 0 ? '+$net' : '$net',
              net >= 0 ? _kBlue : _kRed, net >= 0 ? _kBlueBg : Color(0xFFFCEBEB)),
          const SizedBox(width: 10),
          _statCard('Apresiasi', '+$_totalApr', _kGreen, Color(0xFFEAF3DE)),
          const SizedBox(width: 10),
          _statCard('Pelanggaran', '−$_totalPel', _kRed, Color(0xFFFCEBEB)),
        ]),
      ]),
    );
  }

  Widget _statCard(String label, String val, Color valColor, Color bg) =>
      Expanded(child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: _kText2)),
          const SizedBox(height: 4),
          Text(val, style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w600, color: valColor)),
        ]),
      ));

  // ─── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Divider(height: 1, thickness: 0.5, color: _kBorder),
        // Type row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Row(children: [
            for (final f in ['Semua', 'Apresiasi', 'Pelanggaran'])
              _chip(f, _typeFilter == f, () => setState(() => _typeFilter = f)),
          ]),
        ),
        // Time row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Row(children: [
            for (final f in ['Semua', 'Minggu ini', 'Bulan ini', 'Semester', 'Tahun ini', 'Rentang'])
              _chip(f, _timeFilter == f, () async {
                if (f == 'Rentang') {
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 1, 12, 31),
                    initialDateRange: _customRange ??
                        DateTimeRange(start: DateTime(now.year, now.month), end: now),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(primary: _kBlue),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) setState(() { _customRange = picked; _timeFilter = 'Rentang'; });
                } else {
                  setState(() => _timeFilter = f);
                }
              }),
            // Only new toggle
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () => setState(() => _onlyNew = !_onlyNew),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _onlyNew ? const Color(0xFFEAF3DE) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _onlyNew ? _kGreen : _kBorder, width: 0.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.fiber_new_rounded,
                      size: 14, color: _onlyNew ? _kGreen : _kText3),
                  const SizedBox(width: 4),
                  Text('Baru saja',
                      style: GoogleFonts.poppins(
                          fontSize: 12, fontWeight: FontWeight.w500,
                          color: _onlyNew ? _kGreenDark : _kText2)),
                ]),
              ),
            ),
          ]),
        ),
        const Divider(height: 1, thickness: 0.5, color: _kBorder),
      ]),
    );
  }

  Widget _chip(String label, bool active, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.only(right: 6),
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kText1 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: active ? _kText1 : _kBorder, width: 0.5),
        ),
        child: Text(label,
            style: GoogleFonts.poppins(
                fontSize: 12, fontWeight: FontWeight.w500,
                color: active ? Colors.white : _kText2)),
      ),
    ),
  );

  // ─── Active filter banner ──────────────────────────────────────────────────

  Widget _buildActiveBanner() => Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: _kBlueBg,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _kBlue.withOpacity(0.3), width: 0.5),
    ),
    child: Row(children: [
      const Icon(Icons.filter_alt_outlined, size: 14, color: _kBlue),
      const SizedBox(width: 8),
      Expanded(child: Text(
        [
          if (_typeFilter != 'Semua') _typeFilter,
          if (_timeFilter != 'Semua')
            _timeFilter == 'Rentang' && _customRange != null
                ? '${_fmt(_customRange!.start)} – ${_fmt(_customRange!.end)}'
                : _timeFilter,
          if (_onlyNew) 'Baru saja',
        ].join(' · '),
        style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: _kBlueDark),
      )),
      GestureDetector(
        onTap: () => setState(() {
          _typeFilter = 'Semua'; _timeFilter = 'Semua'; _onlyNew = false;
        }),
        child: const Icon(Icons.close, size: 14, color: _kBlue),
      ),
    ]),
  );

  // ─── Section label ─────────────────────────────────────────────────────────

  Widget _sectionLabel(String title, int count) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
    child: Row(children: [
      Text(title.toUpperCase(),
          style: GoogleFonts.poppins(
              fontSize: 11, fontWeight: FontWeight.w600,
              color: _kText3, letterSpacing: 0.4)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: _kGrayBg, borderRadius: BorderRadius.circular(20)),
        child: Text('$count',
            style: GoogleFonts.poppins(
                fontSize: 11, fontWeight: FontWeight.w600, color: _kGray)),
      ),
    ]),
  );

  // ─── History card ──────────────────────────────────────────────────────────

  Widget _buildCard(HistoryItem item) {
    final isApr  = !item.isPelanggaran;
    final ptColor  = isApr ? _kGreen  : _kRed;
    final ptBg     = isApr ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB);
    final ptDark   = isApr ? _kGreenDark : _kRedDark;
    final ptBadge  = isApr ? _kGreenBg   : _kRedBg;
    final iconBg   = isApr ? const Color(0xFFEAF3DE) : const Color(0xFFFCEBEB);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Icon
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(item.icon, size: 18, color: ptColor),
          ),
          const SizedBox(width: 12),

          // Body
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Badges row
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: ptBadge, borderRadius: BorderRadius.circular(20)),
                child: Text(item.kategori,
                    style: GoogleFonts.poppins(
                        fontSize: 10, fontWeight: FontWeight.w600, color: ptDark)),
              ),
              if (item.isNew) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: _kBlueBg, borderRadius: BorderRadius.circular(20)),
                  child: Text('Baru',
                      style: GoogleFonts.poppins(
                          fontSize: 10, fontWeight: FontWeight.w600, color: _kBlueDark)),
                ),
              ],
            ]),
            const SizedBox(height: 5),

            // Description
            Text(item.description,
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w600, color: _kText1),
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),

            // Meta
            Text(
              isApr
                  ? 'Oleh: ${item.pemberi ?? "—"}'
                  : 'Pelapor: ${item.pelapor ?? "—"}',
              style: GoogleFonts.poppins(fontSize: 11, color: _kText2),
            ),
            if (item.isPelanggaran && item.pelanggaranKe != null) ...[
              const SizedBox(height: 2),
              Text('Pelanggaran ke: ${item.pelanggaranKe}',
                  style: GoogleFonts.poppins(fontSize: 11, color: _kText2)),
            ],
          ])),

          const SizedBox(width: 12),

          // Right column
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: ptBg, borderRadius: BorderRadius.circular(8)),
              child: Text(
                isApr ? '+${item.points}' : '−${item.points}',
                style: GoogleFonts.poppins(
                    fontSize: 13, fontWeight: FontWeight.w700, color: ptColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(item.date,
                style: GoogleFonts.poppins(fontSize: 11, color: _kText3)),
            const SizedBox(height: 2),
            Text(item.time,
                style: GoogleFonts.poppins(fontSize: 11, color: _kText3)),
          ]),
        ]),
      ),
    );
  }

  // ─── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty() => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 64, height: 64,
        decoration: const BoxDecoration(color: _kGrayBg, shape: BoxShape.circle),
        child: const Icon(Icons.inbox_rounded, size: 30, color: _kText3),
      ),
      const SizedBox(height: 16),
      Text('Tidak ada data',
          style: GoogleFonts.poppins(
              fontSize: 15, fontWeight: FontWeight.w600, color: _kText2)),
      const SizedBox(height: 6),
      Text('Coba ubah atau hapus filter aktif',
          style: GoogleFonts.poppins(fontSize: 13, color: _kText3)),
      const SizedBox(height: 20),
      if (_typeFilter != 'Semua' || _timeFilter != 'Semua' || _onlyNew)
        TextButton(
          onPressed: () => setState(() {
            _typeFilter = 'Semua'; _timeFilter = 'Semua'; _onlyNew = false;
          }),
          child: Text('Hapus semua filter',
              style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: FontWeight.w600, color: _kBlue)),
        ),
    ]),
  );

  // ─── Helpers ───────────────────────────────────────────────────────────────

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
}

// ─── Internal types ───────────────────────────────────────────────────────────

class _DateRange {
  final DateTime start;
  final DateTime end;
  const _DateRange(this.start, this.end);
}