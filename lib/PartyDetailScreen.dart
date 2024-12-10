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
import 'package:intl/intl.dart';

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
              screenHeight: MediaQuery.of(context).size.height * 1.45,
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
                        final daysover = data['lentdate'] != null &&
                                data['lentdate'].isNotEmpty
                            ? DateTime.now()
                                .difference(DateFormat('dd-MM-yyyy')
                                    .parse(data['lentdate']))
                                .inDays
                            : null;
                        print(daysover);

                        final daysrem =
                            data['duedays'] != null && daysover != null
                                ? data['duedays'] - daysover
                                : null;
                        print(daysrem);
                        final duedate = data['lentdate'] != null &&
                                data['lentdate'].isNotEmpty
                            ? DateFormat('dd-MM-yyyy')
                                .parse(data['lentdate'])
                                .add(Duration(days: data['duedays']))
                                .toString()
                            : null;
                        return Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Given: ₹${data['totalAmtGiven']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Profit: ₹${data['totalProfit']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Total: ₹${((data['totalAmtGiven'] ?? 0.0) + (data['totalProfit'] ?? 0.0)).toStringAsFixed(2)}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              color: const Color.fromARGB(255, 245, 244, 244),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Collected: ₹${data['totalAmtCollected']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  'Due: ₹${((data['totalAmtGiven'] ?? 0.0) + (data['totalProfit'] ?? 0.0) - (data['totalAmtCollected'] ?? 0.0)).toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 2,
                              color: const Color.fromARGB(255, 247, 244, 244),
                            ),
                            Row(
                              children: [
                                Text(
                                  'Lentdate: ${data['lentdate']?.toString() ?? '0.00'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 14),
                                Text(
                                  'Days Over: $daysover',
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(width: 14),
                                Text(
                                  'Remaining: $daysrem',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: daysrem != null && daysrem < 0
                                        ? Colors.red
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  'Duedate: ${duedate != null ? DateFormat('dd-MM-yyyy').format(DateTime.parse(duedate)) : 'N/A'}',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            )
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
