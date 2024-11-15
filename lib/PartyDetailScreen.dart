import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/CollectionScreen.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/LendingScreen.dart';
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
              screenHeight: MediaQuery.of(context).size.height * 1.50,
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
                                Text(
                                  'Balance: ₹${data['totalDueAmt']?.toStringAsFixed(2) ?? '0.00'}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Due Date: ${data['dueDate'] ?? ''}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  'Days Remaining: ${data['daysRemaining']?.toString() ?? '0'}',
                                  style: TextStyle(fontSize: 16),
                                ),
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
                      '                           Cr',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Right-aligned "Dr"
                Text(
                  'Dr',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.red,
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

                      // Update balance based on credit or debit amount

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 8),
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
                                      drAmt > 0 ? '₹ $drAmt' : '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      crAmt > 0 ? '₹ $crAmt' : '',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

// Right-aligned "Dr"
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
