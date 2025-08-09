
import 'package:excel/excel.dart' as excel;
import 'package:file_saver/file_saver.dart';
import 'dart:typed_data';

class ExcelExport {
  static Future<void> exportToExcel(List<Map<String, dynamic>> students, String fileName) async {
    final excelInstance = excel.Excel.createExcel();
    final sheet = excelInstance['Sheet1'];
    sheet.appendRow(['Nama', 'Total Poin', 'Apresiasi', 'Pelanggaran']);
    
    for (var student in students) {
      sheet.appendRow([
        student['name'],
        student['totalPoin'].toString(),
        student['apresiasi'].toString(),
        student['pelanggaran'].toString(),
      ]);
      sheet.appendRow(['Keterangan', 'Tanggal', 'Poin', 'Tipe']);
      for (var score in student['scores']) {
        sheet.appendRow([
          score['keterangan'],
          score['tanggal'],
          score['poin'].toString(),
          score['type'],
        ]);
      }
      sheet.appendRow(['']);
    }
    
    final bytes = excelInstance.encode();
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: Uint8List.fromList(bytes!),
      mimeType: MimeType.microsoftExcel,
    );
  }
}