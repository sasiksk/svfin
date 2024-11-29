import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/LineReportScreen.dart';
import 'package:svf/PartyDetailScreen.dart';
import 'package:svf/ReportScreen2.dart';
import 'package:svf/Utilities/AppBar.dart';
import 'package:svf/Utilities/EmptyDetailsCard.dart';
import 'package:svf/Utilities/FloatingActionButtonWithText.dart';
import 'package:svf/Utilities/LineCard.dart';
import 'package:svf/Utilities/PartyScreen.dart';
import 'package:svf/Utilities/drawer.dart';
import 'finance_provider.dart';

class LineDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineName = ref.watch(currentLineNameProvider);

    if (lineName == null) {
      return Center(child: CircularProgressIndicator());
    }

    void handleLineSelected(String partyName) async {
      ref.read(currentPartyNameProvider.notifier).state = partyName;
      ref.read(currentLineNameProvider.notifier).state = lineName;
      // Fetch LenId for the selected party
      final lenId = await DatabaseHelper.getLenId(lineName!, partyName);
      ref.read(lenIdProvider.notifier).state = lenId;
      print(lenId.toString());
      final stat = await DatabaseHelper.getStatus(lenId!);
      ref.read(lenStatusProvider.notifier).state = stat.toString();
      ref.read(lenIdProvider.notifier).state = lenId;
      print(stat.toString());

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PartyDetailScreen()),
      ).then((_) {});
    }

    return Scaffold(
      drawer: buildDrawer(context),
      appBar: CustomAppBar(
        title: lineName!,
      ),
      body: Column(
        children: [
          FutureBuilder<Map<String, double>>(
            future: dbLending.getLineSums(lineName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData) {
                return Center(child: Text('No data found.'));
              } else {
                final data = snapshot.data!;
                return EmptyCard(
                  screenHeight: MediaQuery.of(context).size.height * 1.56,
                  screenWidth: MediaQuery.of(context).size.width,
                  title: 'Line Details',
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Given: ₹${data['totalAmtGiven']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'Profit: ₹${data['totalProfit']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Collected: ₹${data['totalAmtCollected']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(fontSize: 16),
                          ),
                          Text(
                            'In Line: ₹${data['totalDueAmt']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Linereportscreen()),
                                );
                              },
                              icon: Icon(Icons.report)),
                          Text('View Report')
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          Text(
            'Party List  ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors
                  .black, // Use Colors.black or Colors.grey[800] for contrast
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: dbLending.getPartyNames(lineName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No parties found.'));
                } else {
                  final partyNames = snapshot.data!;
                  return ListView.builder(
                    itemCount: partyNames.length,
                    itemBuilder: (context, index) {
                      return LineCard(
                        lineName: partyNames[index],
                        screenWidth: MediaQuery.of(context).size.width,
                        onLineSelected: () =>
                            handleLineSelected(partyNames[index]),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonWithText(
        label: 'Add Party',
        navigateTo: PartyScreen(),
        icon: Icons.add,
      ),
    );
  }
}
