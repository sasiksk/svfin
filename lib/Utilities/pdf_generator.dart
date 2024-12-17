import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/finance_provider.dart';
import 'package:flutter/services.dart';

class PdfEntry {
  final String partyName;
  final String date;
  final double drAmt;
  final double crAmt;

  PdfEntry({
    required this.partyName,
    required this.date,
    required this.drAmt,
    required this.crAmt,
  });
}

Future<void> generatePdf(
  List<PdfEntry> entries, // Change the type to List<PdfEntry>
  double totalYouGave,
  double totalYouGot,
  String start,
  String end,
  WidgetRef ref,
) async {
  final pdf = pw.Document();

  // Load custom font from assets
  final fontData = await rootBundle.load("assets/fonts/Roboto-Regular.ttf");
  final ttf = pw.Font.ttf(fontData);

  // Fetch finance name from provider
  final financeName = ref.read(financeNameProvider);

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
                'Finance Name: $financeName',
                style: pw.TextStyle(
                    font: ttf, fontSize: 16, color: PdfColors.black),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Account Statement ($start - $end)',
                  style: pw.TextStyle(
                      font: ttf, fontSize: 16, color: PdfColors.grey)),
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
                    pw.Text('Total Debit(-): \u20B9$totalYouGave',
                        style: pw.TextStyle(font: ttf, color: PdfColors.red)),
                    pw.Text('Total Credit(+): \u20B9$totalYouGot',
                        style: pw.TextStyle(font: ttf, color: PdfColors.green)),
                  ],
                ),
                pw.Text(
                  'Net Balance: \u20B9${totalYouGot - totalYouGave} Cr',
                  style: pw.TextStyle(
                      font: ttf,
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
                            font: ttf,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Name',
                        style: pw.TextStyle(
                            font: ttf,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.black)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Debit(-)',
                        style: pw.TextStyle(
                            font: ttf,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.red)),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.all(8),
                    child: pw.Text('Credit(+)',
                        style: pw.TextStyle(
                            font: ttf,
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
                      child: pw.Text(entry.date,
                          style: pw.TextStyle(font: ttf, fontSize: 12)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(entry.partyName,
                          style: pw.TextStyle(font: ttf, fontSize: 12)),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        entry.drAmt != 0.0 ? '\u20B9${entry.drAmt}' : '',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 12, color: PdfColors.red),
                      ),
                    ),
                    pw.Padding(
                      padding: pw.EdgeInsets.all(8),
                      child: pw.Text(
                        entry.crAmt != 0.0 ? '\u20B9${entry.crAmt}' : '',
                        style: pw.TextStyle(
                            font: ttf, fontSize: 12, color: PdfColors.green),
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
