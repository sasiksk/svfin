import 'package:flutter/material.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/Utilities/CustomDatePicker.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:path_provider/path_provider.dart' as path_provider;
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:svf/Utilities/pdf_generator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/finance_provider.dart';

class ReportScreen2 extends StatefulWidget {
  @override
  _ReportScreen2State createState() => _ReportScreen2State();
}

class _ReportScreen2State extends State<ReportScreen2> {
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  List<PdfEntry> _entries = []; // Change the type to List<PdfEntry>
  double _totalYouGave = 0.0;
  double _totalYouGot = 0.0;

  Future<void> _fetchEntries() async {
    if (_startDateController.text.isNotEmpty &&
        _endDateController.text.isNotEmpty) {
      DateTime startDate =
          DateFormat('dd-MM-yyyy').parse(_startDateController.text);
      DateTime endDate =
          DateFormat('dd-MM-yyyy').parse(_endDateController.text);

      List<Map<String, dynamic>> entries =
          await CollectionDB.getEntriesBetweenDates(startDate, endDate);

      double totalYouGave = 0.0;
      double totalYouGot = 0.0;

      List<PdfEntry> pdfEntries = []; // Create a list of PdfEntry

      for (var entry in entries) {
        if (entry['CrAmt'] != null) {
          totalYouGave += entry['CrAmt'];
        }
        if (entry['DrAmt'] != null) {
          totalYouGot += entry['DrAmt'];
        }

        // Fetch party name
        String partyName =
            await DatabaseHelper.getPartyNameByLenId(entry['LenId']) ??
                'Unknown';

        // Add to pdfEntries
        pdfEntries.add(PdfEntry(
          partyName: partyName,
          date: entry['Date'],
          drAmt: entry['DrAmt'] ?? 0.0,
          crAmt: entry['CrAmt'] ?? 0.0,
        ));
      }

      setState(() {
        _entries = pdfEntries;
        _totalYouGave = totalYouGave;
        _totalYouGot = totalYouGot;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Report'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Selection Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: CustomDatePicker(
                    controller: _startDateController,
                    labelText: 'Start Date',
                    hintText: 'Pick a start date',
                    lastDate: DateTime.now(),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomDatePicker(
                    controller: _endDateController,
                    labelText: 'End Date',
                    hintText: 'Pick an end date',
                    lastDate:
                        DateTime.now(), // Ensure end date does not exceed today
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchEntries,
              child: Text('Fetch Entries'),
            ),
            SizedBox(height: 16),

            // Net Balance Section
            Text(
              'Net Balance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.green.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total', style: TextStyle(color: Colors.white)),
                      Text('${_entries.length} Entries',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('You Gave', style: TextStyle(color: Colors.yellow)),
                      Text('₹ $_totalYouGave',
                          style: TextStyle(color: Colors.yellow)),
                    ],
                  ),
                  Column(
                    children: [
                      Text('You Got', style: TextStyle(color: Colors.white)),
                      Text('₹ $_totalYouGot',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 6),

            // Entries List
            Expanded(
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  var entry = _entries[index];
                  var previousEntry = index > 0 ? _entries[index - 1] : null;
                  bool showDateHeader =
                      previousEntry == null || entry.date != previousEntry.date;

                  double totalCrAmt = 0.0;
                  double totalDrAmt = 0.0;

                  for (var e in _entries.where((e) => e.date == entry.date)) {
                    totalCrAmt += e.crAmt;
                    totalDrAmt += e.drAmt;
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showDateHeader)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 16, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 219, 247, 169),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${DateFormat('dd-MM').format(DateFormat('dd-MM-yyyy').parse(entry.date))}',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '₹${totalCrAmt != 0.0 ? totalCrAmt : 0.0}',
                                  style: TextStyle(color: Colors.red),
                                ),
                                Text(
                                  '₹${totalDrAmt != 0.0 ? totalDrAmt : 0.0}',
                                  style: TextStyle(color: Colors.green),
                                ),
                              ],
                            ),
                          ),
                        ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.partyName.length >= 4
                                      ? entry.partyName.substring(0, 4)
                                      : entry.partyName,
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  entry.crAmt != 0.0 ? '₹${entry.crAmt}' : '',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  entry.drAmt != 0.0 ? '₹${entry.drAmt}' : '',
                                  style: TextStyle(color: Colors.green),
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
            ),

            // Download Button

            Consumer(
              builder: (context, ref, child) {
                final finnaame = ref.watch(financeProvider);
                return Center(
                  child: ElevatedButton.icon(
                    onPressed: () => generatePdf(
                      _entries,
                      _totalYouGave,
                      _totalYouGot,
                      _startDateController.text,
                      _endDateController.text,
                      ref,
                      finnaame,
                      // Pass the ref to generatePdf
                    ),
                    icon: Icon(Icons.picture_as_pdf),
                    label: Text('DOWNLOAD'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
