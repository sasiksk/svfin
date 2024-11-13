import 'package:flutter/material.dart';
import 'package:svf/CollectionScreen.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/LendingScreen.dart';
import 'package:svf/LineScreen.dart';
import 'package:svf/ReportScreen.dart';
import 'package:svf/Utilities/PartyScreen.dart';

import 'package:svf/home_screen.dart';
import 'package:svf/linedetailScreen.dart';

Widget buildDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.teal.shade900,
          ),
          child: const Text(
            'Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('Home'),
          onTap: () {
            //navigate to home screen
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Reports'),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ReportScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Drop Database'),
          onTap: () {
            DatabaseHelper.dropDatabase();
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Create db'),
          onTap: () {
            DatabaseHelper.getDatabase();
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Line Add'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LineScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Party Add'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PartyScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('LineDetail Screen'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LineDetailScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Lending Screen'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => LendingCombinedDetailsScreen()),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.report),
          title: const Text('Collection Screen'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CollectionScreen()),
            );
          },
        ),

        // Add more items here as needed
      ],
    ),
  );
}
