import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Utilities/AppBar.dart';
import 'package:svf/Utilities/BottomNavigationBar.dart';
import 'package:svf/Utilities/EmptyDetailsCard.dart';
import 'finance_provider.dart';

class PartyDetailScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partyName = ref.watch(currentPartyNameProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: partyName ?? 'Party Details',
      ),
      body: Column(
        children: [
          Center(
            child: EmptyCard(
              screenHeight: MediaQuery.of(context).size.height,
              screenWidth: MediaQuery.of(context).size.width,
              title: 'Party Details Loading',
              content: const Text('Loading details...'),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
