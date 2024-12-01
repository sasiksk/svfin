import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<String> lineNames = [];
  double totalAmtGiven = 0.0;
  double totalProfit = 0.0;
  double totalAmtRecieved = 0.0;

  @override
  void initState() {
    super.initState();
    loadLineNames();

    loadLineDetails();
  }

  Future<void> loadLineNames() async {
    final names = await dbline.getLineNames();
    setState(() {
      lineNames = names;
    });
  }

  Future<void> loadLineDetails() async {
    final details = await dbline.allLineDetails();
    setState(() {
      totalAmtGiven = details['totalAmtGiven'] ?? 0.0;
      totalProfit = details['totalProfit'] ?? 0.0;
      totalAmtRecieved = details['totalAmtRecieved'] ?? 0.0;
    });
  }

  void handleLineSelected(String lineName) {
    ref.read(currentLineNameProvider.notifier).state = lineName;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LineDetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final financeName = ref.watch(financeProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: '$financeName',
        actions: [
          IconButton(
            icon: Icon(Icons.upload_file),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ReportScreen2()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.close),
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
            screenHeight: MediaQuery.of(context).size.height * 1.50,
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
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Text(
                      ' Profit: ₹${totalProfit.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' Received: ₹${totalAmtRecieved.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      'in Line: ₹${(totalAmtGiven - totalAmtRecieved + totalProfit).toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                Row(
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
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            'Line List ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors
                  .black, // Use Colors.black or Colors.grey[800] for contrast
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lineNames.length,
              itemBuilder: (context, index) {
                return LineCard(
                  lineName: lineNames[index],
                  screenWidth: MediaQuery.of(context).size.width,
                  onLineSelected: () => handleLineSelected(lineNames[index]),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButtonWithText(
        label: 'Add Line',
        navigateTo: LineScreen(),
        icon: Icons.add,
      ),
    );
  }
}
