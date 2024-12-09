import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/LineReportScreen.dart';
import 'package:svf/PartyDetailScreen.dart';
import 'package:svf/Utilities/AppBar.dart';
import 'package:svf/Utilities/EmptyDetailsCard.dart';
import 'package:svf/Utilities/FloatingActionButtonWithText.dart';
import 'package:svf/Utilities/LineCard.dart';
import 'package:svf/Utilities/PartyScreen.dart';
import 'package:svf/Utilities/drawer.dart';
import 'finance_provider.dart';

class LineDetailScreen extends ConsumerStatefulWidget {
  @override
  _LineDetailScreenState createState() => _LineDetailScreenState();
}

class _LineDetailScreenState extends ConsumerState<LineDetailScreen> {
  List<String> partyNames = [];
  ValueNotifier<List<String>> filteredPartyNamesNotifier = ValueNotifier([]);
  Map<String, Map<String, double>> partyDetailsMap = {};

  @override
  void initState() {
    super.initState();
    loadPartyNames();
  }

  void loadPartyNames() async {
    final lineName = ref.read(currentLineNameProvider);
    if (lineName != null) {
      final names = await dbLending.getPartyNames(lineName);
      final details = await Future.wait(
          names.map((name) => dbLending.getPartyDetailss(lineName, name)));
      print(details);
      setState(() {
        partyNames = names;
        filteredPartyNamesNotifier.value = names;
        for (int i = 0; i < names.length; i++) {
          partyDetailsMap[names[i]] = details[i];
        }
      });
    }
  }

  void handleLineSelected(String partyName) async {
    final lineName = ref.read(currentLineNameProvider);
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

  @override
  Widget build(BuildContext context) {
    final lineName = ref.watch(currentLineNameProvider);

    if (lineName == null) {
      return Center(child: CircularProgressIndicator());
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
                print(data);
                return EmptyCard(
                  screenHeight: MediaQuery.of(context).size.height * 1.25,
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
                            'Expense: ₹${data['totalexpense']?.toStringAsFixed(2) ?? '0.00'}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Amt in Line: ₹${(data['totalAmtGiven']! + data['totalProfit']! - data['totalAmtCollected']! - data['totalexpense']!).toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          SizedBox(
            height: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              height: 50, // Adjust the height as needed
              child: TextField(
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: GoogleFonts.tinos().fontFamily,
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search Party',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  filteredPartyNamesNotifier.value = partyNames
                      .where((partyName) =>
                          partyName.toLowerCase().contains(value.toLowerCase()))
                      .toList();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Party Name',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.tinos().fontFamily,
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Amount                              ',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: GoogleFonts.tinos().fontFamily,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<List<String>>(
              valueListenable: filteredPartyNamesNotifier,
              builder: (context, filteredPartyNames, _) {
                return ListView.builder(
                  itemCount: filteredPartyNames.length,
                  itemBuilder: (context, index) {
                    final partyName = filteredPartyNames[index];
                    final details = partyDetailsMap[partyName] ?? {};
                    final amtGiven = details['amtgiven'] ?? 0.0;
                    final profit = details['profit'] ?? 0.0;
                    final amtCollected = details['amtcollected'] ?? 0.0;
                    final calculatedValue = amtGiven + profit - amtCollected;

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 4),
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue,
                              Colors.blue[200]!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                partyName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontFamily: GoogleFonts.tinos().fontFamily,
                                ),
                              ),
                              Text(
                                '₹${calculatedValue.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                  fontFamily: GoogleFonts.tinos().fontFamily,
                                ),
                              ),
                            ],
                          ),
                          onTap: () => handleLineSelected(partyName),
                          trailing: PopupMenuButton<String>(
                            onSelected: (String value) async {
                              if (value == 'Update') {
                                print(partyName);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PartyScreen(
                                      partyName: partyName,
                                      // Pass other necessary details if needed
                                    ),
                                  ),
                                );
                              } else if (value == 'Delete') {
                                final lenId = await DatabaseHelper.getLenId(
                                    lineName!, partyName);
                                if (lenId != null) {
                                  await dbLending.deleteLendingAndCollections(
                                      lenId, lineName);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Party and related collections deleted successfully')),
                                  );
                                  // Optionally, refresh the list or navigate back
                                  loadPartyNames(); // Refresh the list after deletion
                                }
                              }
                            },
                            itemBuilder: (BuildContext context) {
                              return {'Update', 'Delete'}.map((String choice) {
                                return PopupMenuItem<String>(
                                  value: choice,
                                  child: Text(choice),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
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
