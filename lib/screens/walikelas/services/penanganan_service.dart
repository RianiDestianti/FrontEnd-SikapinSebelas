import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:skoring/config/api.dart';

class PenangananItem {
  final int id;
  final String nis;
  final String namaIntervensi;
  final String isiIntervensi;
  final String status;
  final String tanggalMulai;
  final String tanggalSelesai;
  final String? perubahan;
  final String createdAt;
  final String updatedAt;

  PenangananItem({
    required this.id,
    required this.nis,
    required this.namaIntervensi,
    required this.isiIntervensi,
    required this.status,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    this.perubahan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PenangananItem.fromJson(Map<String, dynamic> json) {
    return PenangananItem(
      id: json['id'] ?? 0,
      nis: json['nis']?.toString() ?? '',
      namaIntervensi: json['nama_intervensi'] ?? '',
      isiIntervensi: json['isi_intervensi'] ?? '',
      status: json['status'] ?? '',
      tanggalMulai: json['tanggal_mulai_perbaikan'] ?? json['tanggal_Mulai_Perbaikan'] ?? '',
      tanggalSelesai: json['tanggal_selesai_perbaikan'] ?? json['tanggal_Selesai_Perbaikan'] ?? '',
      perubahan: json['perubahan_setelah_intervensi']?.toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nis': nis,
      'nama_intervensi': namaIntervensi,
      'isi_intervensi': isiIntervensi,
      'status': status,
      'tanggal_mulai_perbaikan': tanggalMulai,
      'tanggal_selesai_perbaikan': tanggalSelesai,
      'perubahan_setelah_intervensi': perubahan,
    };
  }
}

class PenangananService {
  static Future<List<PenangananItem>> fetchPenanganan(String nis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nip = prefs.getString('walikelas_id') ?? prefs.getString('nip_walikelas') ?? prefs.getString('nip') ?? '';
      final idKelas = prefs.getString('id_kelas') ?? prefs.getString('kelas_id') ?? '';
      final token = prefs.getString('sanctum_token') ?? '';

      if (nip.isEmpty || idKelas.isEmpty) {
        throw Exception('Data sesi tidak lengkap');
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/penanganan/$nis?nip=$nip&id_kelas=$idKelas');

      debugPrint('[PenjanganService] GET $url');

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('[PenjanganService] status: ${response.statusCode}');
      debugPrint('[PenjanganService] body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('[PenjanganService] response data: $data');
        if (data['success'] == true && data['data'] != null) {
          final List<dynamic> list = data['data'];
          debugPrint('[PenjanganService] list count: ${list.length}');
          return list.map((e) => PenangananItem.fromJson(e)).toList();
        }
        debugPrint('[PenjanganService] no data or success false');
        return [];
      }
      debugPrint('[PenjanganService] non-200 status: ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('[PenjanganService] fetch error: $e');
      return [];
    }
  }

  static Future<bool> updatePenintaan({
    required int id,
    required String namaIntervensi,
    required String isiIntervensi,
    required String status,
    required String tanggalMulai,
    required String tanggalSelesai,
    String? perubahan,
    required BuildContext context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nip = prefs.getString('walikelas_id') ?? prefs.getString('nip_walikelas') ?? prefs.getString('nip') ?? '';
      final idKelas = prefs.getString('id_kelas') ?? prefs.getString('kelas_id') ?? '';
      final token = prefs.getString('sanctum_token') ?? '';

      if (nip.isEmpty || idKelas.isEmpty) {
        _showSnackBar(context, 'Data sesi tidak lengkap. Silakan login ulang.', isError: true);
        return false;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/penanganan/$id?nip=$nip&id_kelas=$idKelas');

      debugPrint('[PenjanganService] PUT $url');
      debugPrint('[PenjanganService] body: ${{
        'nama_intervensi': namaIntervensi,
        'isi_intervensi': isiIntervensi,
        'status': status,
        'tanggal_mulai_perbaikan': tanggalMulai,
        'tanggal_selesai_perbaikan': tanggalSelesai,
        'perubahan_setelah_intervensi': perubahan,
      }}');

      final response = await http.put(
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
          if (perubahan != null) 'perubahan_setelah_intervensi': perubahan,
        }),
      );

      debugPrint('[PenjanganService] update status: ${response.statusCode}');
      debugPrint('[PenjanganService] update body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSnackBar(context, 'Penanganan berhasil diperbarui');
          return true;
        } else {
          _showSnackBar(context, data['message'] ?? 'Gagal memperbarui penanganan', isError: true);
          return false;
        }
      } else {
        _showSnackBar(context, 'Gagal menghubungi server: ${response.statusCode}', isError: true);
        return false;
      }
    } catch (e) {
      debugPrint('[PenjanganService] update error: $e');
      _showSnackBar(context, 'Terjadi kesalahan: $e', isError: true);
      return false;
    }
  }

  static Future<bool> deletePenanganan({
    required int id,
    required BuildContext context,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nip = prefs.getString('walikelas_id') ?? prefs.getString('nip_walikelas') ?? prefs.getString('nip') ?? '';
      final idKelas = prefs.getString('id_kelas') ?? prefs.getString('kelas_id') ?? '';
      final token = prefs.getString('sanctum_token') ?? '';

      if (nip.isEmpty || idKelas.isEmpty) {
        _showSnackBar(context, 'Data sesi tidak lengkap. Silakan login ulang.', isError: true);
        return false;
      }

      final url = Uri.parse('${ApiConfig.baseUrl}/penanganan/$id?nip=$nip&id_kelas=$idKelas');

      final response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          _showSnackBar(context, 'Penanganan berhasil dihapus');
          return true;
        }
      }
      _showSnackBar(context, 'Gagal menghapus penanganan', isError: true);
      return false;
    } catch (e) {
      _showSnackBar(context, 'Terjadi kesalahan: $e', isError: true);
      return false;
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