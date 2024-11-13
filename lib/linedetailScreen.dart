import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/PartyDetailScreen.dart';
import 'package:svf/Utilities/AppBar.dart';
import 'package:svf/Utilities/BottomNavigationBar.dart';
import 'package:svf/Utilities/EmptyDetailsCard.dart';
import 'package:svf/Utilities/LineCard.dart';
import 'package:svf/Utilities/drawer.dart';
import 'finance_provider.dart';

class LineDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineName = ref.watch(currentLineNameProvider);

    void handleLineSelected(String partyName) async {
      ref.read(currentPartyNameProvider.notifier).state = partyName;

      // Fetch LenId for the selected party
      final lenId = await DatabaseHelper.getLenId(lineName!, partyName);
      ref.read(lenIdProvider.notifier).state = lenId;
      print(lenId.toString());
      final stat = await DatabaseHelper.getStatus(lenId!);
      ref.read(lenStatusProvider.notifier).state = stat.toString();
      print(stat.toString());

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PartyDetailScreen()),
      );
    }

    return Scaffold(
      drawer: buildDrawer(context),
      appBar: CustomAppBar(
        title: lineName!,
      ),
      body: Column(
        children: [
          Center(
            child: EmptyCard(
              screenHeight: MediaQuery.of(context).size.height,
              screenWidth: MediaQuery.of(context).size.width,
              title: 'Line Details Loading',
              content: Text('Loading details...'),
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
      bottomNavigationBar: CustomBottomNavigationBar(),
    );
  }
}
