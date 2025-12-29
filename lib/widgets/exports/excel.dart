import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

class ExcelExport {
  static Future<String?> exportToExcel(
    List<Map<String, dynamic>> students,
    String fileName, {
    String? kelas,
    String? filterLabel,
    String? searchQuery,
  }) async {
    final excel = Excel.createExcel();
    final summary = excel['Summary'];
    excel.setDefaultSheet('Summary');
    summary.appendRow(['Filter', filterLabel ?? 'Semua']);
    summary.appendRow(
      ['Pencarian', searchQuery != null && searchQuery.isNotEmpty ? searchQuery : '-'],
    );
    summary.appendRow(['Kelas', kelas ?? '-']);
    summary.appendRow([]);
    summary.appendRow(['Nama', 'NIS', 'Total Poin', 'Apresiasi', 'Pelanggaran']);

    for (final student in students) {
      summary.appendRow([
        student['name']?.toString() ?? '',
        student['nis']?.toString() ?? '',
        student['totalPoin']?.toString() ?? '0',
        student['apresiasi']?.toString() ?? '0',
        student['pelanggaran']?.toString() ?? '0',
      ]);
    }

    final detail = excel['Detail'];
    detail.appendRow(['Nama', 'NIS', 'Keterangan', 'Tanggal', 'Poin', 'Tipe']);

    for (final student in students) {
      final scores =
          (student['scores'] as List<dynamic>? ?? [])
              .cast<Map<String, dynamic>>();
      for (final score in scores) {
        detail.appendRow([
          student['name']?.toString() ?? '',
          student['nis']?.toString() ?? '',
          score['keterangan']?.toString() ?? '',
          score['tanggal']?.toString() ?? '',
          score['poin']?.toString() ?? '0',
          score['type']?.toString() ?? '',
        ]);
      }
    }

    final bytes = excel.encode();
    if (bytes == null) return null;
    final data = Uint8List.fromList(bytes);

    final trimmedName = fileName.trim().isEmpty ? 'laporan_siswa' : fileName;
    final dotIndex = trimmedName.lastIndexOf('.');
    String baseName = trimmedName;
    String ext = '';
    if (dotIndex > 0 && dotIndex < trimmedName.length - 1) {
      baseName = trimmedName.substring(0, dotIndex);
      ext = trimmedName.substring(dotIndex + 1);
    }
    if (ext.isEmpty) {
      ext = 'xlsx';
    }

    if (Platform.isAndroid || Platform.isIOS) {
      return FileSaver.instance.saveAs(
        name: baseName,
        bytes: data,
        ext: ext,
        mimeType: MimeType.microsoftExcel,
      );
    }

    return FileSaver.instance.saveFile(
      name: baseName,
      bytes: data,
      ext: ext,
      mimeType: MimeType.microsoftExcel,
    );
  }
}
