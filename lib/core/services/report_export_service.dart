import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportExportService {
  const ReportExportService();

  Future<String> exportPdf({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final document = pw.Document(
      title: title,
      author: 'UniHostel Visitor Management',
    );
    document.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (_) => [
          pw.Text(
            title,
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text('Generated ${DateTime.now().toIso8601String()}'),
          pw.SizedBox(height: 18),
          pw.TableHelper.fromTextArray(
            headers: headers,
            data: rows,
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF6D28D9),
            ),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellPadding: const pw.EdgeInsets.all(5),
          ),
        ],
      ),
    );
    return _write('${_safeName(title)}.pdf', await document.save());
  }

  Future<String> exportExcel({
    required String title,
    required List<String> headers,
    required List<List<String>> rows,
  }) async {
    final workbook = Excel.createExcel();
    final sheet = workbook['Report'];
    workbook.delete('Sheet1');
    sheet.appendRow(headers.map(TextCellValue.new).toList());
    for (final row in rows) {
      sheet.appendRow(row.map(TextCellValue.new).toList());
    }
    for (var index = 0; index < headers.length; index++) {
      sheet.setColumnWidth(index, 20);
    }
    final bytes = workbook.encode();
    if (bytes == null) {
      throw const FileSystemException('Unable to encode Excel report.');
    }
    return _write('${_safeName(title)}.xlsx', Uint8List.fromList(bytes));
  }

  Future<String> _write(String fileName, Uint8List bytes) async {
    final home = Platform.environment['USERPROFILE'] ?? Directory.current.path;
    final directory = Directory(
      '$home${Platform.pathSeparator}Downloads${Platform.pathSeparator}UniHostel Reports',
    );
    await directory.create(recursive: true);
    final file = File('${directory.path}${Platform.pathSeparator}$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  String _safeName(String value) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final base = value.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    return '${base}_$timestamp';
  }
}
