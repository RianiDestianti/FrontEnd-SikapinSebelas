import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skoring/models/api/api_detail.dart';
import 'point.dart';
import 'note.dart';
import 'history.dart';
import 'services/student_detail_service.dart';
import 'services/penanganan_service.dart';
import 'utils/detail_colors.dart';
import 'utils/point_detail_utils.dart';
import 'widgets/biodata_row.dart';
import 'widgets/history_card.dart';
import 'widgets/akumulasi_card.dart';
import 'widgets/empty_detail_state.dart';
import 'widgets/student_profile_headers.dart';
import 'widgets/penanganan_card.dart';

class DetailScreen extends StatefulWidget {
  final Map student;
  const DetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<DetailScreen> createState() => DetailScreenState();
}

class DetailScreenState extends State<DetailScreen> with TickerProviderStateMixin {
  static const int _maxPreview = 5;

  late AnimationController _headerCtrl;
  late AnimationController _contentCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _contentFade;

  int _tab = 0;

  // Search state
  String _penangananSearchQuery = '';
  final TextEditingController _penangananSearchController = TextEditingController();

  late Student _student;
  bool _loadingStudent = true;
  String? _errorStudent;

  List<ViolationHistory> _violations = [];
  List<AppreciationHistory> _appreciations = [];
  AccumulationHistory? _accumulation;

  bool _loadingViolations = true;
  bool _loadingAppreciations = true;
  String? _errorViolations;
  String? _errorAppreciations;

  List<PenangananItem> _penanganans = [];
  bool _loadingPenanganans = true;
  String? _errorPenanganans;

  StudentService? _service;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _load();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _contentCtrl.dispose();
    _penangananSearchController.dispose();
    super.dispose();
  }

  void _initAnimations() {
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 480));
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 380));

    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _contentFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeIn);

    _headerCtrl.forward();
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) _contentCtrl.forward();
    });
  }

  Future<void> _load() async {
    setState(() {
      _errorStudent = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final nip = prefs.getString('walikelas_id') ?? '';
    final idKelas = prefs.getString('id_kelas') ?? '';

    if (nip.isEmpty || idKelas.isEmpty) {
      setState(() {
        _errorStudent = 'Data guru tidak lengkap. Silakan login ulang.';
        _loadingStudent = false;
      });
      return;
    }

    _service = StudentService(nipWalikelas: nip, idKelas: idKelas);

    try {
      final aspek = await _service!.fetchAspekPenilaian();
      _buildStudent(aspek);
    } catch (e) {
      if (mounted) setState(() { _errorStudent = e.toString(); _loadingStudent = false; });
    }
  }

  void _buildStudent(List<dynamic> aspek) {
    setState(() { _loadingStudent = true; _errorStudent = null; });
    try {
      final d = widget.student;
      final total = int.tryParse(d['points']?.toString() ?? '') ?? 0;

      _student = Student(
        name: d['name'] ?? 'Unknown',
        nis: d['nis'] ?? '0',
        programKeahlian: d['programKeahlian'] ?? d['kelas'] ?? 'Unknown',
        kelas: d['kelas'] ?? 'Unknown',
        poinApresiasi: d['poinApresiasi'] ?? 0,
        poinPelanggaran: (d['poinPelanggaran'] ?? 0).abs(),
        poinTotal: total,
        spLevel: DetailPointUtils.resolveSpLevel((d['spLevel'] ?? d['sp_level'])?.toString(), total),
        phLevel: DetailPointUtils.resolvePhLevel((d['phLevel'] ?? d['ph_level'])?.toString(), total),
      );

      setState(() => _loadingStudent = false);
      _fetchHistory(aspek);
    } catch (e) {
      setState(() { _errorStudent = 'Gagal memuat detail siswa: $e'; _loadingStudent = false; });
    }
  }

  Future<void> _fetchHistory(List<dynamic> aspek) async {
    final nis = widget.student['nis']?.toString() ?? '';
    await Future.wait([
      _fetchViolations(nis, aspek),
      _fetchAppreciations(nis, aspek),
      _fetchPenanganans(),
    ]);
  }

  Future<void> _fetchViolations(String nis, List<dynamic> aspek) async {
    setState(() { _loadingViolations = true; _errorViolations = null; });
    try {
      final result = await _service!.fetchViolations(nis: nis, aspek: aspek);
      if (mounted) {
        setState(() { _violations = result; _loadingViolations = false; });
        _recalc();
      }
    } catch (e) {
      if (mounted) setState(() { _errorViolations = e.toString(); _loadingViolations = false; });
    }
  }

  Future<void> _fetchAppreciations(String nis, List<dynamic> aspek) async {
    setState(() { _loadingAppreciations = true; _errorAppreciations = null; });
    try {
      final result = await _service!.fetchAppreciations(nis: nis, aspek: aspek);
      if (mounted) {
        setState(() { _appreciations = result; _loadingAppreciations = false; });
        _recalc();
      }
    } catch (e) {
      if (mounted) setState(() { _errorAppreciations = e.toString(); _loadingAppreciations = false; });
    }
  }

  void _recalc() {
    setState(() {
      _accumulation = StudentService.buildAccumulation(_appreciations, _violations);
    });
  }

  Future<void> _fetchPenanganans() async {
    final nis = widget.student['nis']?.toString() ?? '';
    if (nis.isEmpty) return;

    setState(() { _loadingPenanganans = true; _errorPenanganans = null; });

    try {
      final result = await PenangananService.fetchPenanganan(nis);
      if (mounted) {
        setState(() { _penanganans = result; _loadingPenanganans = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _errorPenanganans = e.toString(); _loadingPenanganans = false; });
    }
  }

  Future<void> _refreshPenanganans() async {
    setState(() { _loadingPenanganans = true; _errorPenanganans = null; });
    await _fetchPenanganans();
  }

  void _deletePenanganan(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Hapus Penanganan', style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
        content: Text('Apakah Anda yakin ingin menghapus penanganan ini?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: GoogleFonts.poppins(color: const Color(0xFF6B7280))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: Text('Hapus', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PenangananService.deletePenanganan(id: id, context: context);
      if (success) {
        _refreshPenanganans();
      }
    }
  }

  void _editPenanganan(Map<String, dynamic> penanganan) {
    showEditPenangananPopup(
      context,
      _student.name,
      _student.nis,
      _student.kelas,
      penanganan,
      _refreshPenanganans,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _loadingStudent = true;
      _loadingViolations = true;
      _loadingAppreciations = true;
      _loadingPenanganans = true;

      _errorStudent = null;
      _errorViolations = null;
      _errorAppreciations = null;
      _errorPenanganans = null;
    });

    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingStudent) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorStudent != null && !_loadingStudent) {
      return _errorScreen(_errorStudent!);
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxW = constraints.maxWidth > 600 ? 600.0 : constraints.maxWidth;
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _gradientHeader()),
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _contentFade,
                          child: Column(children: [
                            _biodataCard(),
                            _tabBar(),
                            _tabContent(),
                            const SizedBox(height: 32),
                          ]),
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

  Widget _gradientHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryLight, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 32),
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 16),
            StudentProfileHeader(
              name: _student.name,
              kelas: _student.kelas,
              programKeahlian: _student.programKeahlian,
              onBeriPoin: () async {
                final success = await showPointPopup(context, _student.name, _student.nis, _student.kelas);
                if (success == true) {
                  _refresh();
                }
              },
              onPenanganan: () async {
                final success = await showAddPenangananPopup(context, _student.name, _student.nis, _student.kelas);
                if (success == true) {
                  _refresh();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _biodataCard() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Biodata Siswa',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            BiodataRow(label: 'NIS', value: _student.nis, icon: Icons.badge_rounded),
            BiodataRow(label: 'Program Keahlian', value: _student.programKeahlian, icon: Icons.school_rounded),
            BiodataRow(label: 'Kelas', value: _student.kelas, icon: Icons.class_rounded),
            BiodataRow(label: 'Poin Apresiasi', value: '+${_student.poinApresiasi}', icon: Icons.star_rounded),
            BiodataRow(label: 'Poin Pelanggaran', value: '-${_student.poinPelanggaran.abs()}', icon: Icons.warning_rounded),
            BiodataRow(label: 'Poin Total', value: DetailPointUtils.signed(_student.poinTotal), icon: Icons.calculate_rounded),
            BiodataRow(label: 'Status SP', value: _student.spLevel, icon: Icons.report_rounded),
            BiodataRow(label: 'Status PH', value: _student.phLevel, icon: Icons.emoji_events_rounded),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isCompact = screenWidth < 360;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(4),
          child: Row(children: [
            _tabBtn(isCompact ? 'Pelanggaran' : 'Pelanggaran', 0, Icons.warning_rounded, isCompact),
            _tabBtn(isCompact ? 'Apresiasi' : 'Apresiasi', 1, Icons.star_rounded, isCompact),
            _tabBtn(isCompact ? 'Akumulasi' : 'Akumulasi', 2, Icons.calculate_rounded, isCompact),
            _tabBtn(isCompact ? 'Penanganan' : 'Penanganan', 3, Icons.assignment_rounded, isCompact),
          ]),
        ),
      ),
    );
  }

  Widget _tabBtn(String label, int index, IconData icon, bool isCompact) {
    final active = _tab == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: () => setState(() => _tab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : AppColors.textMuted),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: GoogleFonts.poppins(
                  color: active ? Colors.white : AppColors.textMuted,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 12,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(anim),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_tab),
          child: switch (_tab) {
            0 => _violationsTab(),
            1 => _appreciationsTab(),
            2 => _accumulationTab(),
            3 => _penangananTab(),
            _ => _violationsTab(),
          },
        ),
      ),
    );
  }

  Widget _violationsTab() {
    final shown = _violations.take(_maxPreview).toList();
    return _tabShell(
      title: 'Histori Poin Pelanggaran',
      loading: _loadingViolations,
      error: _errorViolations,
      emptyMsg: 'Belum ada riwayat pelanggaran',
      emptyIcon: Icons.warning_rounded,
      isEmpty: _violations.isEmpty,
      children: [
        ...shown.map((v) => HistoryCard(
              type: v.type, description: v.description, kategori: v.kategori,
              date: v.date, time: v.time, points: v.points,
              icon: v.icon, color: v.color, isPelanggaran: true, onTap: _goHistory,
            )),
        if (_violations.length > _maxPreview) _seeAllBtn(),
      ],
    );
  }

  Widget _appreciationsTab() {
    final shown = _appreciations.take(_maxPreview).toList();
    return _tabShell(
      title: 'Histori Poin Apresiasi',
      loading: _loadingAppreciations,
      error: _errorAppreciations,
      emptyMsg: 'Belum ada riwayat apresiasi',
      emptyIcon: Icons.star_rounded,
      isEmpty: _appreciations.isEmpty,
      children: [
        ...shown.map((a) => HistoryCard(
              type: a.type, description: a.description, kategori: a.kategori,
              date: a.date, time: a.time, points: a.points,
              icon: a.icon, color: a.color, isPelanggaran: false, onTap: _goHistory,
            )),
        if (_appreciations.length > _maxPreview) _seeAllBtn(),
      ],
    );
  }

  Widget _accumulationTab() {
    return _tabShell(
      title: 'Histori Akumulasi Poin',
      loading: _loadingViolations || _loadingAppreciations,
      error: _errorViolations ?? _errorAppreciations,
      emptyMsg: 'Belum ada riwayat akumulasi',
      emptyIcon: Icons.calculate_rounded,
      isEmpty: _accumulation == null,
      children: [
        if (_accumulation != null) AkumulasiCard(item: _accumulation!),
      ],
    );
  }

Widget _penangananTab() {
    final filteredPenanganans = _penanganans.where((p) {
      if (_penangananSearchQuery.isEmpty) return true;
      final query = _penangananSearchQuery.toLowerCase();
      return p.namaIntervensi.toLowerCase().contains(query) ||
          p.isiIntervensi.toLowerCase().contains(query) ||
          p.status.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Riwayat Penanganan',
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        // Search Bar
Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: _penangananSearchController,
            onChanged: (value) => setState(() => _penangananSearchQuery = value),
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Cari penanganan...',
              hintStyle: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
              suffixIcon: _penangananSearchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.textMuted),
                      onPressed: () {
                        _penangananSearchController.clear();
                        setState(() => _penangananSearchQuery = '');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_loadingPenanganans)
          const _Spinner()
        else if (_errorPenanganans != null)
          Center(child: EmptyState(message: _errorPenanganans!, icon: Icons.error_outline_rounded))
        else if (_penanganans.isEmpty)
          Center(child: EmptyState(message: 'Belum ada penanganan untuk siswa ini', icon: Icons.assignment_outlined))
        else if (filteredPenanganans.isEmpty)
          Center(child: EmptyState(message: 'Tidak ada hasil untuk "$_penangananSearchQuery"', icon: Icons.search_off_rounded))
        else
          ...filteredPenanganans.map((p) => PenangananCard(
            penanganan: p.toJson(),
            onEdit: () => _editPenanganan(p.toJson()),
            onDelete: () => _deletePenanganan(p.id),
          )),
      ],
    );
  }

  Widget _tabShell({
    required String title,
    required bool loading,
    required String? error,
    required String emptyMsg,
    required IconData emptyIcon,
    required bool isEmpty,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: GoogleFonts.poppins(
                fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 14),
        if (loading)
          const _Spinner()
        else if (error != null)
          EmptyState(message: error, icon: Icons.error_outline_rounded)
        else if (isEmpty)
          EmptyState(message: emptyMsg, icon: emptyIcon)
        else
          ...children,
      ],
    );
  }

  Widget _seeAllBtn() => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _goHistory,
            icon: const Icon(Icons.history_rounded, color: AppColors.primary),
            label: Text('Lihat semua riwayat',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.primary)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      );

  void _goHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryScreen(student: Map<String, dynamic>.from(widget.student)),
      ),
    );
  }

  Widget _errorScreen(String msg) => Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 36),
                ),
                const SizedBox(height: 20),
                Text(msg, textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text('Coba Lagi', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _Spinner extends StatelessWidget {
  const _Spinner();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
}
