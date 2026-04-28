import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skoring/config/api.dart';

class IntervensiEditScreen extends StatefulWidget {
  final Map intervensi;
  final String nis;
  final String studentName;
  final String className;

  const IntervensiEditScreen({
    Key? key,
    required this.intervensi,
    required this.nis,
    required this.studentName,
    required this.className,
  }) : super(key: key);

  @override
  State<IntervensiEditScreen> createState() => _IntervensiEditScreenState();
}

class _IntervensiEditScreenState extends State<IntervensiEditScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  final _namaController = TextEditingController();
  final _isiController = TextEditingController();
  final _perubahanController = TextEditingController();
  final _namaFocus = FocusNode();
  final _isiFocus = FocusNode();
  final _perubahanFocus = FocusNode();

  String? _namaError;
  String? _isiError;
  String? _perubahanError;
  String? _statusError;
  String? _tanggalMulaiError;
  String? _tanggalSelesaiError;

  String? _selectedStatus;
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _loadData();
  }

  void _loadData() {
    final data = widget.intervensi;
    _namaController.text = data['nama_intervensi'] ?? '';
    _isiController.text = data['isi_intervensi'] ?? '';
    _perubahanController.text = data['perubahan_setelah_intervensi'] ?? '';
    _selectedStatus = data['status'];
    if (data['tanggal_Mulai_Perbaikan'] != null) {
      _tanggalMulai = DateTime.tryParse(data['tanggal_Mulai_Perbaikan']);
    }
    if (data['tanggal_Selesai_Perbaikan'] != null) {
      _tanggalSelesai = DateTime.tryParse(data['tanggal_Selesai_Perbaikan']);
    }
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _namaController.dispose();
    _isiController.dispose();
    _perubahanController.dispose();
    _namaFocus.dispose();
    _isiFocus.dispose();
    _perubahanFocus.dispose();
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
      _perubahanError = _selectedStatus == 'Selesai' && _perubahanController.text.trim().isEmpty
          ? 'Perubahan setelah penanganan wajib diisi' : null;
    });
    return _namaError == null &&
        _isiError == null &&
        _statusError == null &&
        _tanggalMulaiError == null &&
        _tanggalSelesaiError == null &&
        _perubahanError == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final nip = prefs.getString('walikelas_id') ?? '';
      final idKelas = prefs.getString('id_kelas') ?? '';
      final token = prefs.getString('sanctum_token') ?? '';

      final idIntervensi = widget.intervensi['id_intervensi'];
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/intervensi/$idIntervensi/update?nip=$nip&id_kelas=$idKelas',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nis': widget.nis,
          'nama_intervensi': _namaController.text.trim(),
          'isi_intervensi': _isiController.text.trim(),
          'status': _selectedStatus,
          'tanggal_Mulai_Perbaikan': _formatDate(_tanggalMulai!),
          'tanggal_Selesai_Perbaikan': _formatDate(_tanggalSelesai!),
          if (_selectedStatus == 'Selesai')
            'perubahan_setelah_intervensi': _perubahanController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Penanganan berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          _close();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Gagal memperbarui penanganan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit Penanganan',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    onPressed: _close,
                    icon: const Icon(Icons.close_rounded),
                    color: const Color(0xFF6B7280),
                  ),
                ],
              ),
            ),

            // Scrollable body
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Student info
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

                    // Detail penanganan
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
                      hint: 'cth: Memberikan bimbingan khusus kepada siswa...',
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
                      items: const ['Binaan Khusus', 'Dalam Binaan', 'Selesai'],
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

                    // Show perubahan field when status is Selesai
                    if (_selectedStatus == 'Selesai') ...[
                      const SizedBox(height: 20),
                      _SectionLabel(
                        label: 'Perubahan Setelah Penanganan',
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      const SizedBox(height: 8),
                      _InputField(
                        controller: _perubahanController,
                        focusNode: _perubahanFocus,
                        label: 'Perubahan Setelah Penanganan',
                        hint: 'Jelaskan perubahan yang terjadi pada siswa setelah penanganan selesai...',
                        icon: Icons.notes_rounded,
                        maxLines: 4,
                        errorText: _perubahanError,
                        textInputAction: TextInputAction.done,
                      ),
                    ],

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
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation(
                                          Colors.white),
                                    ),
                                  )
                                : Text(
                                    'Simpan',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  final IconData icon;

  const _SectionLabel({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6B7280),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF9CA3AF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEmpty ? '—' : value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isEmpty
                        ? const Color(0xFF9CA3AF)
                        : const Color(0xFF1F2937),
                  ),
                ),
              ),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 18, color: const Color(0xFF9CA3AF)),
            ],
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? errorText;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const _InputField({
    required this.controller,
    this.focusNode,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.errorText,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF)),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFE5E7EB),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEF4444),
            ),
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
  final Function(String?) onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.errorText,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? const Color(0xFFEF4444)
                  : const Color(0xFFE5E7EB),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9CA3AF)),
              hint: Text(
                'Pilih',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFEF4444),
            ),
          ),
        ],
      ],
    );
  }
}