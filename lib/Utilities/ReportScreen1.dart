import 'package:flutter/material.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/Utilities/pdf_generator2.dart';

class ReportScreen1 extends StatelessWidget {
  const ReportScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generate PDF'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Fetch data from the database
            Map<String, double> totals = await dbline.allLineDetails();

            List<PdfEntry> entries = await dbLending.fetchLendingEntries();
            double totalAmtGiven = totals['totalAmtGiven'] ?? 0.0;
            double totalProfit = totals['totalProfit'] ?? 0.0;
            double totalAmtReceived = totals['totalAmtRecieved'] ?? 0.0;
            double totalExpense = await fetchTotalExpense();

            await generateNewPdf(entries, totalAmtGiven, totalProfit,
                totalAmtReceived, totalExpense, 'sk');
          },
          child: Text('Generate PDF'),
        ),
      ),
    );
  }

  Future<double> fetchTotalExpense() async {
    // Implement your logic to fetch total expense from the database
    // Example:
    return 100.0;
  }
}
