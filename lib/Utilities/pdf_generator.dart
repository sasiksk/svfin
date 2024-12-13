import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:svf/finance_provider.dart';

Future<void> generatePdf(
  List<Map<String, dynamic>> entries,
  double totalYouGave,
  double totalYouGot,
  // Ensure this is a String
) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(16),
      build: (pw.Context context) {
        return [
          // Title Section
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Finance Name:', // Updated line
                style: pw.TextStyle(fontSize: 16, color: PdfColors.black),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Account Statement (01 Dec 2024 - 31 Dec 2024)',
                  style: pw.TextStyle(fontSize: 16, color: PdfColors.grey)),
              pw.SizedBox(height: 16),
            ],
          ),
          // Summary Section
          pw.Container(
            padding: pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey300,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Total Debit(-): ₹$totalYouGave',
                        style: pw.TextStyle(color: PdfColors.red)),
                    pw.Text('Total Credit(+): ₹$totalYouGot',
                        style: pw.TextStyle(color: PdfColors.green)),
                  ],
                ),
                pw.Text(
                  'Net Balance: ₹${totalYouGave - totalYouGot} Dr',
                  style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // Table Section
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(3),
              2: pw.FlexColumnWidth(2),
              3: pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Date',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Name',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Debit(-)',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Credit(+)',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.green)),
                  ),
                ],
              ),
              ...entries.map((entry) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('${entry['Date']}',
                          style: pw.TextStyle(fontSize: 12)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text('${entry['PartyName']}',
                          style: pw.TextStyle(fontSize: 12)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        entry['CrAmt'] != null ? '₹${entry['CrAmt']}' : '',
                        style: pw.TextStyle(fontSize: 12, color: PdfColors.red),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        entry['DrAmt'] != null ? '₹${entry['DrAmt']}' : '',
                        style:
                            pw.TextStyle(fontSize: 12, color: PdfColors.green),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ];
      },
    ),
  );

  final output = await path_provider.getTemporaryDirectory();
  final file = File("${output.path}/report.pdf");
  await file.writeAsBytes(await pdf.save());

  OpenFile.open(file.path);
}
