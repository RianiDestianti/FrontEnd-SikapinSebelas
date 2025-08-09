import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:file_saver/file_saver.dart';

class PdfExport {
  static Future<void> exportToPDF(List<Map<String, dynamic>> students, String fileName) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                'Laporan Penilaian Siswa XII RPL 2 - Semester Ganjil 2025/2026',
                style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['Nama', 'Total Poin', 'Apresiasi', 'Pelanggaran'],
              data: students.map((student) => [
                    student['name'],
                    student['totalPoin'].toString(),
                    student['apresiasi'].toString(),
                    student['pelanggaran'].toString(),
                  ]).toList(),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Detail Nilai', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            ...students.map((student) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.SizedBox(height: 10),
                  pw.Text(student['name'], style: const pw.TextStyle(fontSize: 14)),
                  pw.Table.fromTextArray(
                    headers: ['Keterangan', 'Tanggal', 'Poin', 'Tipe'],
                    data: (student['scores'] as List<Map<String, dynamic>>)
                        .map((score) => [
                              score['keterangan'],
                              score['tanggal'],
                              score['poin'].toString(),
                              score['type'],
                            ])
                        .toList(),
                  ),
                ],
              );
            }).toList(),
          ];
        },
      ),
    );

    final bytes = await pdf.save();
    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      mimeType: MimeType.pdf,
    );
  }
}