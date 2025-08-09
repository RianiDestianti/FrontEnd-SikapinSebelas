import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skoring/models/point.dart';

class PointUtils {
  static Future<Point?> submitPoint({
    required String type,
    required String studentName,
    required String className,
    required String date,
    required String description,
    required BuildContext context,
  }) async {
    if (studentName.isEmpty || className.isEmpty || date.isEmpty) {
      _showErrorSnackBar(context, 'Mohon lengkapi semua field yang diperlukan');
      return null;
    }

    await Future.delayed(const Duration(milliseconds: 1500));

    final pointData = Point(
      type: type,
      studentName: studentName,
      className: className,
      date: date,
      description: description,
    );

    print(
      'Point data: ${pointData.type}, ${pointData.studentName}, ${pointData.className}, ${pointData.date}, ${pointData.description}',
    );

    _showSuccessSnackBar(
      context,
      'Poin berhasil ditambahkan untuk $studentName',
    );
    return pointData;
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  static void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class PointPopup extends StatefulWidget {
  final String studentName;

  const PointPopup({Key? key, required this.studentName}) : super(key: key);

  @override
  State<PointPopup> createState() => _PointPopupState();
}

class _PointPopupState extends State<PointPopup> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _slideController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _rotateAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _classController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedPointType = 'Pelanggaran';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _nameController.text = widget.studentName;
    _classController.text = 'XII RPL 2'; // Set default class
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _rotateAnimation = Tween<double>(begin: 0.1, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _slideController.dispose();
    _nameController.dispose();
    _classController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    _animationController.reverse().then((_) => Navigator.of(context).pop());
  }

  void _submitPoint() async {
    setState(() => _isSubmitting = true);
    final point = await PointUtils.submitPoint(
      type: _selectedPointType,
      studentName: _nameController.text,
      className: _classController.text,
      date: _dateController.text,
      description: _descriptionController.text,
      context: context,
    );
    setState(() => _isSubmitting = false);
    if (point != null) {
      _closeDialog();
    }
  }

  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF3B82F6)),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = pickedDate.toString().split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        color: Colors.black.withOpacity(0.6),
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: RotationTransition(
              turns: _rotateAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: PointDialogContent(
                    nameController: _nameController,
                    classController: _classController,
                    dateController: _dateController,
                    descriptionController: _descriptionController,
                    selectedPointType: _selectedPointType,
                    onPointTypeChanged:
                        (value) => setState(() => _selectedPointType = value),
                    isSubmitting: _isSubmitting,
                    onClose: _closeDialog,
                    onSubmit: _submitPoint,
                    onDateTap: _pickDate,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PointDialogContent extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController classController;
  final TextEditingController dateController;
  final TextEditingController descriptionController;
  final String selectedPointType;
  final ValueChanged<String> onPointTypeChanged;
  final bool isSubmitting;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final VoidCallback onDateTap;

  const PointDialogContent({
    Key? key,
    required this.nameController,
    required this.classController,
    required this.dateController,
    required this.descriptionController,
    required this.selectedPointType,
    required this.onPointTypeChanged,
    required this.isSubmitting,
    required this.onClose,
    required this.onSubmit,
    required this.onDateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 420),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeaderSection(onClose: onClose),
          FormSection(
            nameController: nameController,
            classController: classController,
            dateController: dateController,
            descriptionController: descriptionController,
            selectedPointType: selectedPointType,
            onPointTypeChanged: onPointTypeChanged,
            onDateTap: onDateTap,
          ),
          ActionButtons(
            isSubmitting: isSubmitting,
            onCancel: onClose,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final VoidCallback onClose;

  const HeaderSection({Key? key, required this.onClose}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.add_circle_outline,
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
                  'Tambah Poin',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Isi formulir di bawah ini',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class FormSection extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController classController;
  final TextEditingController dateController;
  final TextEditingController descriptionController;
  final String selectedPointType;
  final ValueChanged<String> onPointTypeChanged;
  final VoidCallback onDateTap;

  const FormSection({
    Key? key,
    required this.nameController,
    required this.classController,
    required this.dateController,
    required this.descriptionController,
    required this.selectedPointType,
    required this.onPointTypeChanged,
    required this.onDateTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          CustomTextField(
            controller: nameController,
            hint: 'Nama Lengkap',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: classController,
            hint: 'Kelas',
            icon: Icons.school_outlined,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: dateController,
            hint: 'Tanggal',
            icon: Icons.calendar_today_outlined,
            readOnly: true,
            onTap: onDateTap,
          ),
          const SizedBox(height: 16),
          PointTypeDropdown(
            selectedPointType: selectedPointType,
            onChanged: onPointTypeChanged,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: descriptionController,
            hint: 'Uraian pelanggaran atau prestasi',
            icon: Icons.description_outlined,
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF9CA3AF),
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF6B7280), size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: const Color(0xFF374151),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class PointTypeDropdown extends StatelessWidget {
  final String selectedPointType;
  final ValueChanged<String> onChanged;

  const PointTypeDropdown({
    Key? key,
    required this.selectedPointType,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pointTypes = ['Pelanggaran', 'Prestasi'];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(
              selectedPointType == 'Pelanggaran'
                  ? Icons.warning_rounded
                  : Icons.star_rounded,
              color:
                  selectedPointType == 'Pelanggaran'
                      ? const Color(0xFFEF4444)
                      : const Color(0xFFFBBF24),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPointType,
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF6B7280),
                  ),
                  items:
                      pointTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF374151),
                            ),
                          ),
                        );
                      }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      onChanged(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  const ActionButtons({
    Key? key,
    required this.isSubmitting,
    required this.onCancel,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: isSubmitting ? null : onCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  'Batal',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: isSubmitting ? null : onSubmit,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child:
                    isSubmitting
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : Text(
                          'Tambah Poin',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showPointPopup(BuildContext context, String studentName) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Material(
        color: Colors.transparent,
        child: PointPopup(studentName: studentName),
      );
    },
  );
}