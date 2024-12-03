import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/CollectionScreen.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/LendingScreen.dart';
import 'package:svf/PartyReportScreen.dart';
import 'package:svf/Utilities/AppBar.dart';
import 'package:svf/Utilities/BottomNavigationBar.dart';
import 'package:svf/Utilities/EmptyDetailsCard.dart';
import 'package:svf/Utilities/FloatingActionButtonWithText.dart';
import 'package:svf/home_screen.dart';
import 'package:svf/linedetailScreen.dart';
import 'finance_provider.dart';

class PartyDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final linename = ref.watch(currentLineNameProvider);
    final partyName = ref.watch(currentPartyNameProvider);
    final lenId = ref.watch(lenIdProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: partyName ?? 'Party Details',
      ),
      body: Column(
        children: [
          Center(
            child: EmptyCard(
              screenHeight: MediaQuery.of(context).size.height * 1.85,
              screenWidth: MediaQuery.of(context).size.width,
              title: 'Party Details',
              content: Consumer(
                builder: (context, ref, child) {
                  final lenId = ref.watch(lenIdProvider);
                  return FutureBuilder<Map<String, dynamic>>(
                    future: dbLending.getPartySums(lenId!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData) {
                        return const Center(child: Text('No data found.'));
                      } else {
                        final data = snapshot.data!;
                        return Column(
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
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [],
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
                                            builder: (context) =>
                                                Partyreportscreen()),
                                      );
                                    },
                                    icon: Icon(Icons.report)),
                                Text('View Report')
                              ],
                            ),
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25),
            child: Row(
              children: [
                // Centered "Cr"
                Expanded(
                  child: Center(
                    child: Text(
                      'You Gave',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Text(
                  'You Got',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: CollectionDB.getCollectionEntries(lenId!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No entries found.'));
                } else {
                  final entries = snapshot.data!;
                  // Assuming you start with a 0 balance
                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final date = entry['Date'];
                      final crAmt = entry['CrAmt'] ?? 0.0;
                      final drAmt = entry['DrAmt'] ?? 0.0;
                      final cid = entry['cid'];

                      // Update balance based on credit or debit amount

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      date,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      crAmt > 0 ? '₹$crAmt' : '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      drAmt > 0 ? '₹ $drAmt' : '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.drag_indicator),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  ListTile(
                                                    title: const Text('Update'),
                                                    onTap: () {
                                                      if (drAmt > 0) {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                CollectionScreen(
                                                              preloadedDate:
                                                                  date,
                                                              preloadedAmtCollected:
                                                                  drAmt,
                                                              preloadedCid: cid,
                                                            ),
                                                          ),
                                                        );
                                                      } else {
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                  ),
                                                  ListTile(
                                                    title: Text('Delete'),
                                                    onTap: () {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                'Confirm Delete'),
                                                            content: Text(
                                                                'Are you sure you want to delete this entry?'),
                                                            actions: [
                                                              TextButton(
                                                                child: Text(
                                                                    'Cancel'),
                                                                onPressed: () {
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop();
                                                                },
                                                              ),
                                                              TextButton(
                                                                child:
                                                                    Text('OK'),
                                                                onPressed:
                                                                    () async {
                                                                  await CollectionDB
                                                                      .deleteEntry(
                                                                          cid);
                                                                  final lendingData =
                                                                      await dbLending
                                                                          .fetchLendingData(
                                                                              lenId);
                                                                  final amtRecieved_Line =
                                                                      await dbline
                                                                          .fetchAmtRecieved(
                                                                              linename!);
                                                                  final newamtrecived =
                                                                      amtRecieved_Line +
                                                                          -drAmt;
                                                                  await dbline.updateLine(
                                                                      lineName:
                                                                          linename,
                                                                      updatedValues: {
                                                                        'Amtrecieved':
                                                                            newamtrecived
                                                                      });

                                                                  final double
                                                                      currentAmtCollected =
                                                                      lendingData[
                                                                          'amtcollected'];

                                                                  // Calculate the new amtCollected and dueAmt
                                                                  final double
                                                                      newAmtCollected =
                                                                      currentAmtCollected -
                                                                          drAmt;

                                                                  final updatedValues =
                                                                      {
                                                                    'amtcollected':
                                                                        newAmtCollected,
                                                                  };
                                                                  //invoke dblending.updatelending
                                                                  await dbLending.updateAmtCollectedAndGiven(
                                                                      lineName:
                                                                          linename,
                                                                      partyName:
                                                                          partyName!,
                                                                      lenId:
                                                                          lenId,
                                                                      updatedValues:
                                                                          updatedValues);

                                                                  //get the lenid from the provider
                                                                  //get the current line name from the provider

                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Close the confirmation dialog
                                                                  Navigator.of(
                                                                          context)
                                                                      .pop(); // Close the options dialog
                                                                  // Refresh the screen
                                                                  Navigator.of(
                                                                          context)
                                                                      .pushReplacement(
                                                                    MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              PartyDetailScreen(),
                                                                    ),
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(left: 16.0, right: 16, bottom: 20, top: 20),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: FloatingActionButtonWithText(
                label: 'You Gave',
                navigateTo: LendingCombinedDetailsScreen(),
                icon: Icons.add,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: FloatingActionButtonWithText(
                label: 'You Got',
                navigateTo: CollectionScreen(),
                icon: Icons.add,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
