import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/LineScreen.dart';
import 'package:svf/ReportScreen2.dart';
import 'package:svf/Utilities/AppBar.dart';
import 'package:svf/Utilities/EmptyDetailsCard.dart';
import 'package:svf/Utilities/LineCard.dart';
import 'package:svf/Utilities/drawer.dart';
import 'package:svf/Utilities/FloatingActionButtonWithText.dart';
import 'package:svf/linedetailScreen.dart';
import 'finance_provider.dart';
import 'package:svf/Utilities/GoogleFileUpload.dart';
import 'dart:io';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // final FirebaseFileUploader uploader = FirebaseFileUploader();

  List<String> lineNames = [];
  List<String> originalLineNames = [];
  double totalAmtGiven = 0.0;
  double totalProfit = 0.0;
  double totalAmtRecieved = 0.0;
  Map<String, Map<String, dynamic>> lineDetailsMap = {};
  double todaysTotalDrAmt = 0.0;
  double todaysTotalCrAmt = 0.0;
  double totalexpense = 0.0;

  @override
  void initState() {
    super.initState();
    loadLineNames();
    loadLineDetails();
    loadTodaysCollectionAndGiven();
  }

  Future<void> loadTodaysCollectionAndGiven() async {
    final result = await CollectionDB.getTodaysCollectionAndGiven();
    setState(() {
      todaysTotalDrAmt = result['totalDrAmt'] ?? 0.0;
      todaysTotalCrAmt = result['totalCrAmt'] ?? 0.0;
    });
  }

  Future<void> loadLineNames() async {
    final names = await dbline.getLineNames();
    final details =
        await Future.wait(names.map((name) => dbline.getLineDetails(name)));
    setState(() {
      originalLineNames = names;
      lineNames = names;
      for (int i = 0; i < names.length; i++) {
        lineDetailsMap[names[i]] = details[i];
      }
    });
  }

  Future<void> loadLineDetails() async {
    final details = await dbline.allLineDetails();
    setState(() {
      totalAmtGiven = details['totalAmtGiven'] ?? 0.0;
      totalProfit = details['totalProfit'] ?? 0.0;
      totalAmtRecieved = details['totalAmtRecieved'] ?? 0.0;
      totalexpense = details['totalexpense'] ?? 0.0;
    });
  }

  void handleLineSelected(String lineName) {
    ref.read(currentLineNameProvider.notifier).state = lineName;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LineDetailScreen()),
    );
  }

  void _showUpdateFinanceNameDialog(BuildContext context) {
    final TextEditingController _financeNameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Finance Name'),
          content: TextField(
            controller: _financeNameController,
            decoration:
                const InputDecoration(hintText: 'Enter new finance name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Update'),
              onPressed: () async {
                final newFinanceName = _financeNameController.text;
                if (newFinanceName.isNotEmpty) {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('financeName', newFinanceName);
                  ref.read(financeProvider.notifier).state = newFinanceName;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeName = ref.watch(financeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: financeName,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note_outlined),
            onPressed: () {
              _showUpdateFinanceNameDialog(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              final dbFilePath = await DatabaseHelper.getDatabasePath();
              File dbFile = File(dbFilePath);
              print(dbFile.path);
              //  await uploader.uploadFileToFirebase(dbFile);
            },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              // Handle close action
            },
          ),
        ],
      ),
      drawer: buildDrawer(context),
      body: Column(
        children: [
          EmptyCard(
            screenHeight: MediaQuery.of(context).size.height * 1.35,
            screenWidth: MediaQuery.of(context).size.width,
            title: 'Finance Details',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Given: ₹${totalAmtGiven.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    Text(
                      ' Profit: ₹${totalProfit.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' Received: ₹${totalAmtRecieved.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                    Text(
                      'Expense: ₹${totalexpense.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'In Line: ₹${(totalAmtGiven - totalAmtRecieved + totalProfit).toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color.fromARGB(255, 255, 255, 255)),
                    ),
                  ],
                ),
                /*Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReportScreen2()),
                          );
                        },
                        icon: Icon(Icons.report)),
                    Text('View Report')
                  ],
                ),*/
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Today\'s',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LineCard(
              lineName:
                  'Collection: ₹${todaysTotalDrAmt.toStringAsFixed(2)}     - Given: ₹${todaysTotalCrAmt.toStringAsFixed(2)}',
              screenWidth: MediaQuery.of(context).size.width,
            ),
          ),

          const SizedBox(
            height: 3,
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
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.add_chart_outlined,
                      color: Colors.blue,
                    ),
                    tooltip: 'View Report',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ReportScreen2()),
                      );
                    },
                  ),
                  hintText: 'Search line',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) {
                  setState(() {
                    lineNames = originalLineNames
                        .where((lineName) => lineName
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
          ),
          // i need a container to dispaly as Linename and in right side i need to display the amount
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Line Name',
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
                    'Amount in Line                               ',
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
            child: ListView.builder(
              itemCount: lineNames.length,
              itemBuilder: (context, index) {
                final lineName = lineNames[index];
                final lineDetails = lineDetailsMap[lineName] ?? {};
                final amtGiven = lineDetails['Amtgiven'] ?? 0.0;
                final profit = lineDetails['Profit'] ?? 0.0;
                final expense = lineDetails['expense'] ?? 0.0;
                final amtRecieved = lineDetails['Amtrecieved'] ?? 0.0;
                final calculatedValue =
                    amtGiven + profit - expense - amtRecieved;

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Colors.blueAccent,
                          Colors.blue,
                          Colors.lightBlueAccent
                        ], // Gradient background
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      title: Text(
                        lineName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: GoogleFonts.tinos().fontFamily,
                        ),
                      ),
                      onTap: () => handleLineSelected(lineName),
                      trailing: SizedBox(
                        width: MediaQuery.of(context).size.width *
                            0.4, // Adjust the width as needed
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Bal : ₹${calculatedValue.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontFamily: GoogleFonts.tinos().fontFamily,
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (String value) async {
                                if (value == 'Update') {
                                  final lineDetails = lineDetailsMap[lineName];
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          LineScreen(entry: lineDetails),
                                    ),
                                  );
                                } else if (value == 'Delete') {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Deletion'),
                                        content: const Text(
                                            'Are you sure you want to delete ! All the Parties inside the Line will be deleted'),
                                        actions: <Widget>[
                                          TextButton(
                                            child: const Text('Cancel'),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Dismiss the dialog
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('OK'),
                                            onPressed: () async {
                                              Navigator.of(context)
                                                  .pop(); // Dismiss the dialog
                                              final lenIds = await dbLending
                                                  .getLenIdsByLineName(
                                                      lineName);
                                              await dbline.deleteLine(lineName);
                                              await dbLending
                                                  .deleteLendingByLineName(
                                                      lineName);
                                              for (final lenId in lenIds) {
                                                await CollectionDB
                                                    .deleteEntriesByLenId(
                                                        lenId);
                                              }
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  loadLineNames();
                                  loadLineDetails();
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return {'Update', 'Delete'}
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: const FloatingActionButtonWithText(
        label: 'Add Line',
        navigateTo: LineScreen(),
        icon: Icons.add,
      ),
    );
  }
}
