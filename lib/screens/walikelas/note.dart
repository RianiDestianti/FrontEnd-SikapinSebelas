import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skoring/config/api.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

class Penanganan {
  final String nis;
  final String namaIntervensi;
  final String isiIntervensi;
  final String status;
  final String tanggalMulai;
  final String tanggalSelesai;

  Penanganan({
    required this.nis,
    required this.namaIntervensi,
    required this.isiIntervensi,
    required this.status,
    required this.tanggalMulai,
    required this.tanggalSelesai,
  });
}

// ─── Utils ────────────────────────────────────────────────────────────────────

class PenangananUtils {
  static const List<String> statusOptions = [
    'Binaan Khusus',
    'Dalam Binaan',
    'Selesai',
  ];

  static Future<Penanganan?> submitPenanganan({
    required String nis,
    required String namaIntervensi,
    required String isiIntervensi,
    required String status,
    required String tanggalMulai,
    required String tanggalSelesai,
    required BuildContext context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Debug: dump ALL saved keys so we can find the right one
      final allKeys = prefs.getKeys();
      debugPrint('[AddPenanganan] SharedPrefs keys: $allKeys');
      for (final k in allKeys) {
        debugPrint('[AddPenanganan]   $k = ${prefs.get(k)}');
      }

      // Try multiple possible key names used by login flow
      final nip = prefs.getString('walikelas_id')
          ?? prefs.getString('nip_walikelas')
          ?? prefs.getString('nip')
          ?? '';
      final idKelas = prefs.getString('id_kelas')
          ?? prefs.getString('kelas_id')
          ?? '';

      debugPrint('[AddPenanganan] resolved nip=$nip  id_kelas=$idKelas');

      if (nip.isEmpty || idKelas.isEmpty) {
        debugPrint('[AddPenanganan] ABORT: nip or id_kelas is empty');
        if (context.mounted) {
          _showSnackBar(
            context,
            'Data sesi tidak lengkap (nip: ${nip.isEmpty ? "kosong" : "ok"}, '
            'kelas: ${idKelas.isEmpty ? "kosong" : "ok"}). Silakan login ulang.',
            isError: true,
          );
        }
        return null;
      }

      final url = Uri.parse(
        '${ApiConfig.baseUrl}/addpenanganan/$nis?nip=$nip&id_kelas=$idKelas',
      );

      debugPrint('[AddPenanganan] POST $url');
      debugPrint('[AddPenanganan] body: ${{
        "nama_intervensi": namaIntervensi,
        "isi_intervensi": isiIntervensi,
        "status": status,
        "tanggal_Mulai_Perbaikan": tanggalMulai,
        "tanggal_Selesai_Perbaikan": tanggalSelesai,
      }}');

      final token = prefs.getString('sanctum_token') ?? '';

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nama_intervensi': namaIntervensi,
          'isi_intervensi': isiIntervensi,
          'status': status,
          'tanggal_Mulai_Perbaikan': tanggalMulai,
          'tanggal_Selesai_Perbaikan': tanggalSelesai,
        }),
      );

      // Debug: print full response so we can see what server actually returns
      debugPrint('[AddPenanganan] status: ${response.statusCode}');
      debugPrint('[AddPenanganan] body: ${response.body}');

      // Accept 200 or 201 — Laravel sometimes returns 200 for store()
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Guard: body might be HTML (redirect/error page) if Laravel isn't in API mode
        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body);
        } catch (_) {
          _showSnackBar(
            context,
            'Server mengembalikan respons tidak valid. Cek log Laravel.',
            isError: true,
          );
          return null;
        }

        if (data['success'] == true) {
          if (context.mounted) _showSnackBar(context, 'Penanganan berhasil ditambahkan');
          return Penanganan(
            nis: nis,
            namaIntervensi: namaIntervensi,
            isiIntervensi: isiIntervensi,
            status: status,
            tanggalMulai: tanggalMulai,
            tanggalSelesai: tanggalSelesai,
          );
        } else {
          debugPrint('[AddPenanganan] success==false: ${data['message']}');
          if (context.mounted) {
            _showSnackBar(
              context,
              data['message'] ?? 'Gagal menambahkan penanganan',
              isError: true,
            );
          }
          return null;
        }
      } else {
        // Try to decode error body, fall back gracefully if it's HTML
        String errorMsg = 'Gagal menghubungi server: ${response.statusCode}';
        try {
          final data = jsonDecode(response.body);
          errorMsg = data['message'] ?? errorMsg;
        } catch (_) {
          // Server returned HTML (e.g. 500 error page or redirect)
          errorMsg = 'Server error ${response.statusCode}. Cek log Laravel.';
        }
        if (context.mounted) _showSnackBar(context, errorMsg, isError: true);
        return null;
      }
    } catch (e) {
      debugPrint('[AddPenanganan] exception: $e');
      _showSnackBar(context, 'Terjadi kesalahan: $e', isError: true);
      return null;
    }
  }

  static void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ─── Show Helper ──────────────────────────────────────────────────────────────

void showAddPenangananPopup(
  BuildContext context,
  String studentName,
  String nis,
  String className,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: Colors.transparent,
    builder: (_) => AddPenangananSheet(
      studentName: studentName,
      nis: nis,
      className: className,
    ),
  );
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class AddPenangananSheet extends StatefulWidget {
  final String studentName;
  final String nis;
  final String className;

  const AddPenangananSheet({
    Key? key,
    required this.studentName,
    required this.nis,
    required this.className,
  }) : super(key: key);

  @override
  State<AddPenangananSheet> createState() => _AddPenangananSheetState();
}

class _AddPenangananSheetState extends State<AddPenangananSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final _namaController = TextEditingController();
  final _isiController = TextEditingController();
  final _namaFocus = FocusNode();
  final _isiFocus = FocusNode();

  bool _isSubmitting = false;
  String? _namaError;
  String? _isiError;
  String? _statusError;
  String? _tanggalMulaiError;
  String? _tanggalSelesaiError;

  String? _selectedStatus;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _namaController.dispose();
    _isiController.dispose();
    _namaFocus.dispose();
    _isiFocus.dispose();
    super.dispose();
  }

  void _close() {
    _animCtrl.reverse().then((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  bool _validate() {
    setState(() {
      _namaError = _namaController.text.trim().isEmpty ? 'Nama penanganan wajib diisi' : null;
      _isiError = _isiController.text.trim().isEmpty ? 'Isi penanganan wajib diisi' : null;
      _statusError = _selectedStatus == null ? 'Status wajib dipilih' : null;
      _tanggalMulaiError = _tanggalMulai == null ? 'Tanggal mulai wajib dipilih' : null;
      _tanggalSelesaiError = _tanggalSelesai == null
          ? 'Tanggal selesai wajib dipilih'
          : (_tanggalSelesai!.isBefore(_tanggalMulai!)
              ? 'Tanggal selesai harus setelah tanggal mulai'
              : null);
    });
    return _namaError == null &&
        _isiError == null &&
        _statusError == null &&
        _tanggalMulaiError == null &&
        _tanggalSelesaiError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);

    Penanganan? result;
    try {
      result = await PenangananUtils.submitPenanganan(
        nis: widget.nis,
        namaIntervensi: _namaController.text.trim(),
        isiIntervensi: _isiController.text.trim(),
        status: _selectedStatus!,
        tanggalMulai: _formatDate(_tanggalMulai!),
        tanggalSelesai: _formatDate(_tanggalSelesai!),
        context: context,
      );
    } finally {
      // Always reset spinner, even if an exception slips through
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (!mounted) return;
    if (result != null) _close();
  }

  String _formatDate(DateTime dt) => dt.toString().split(' ')[0];

  Future<void> _pickDate({required bool isMulai}) async {
    final now = DateTime.now();
    final initial = isMulai
        ? (_tanggalMulai ?? now)
        : (_tanggalSelesai ?? (_tanggalMulai ?? now));
    final first = isMulai ? DateTime(2020) : (_tanggalMulai ?? DateTime(2020));

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2030),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF3B82F6)),
        ),
        child: child!,
      ),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isMulai) {
          _tanggalMulai = picked;
          // Reset end date if it's before new start date
          if (_tanggalSelesai != null && _tanggalSelesai!.isBefore(picked)) {
            _tanggalSelesai = null;
          }
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            _SheetHeader(onClose: _close),

            // Scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Student info ──────────────────────────────
                    _SectionLabel(label: 'Informasi Siswa', icon: Icons.person_outline_rounded),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _ReadOnlyTile(
                            value: widget.studentName,
                            label: 'Nama Siswa',
                            icon: Icons.person_rounded,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _ReadOnlyTile(
                            value: widget.className,
                            label: 'Kelas',
                            icon: Icons.class_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ── Detail penanganan ─────────────────────────
                    _SectionLabel(label: 'Detail Penanganan', icon: Icons.assignment_outlined),
                    const SizedBox(height: 8),

                    // Nama Penanganan
                    _InputField(
                      controller: _namaController,
                      focusNode: _namaFocus,
                      label: 'Nama Penanganan',
                      hint: 'cth: Penindak Lanjutan Kehadiran Siswa',
                      icon: Icons.title_rounded,
                      errorText: _namaError,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _isiFocus.requestFocus(),
                    ),

                    const SizedBox(height: 12),

                    // Isi Penanganan
                    _InputField(
                      controller: _isiController,
                      focusNode: _isiFocus,
                      label: 'Isi Penanganan',
                      hint:
                          'cth: Memberikan bimbingan khusus kepada siswa yang sering absen...',
                      icon: Icons.notes_rounded,
                      maxLines: 4,
                      errorText: _isiError,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 12),

                    // Status dropdown
                    _DropdownField(
                      label: 'Status',
                      icon: Icons.flag_outlined,
                      value: _selectedStatus,
                      items: PenangananUtils.statusOptions,
                      errorText: _statusError,
                      onChanged: (val) => setState(() {
                        _selectedStatus = val;
                        _statusError = null;
                      }),
                    ),

                    const SizedBox(height: 12),

                    // Date pickers row
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(isMulai: true),
                            child: _ReadOnlyTile(
                              value: _tanggalMulai != null
                                  ? _formatDate(_tanggalMulai!)
                                  : 'Pilih tanggal',
                              label: 'Tanggal Mulai',
                              icon: Icons.calendar_today_rounded,
                              trailingIcon: Icons.edit_calendar_rounded,
                              errorText: _tanggalMulaiError,
                              isEmpty: _tanggalMulai == null,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _pickDate(isMulai: false),
                            child: _ReadOnlyTile(
                              value: _tanggalSelesai != null
                                  ? _formatDate(_tanggalSelesai!)
                                  : 'Pilih tanggal',
                              label: 'Tanggal Selesai',
                              icon: Icons.event_available_rounded,
                              trailingIcon: Icons.edit_calendar_rounded,
                              errorText: _tanggalSelesaiError,
                              isEmpty: _tanggalSelesai == null,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : _close,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              side: const BorderSide(color: Color(0xFFE5E7EB)),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Text(
                              'Batal',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFF93C5FD),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.save_rounded, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Simpan',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _SheetHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_add, color: Colors.white, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tambah Penanganan',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Catat rencana intervensi untuk siswa',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 6),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9CA3AF),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final IconData? trailingIcon;
  final String? errorText;
  final bool isEmpty;

  const _ReadOnlyTile({
    required this.value,
    required this.label,
    required this.icon,
    this.trailingIcon,
    this.errorText,
    this.isEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFFFFF1F2) : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17, color: const Color(0xFFD1D5DB)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF9CA3AF),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isEmpty
                            ? const Color(0xFFD1D5DB)
                            : const Color(0xFF374151),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 15, color: const Color(0xFF3B82F6)),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 13, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  errorText!,
                  style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFEF4444)),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? errorText;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  const _InputField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.errorText,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF6B7280)),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFFD1D5DB)),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            filled: true,
            fillColor: errorText != null ? const Color(0xFFFFF1F2) : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFFCA5A5)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: maxLines > 1 ? 14 : 0,
            ),
            alignLabelWithHint: maxLines > 1,
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 13, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFEF4444)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final String? errorText;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: hasError ? const Color(0xFFFFF1F2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasError ? const Color(0xFFFCA5A5) : const Color(0xFFE5E7EB),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: value,
              hint: Row(
                children: [
                  Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
                  const SizedBox(width: 10),
                  Text(
                    'Pilih Status',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color(0xFFD1D5DB),
                    ),
                  ),
                ],
              ),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF9CA3AF)),
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
              items: items
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Row(
                          children: [
                            Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
                            const SizedBox(width: 10),
                            Text(s),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.error_outline, size: 13, color: Color(0xFFEF4444)),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFFEF4444)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}