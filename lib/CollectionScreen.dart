import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/PartyDetailScreen.dart';
import 'package:svf/Utilities/CustomDatePicker.dart';
import 'package:svf/finance_provider.dart';
import 'package:intl/intl.dart';
import 'package:svf/linedetailScreen.dart';

class CollectionScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amtCollectedController = TextEditingController();
  final int? preloadedCid;
  final double? preloadedAmtCollected;

  CollectionScreen(
      {String? preloadedDate, this.preloadedAmtCollected, this.preloadedCid}) {
    if (preloadedDate != null) {
      _dateController.text = preloadedDate;
    } else {
      _dateController.text = DateFormat('dd-MM-yyyy').format(DateTime.now());
    }
    if (preloadedAmtCollected != null) {
      _amtCollectedController.text = preloadedAmtCollected.toString();
    }
  }

  Future<Map<String, dynamic>> _fetchLendingData(int lenId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'Lending',
      columns: [' amtgiven', 'profit', 'amtcollected'],
      where: 'LenId = ?',
      whereArgs: [lenId],
    );

    if (result.isNotEmpty) {
      return result.first;
    } else {
      throw Exception('No data found for LenId: $lenId');
    }
  }

  Future<void> _updateLendingData(int lenId, double collectedAmt) async {
    final lendingData = await _fetchLendingData(lenId);
    print(lendingData.entries);

    final double amtCollected = (lendingData['amtcollected']);
    final double amtgiven = (lendingData['amtgiven']) + (lendingData['profit']);

    final updatedValues = {
      'amtcollected': amtCollected + collectedAmt,
      'status': (amtgiven - collectedAmt) == 0 ? 'passive' : 'active',
    };

    await dbLending.updateDueAmt(
      lenId: lenId,
      updatedValues: updatedValues,
    );
  }

  Future<double> _fetchAmtRecieved(String lineName) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'Line',
      columns: ['Amtrecieved'],
      where: 'Linename = ?',
      whereArgs: [lineName],
    );

    if (result.isNotEmpty) {
      return (result.first['Amtrecieved'] ?? 0.0) as double;
    } else {
      throw Exception('No data found for LineName: $lineName');
    }
  }

  Future<void> _updateAmtRecieved(String lineName, double collectedAmt) async {
    final amtRecieved = await _fetchAmtRecieved(lineName);
    final updatedAmtRecieved = amtRecieved + collectedAmt;

    await dbline.updateLine(
      lineName: lineName,
      updatedValues: {'Amtrecieved': updatedAmtRecieved},
    );
  }

  Future<int> _getNextCid() async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT MAX(cid) as maxCid FROM Collection');
    final maxCid = result.first['maxCid'] as int?;
    return (maxCid ?? 0) + 1;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partyName = ref.watch(currentPartyNameProvider);
    final lenid = ref.watch(lenIdProvider);
    final lineName = ref.watch(currentLineNameProvider);
    final lenStatus = ref.watch(lenStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(partyName ?? "Add Collection"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomDatePicker(
                controller: _dateController,
                labelText: "Date of Payment",
                hintText: "Pick the date of payment",
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _amtCollectedController,
                decoration: InputDecoration(
                  labelText: "Amount Collected",
                  hintText: "Enter the amount collected",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the amount collected';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      final date = _dateController.text;
                      final collectedAmt =
                          double.parse(_amtCollectedController.text);

                      if (lenid != null && lineName != null) {
                        if (lenStatus == 'active') {
                          if (preloadedCid != null) {
                            // Fetch the current amtCollected and dueAmt from Lending table
                            final lendingData =
                                await dbLending.fetchLendingData(lenid);

                            final double currentAmtCollected =
                                lendingData['amtcollected'];
                            final double currentgivenamt =
                                lendingData['amtgiven'];

                            // Calculate the new amtCollected and dueAmt
                            final double newAmtCollected = currentAmtCollected +
                                collectedAmt -
                                preloadedAmtCollected!;
                            final String status =
                                currentgivenamt - newAmtCollected == 0
                                    ? 'passive'
                                    : 'active';

                            final amtRecieved_Line =
                                await _fetchAmtRecieved(lineName);
                            final newamtrecived = amtRecieved_Line +
                                collectedAmt -
                                preloadedAmtCollected!;
                            await dbline.updateLine(
                                lineName: lineName,
                                updatedValues: {'Amtrecieved': newamtrecived});

                            await dbLending.updateLendingAmounts(
                                lenId: lenid,
                                newAmtCollected: newAmtCollected,
                                status: status);

                            //newDueAmt: newDueAmt);
                            // Update existing record in Collection table
                            await CollectionDB.updateCollection(
                              cid: preloadedCid!,
                              lenId: lenid,
                              date: date,
                              crAmt: 0.0,
                              drAmt: collectedAmt,
                            );
                          } else {
                            // Insert new record
                            final cid = await _getNextCid();
                            await CollectionDB.insertCollection(
                              cid: cid,
                              lenId: lenid,
                              date: date,
                              crAmt: 0.0,
                              drAmt: collectedAmt,
                            );
                            print(lineName);
                            print(partyName);
                            print(lenid);
                            await _updateLendingData(lenid, collectedAmt);
                            await _updateAmtRecieved(lineName, collectedAmt);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Form Submitted')),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PartyDetailScreen(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    'Cannot lend amount to passive state party')),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Error: LenId or LineName is null')),
                        );
                      }
                    }
                  },
                  child: Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
