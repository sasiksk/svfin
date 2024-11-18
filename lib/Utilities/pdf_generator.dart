import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:open_file/open_file.dart';

Future<void> generatePdf(List<Map<String, dynamic>> entries,
    double totalYouGave, double totalYouGot) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Report', style: pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 16),
            pw.Text('Net Balance',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 8),
            pw.Container(
              padding: pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('TOTAL',
                          style: pw.TextStyle(color: PdfColors.grey)),
                      pw.Text('${entries.length} Entries'),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('YOU GAVE',
                          style: pw.TextStyle(color: PdfColors.red)),
                      pw.Text('₹ $totalYouGave',
                          style: pw.TextStyle(color: PdfColors.red)),
                    ],
                  ),
                  pw.Column(
                    children: [
                      pw.Text('YOU GOT',
                          style: pw.TextStyle(color: PdfColors.green)),
                      pw.Text('₹ $totalYouGot',
                          style: pw.TextStyle(color: PdfColors.green)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 16),
            pw.ListView.builder(
              itemCount: entries.length,
              itemBuilder: (context, index) {
                var entry = entries[index];
                var previousEntry = index > 0 ? entries[index - 1] : null;
                bool showDateHeader = previousEntry == null ||
                    entry['Date'] != previousEntry['Date'];

                double totalCrAmt = 0.0;
                double totalDrAmt = 0.0;

                for (var e
                    in entries.where((e) => e['Date'] == entry['Date'])) {
                  if (e['CrAmt'] != null) {
                    totalCrAmt += e['CrAmt'];
                  }
                  if (e['DrAmt'] != null) {
                    totalDrAmt += e['DrAmt'];
                  }
                }

                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    if (showDateHeader)
                      pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
                        child: pw.Container(
                          padding: pw.EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(8),
                          ),
                          child: pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                '${entry['Date']}',
                                style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold),
                              ),
                              pw.Text(
                                'You Gave: ₹ ${totalCrAmt != 0.0 ? totalCrAmt : 'null'}',
                                style: pw.TextStyle(color: PdfColors.red),
                              ),
                              pw.Text(
                                'You Got: ₹ ${totalDrAmt != 0.0 ? totalDrAmt : 'null'}',
                                style: pw.TextStyle(color: PdfColors.green),
                              ),
                            ],
                          ),
                        ),
                      ),
                    pw.Container(
                      padding:
                          pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                entry['PartyName'] != null &&
                                        entry['PartyName'].length >= 4
                                    ? entry['PartyName'].substring(0, 4)
                                    : entry['PartyName'] ?? '',
                                style: pw.TextStyle(color: PdfColors.grey),
                              ),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                entry['CrAmt'] != 0.0
                                    ? '₹ ${entry['CrAmt']}'
                                    : '',
                                style: pw.TextStyle(color: PdfColors.red),
                              ),
                            ],
                          ),
                          pw.Column(
                            children: [
                              pw.Text(
                                entry['DrAmt'] != 0.0
                                    ? '₹ ${entry['DrAmt']}'
                                    : '',
                                style: pw.TextStyle(color: PdfColors.green),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    ),
  );

  final output = await path_provider.getTemporaryDirectory();
  final file = File("${output.path}/report.pdf");
  await file.writeAsBytes(await pdf.save());

  OpenFile.open(file.path);
}
