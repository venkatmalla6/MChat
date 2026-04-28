import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportHelper {
  static Future<void> exportToPdf(String title, List<Map<String, dynamic>> mcqs) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 20),
            ...mcqs.asMap().entries.map((entry) {
              final index = entry.key;
              final mcq = entry.value;
              final question = mcq['question'] as String;
              final options = List<String>.from(mcq['options']);

              return pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 20),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Q${index + 1}: $question', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 10),
                    ...options.asMap().entries.map((optEntry) {
                      final optIdx = optEntry.key;
                      final optText = optEntry.value;
                      final label = ['A', 'B', 'C', 'D'][optIdx];
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(left: 20, bottom: 5),
                        child: pw.Text('$label. $optText'),
                      );
                    }),
                  ],
                ),
              );
            }),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static Future<void> exportToJson(List<Map<String, dynamic>> mcqs) async {
    final jsonString = jsonEncode(mcqs);
    await Share.share(jsonString, subject: 'Quiz JSON Export');
  }
}
