import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/Utilities/CustomDatePicker.dart';
import 'package:svf/finance_provider.dart';
import 'package:intl/intl.dart';

class CollectionScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amtCollectedController = TextEditingController();

  CollectionScreen() {
    _dateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<Map<String, dynamic>> _fetchLendingData(int lenId) async {
    final db = await DatabaseHelper.getDatabase();
    final List<Map<String, dynamic>> result = await db.query(
      'Lending',
      columns: ['dueAmt', 'amtCollected'],
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
    final double dueAmt1 = (lendingData['DueAmt']);
    final double amtCollected = (lendingData['amtcollected']);

    final updatedValues = {
      'dueAmt': dueAmt1 - collectedAmt,
      'amtCollected': amtCollected + collectedAmt,
      'status': (dueAmt1 - collectedAmt) == 0 ? 'passive' : 'active',
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partyName = ref.watch(currentPartyNameProvider);
    final lenid = ref.watch(lenIdProvider);
    final lineName = ref.watch(currentLineNameProvider);

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
                        final lenStatus = ref.read(lenStatusProvider);
                        if (lenStatus == 'active') {
                          await CollectionDB.insertCollection(
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

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Form Submitted')),
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
