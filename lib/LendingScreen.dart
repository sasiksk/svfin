import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/Utilities/AppBar.dart';
import 'package:svf/Utilities/CustomDatePicker.dart';
import 'package:svf/Utilities/CustomTextField.dart';
import 'package:svf/finance_provider.dart';
import 'package:intl/intl.dart';

class LendingCombinedDetailsScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amtGivenController = TextEditingController();
  final TextEditingController _profitController = TextEditingController();
  final TextEditingController _totalController = TextEditingController();
  final TextEditingController _lentDateController = TextEditingController();
  final TextEditingController _dueDaysController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  void _updateLending(BuildContext context, String lineName, String partyName,
      int lentid) async {
    if (_formKey.currentState?.validate() == true) {
      try {
        final double amtGiven = double.parse(_amtGivenController.text);
        final double profit = double.parse(_profitController.text);
        final double total = double.parse(_totalController.text);

        final updatedValues = {
          'LenId': lentid,
          'amtgiven': amtGiven,
          'profit': profit,
          'total': total,
          'Lentdate': _lentDateController.text,
          'duedays': int.parse(_dueDaysController.text),
          'duedate': _dueDateController.text,
          'amtcollected': 0.0,
          'DueAmt': total,
          'Daysrem': int.parse(_dueDaysController.text),
          'status': 'active',
        };

        await dbLending.updateLending(
          lineName: lineName,
          partyName: partyName,
          lenId: lentid,
          updatedValues: updatedValues,
        );

        // Fetch existing values from the Line table
        final db = await DatabaseHelper.getDatabase();
        final List<Map<String, dynamic>> existingEntries = await db.query(
          'Line',
          where: 'LOWER(Linename) = ?',
          whereArgs: [lineName.toLowerCase()],
        );

        if (existingEntries.isNotEmpty) {
          final existingEntry = existingEntries.first;
          final double existingAmtGiven = existingEntry['Amtgiven'];
          final double existingProfit = existingEntry['Profit'];
          final double existingTotalAmt = existingEntry['TotalAmt'];

          // Add new values to existing values
          final double newAmtGiven = existingAmtGiven + amtGiven;
          final double newProfit = existingProfit + profit;
          final double newTotalAmt = existingTotalAmt + total;

          // Update the Line table with new values
          await dbline.updateLineAmounts(
            lineName: lineName,
            amtGiven: newAmtGiven,
            profit: newProfit,
            totalAmt: newTotalAmt,
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lending details updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating lending details: $e')),
        );
      }
    }
  }

  void _calculateTotal() {
    final amtGiven = double.tryParse(_amtGivenController.text) ?? 0.0;
    final profit = double.tryParse(_profitController.text) ?? 0.0;
    final total = amtGiven + profit;
    _totalController.text = total.toString();
  }

  void _calculateDueDate() {
    final lentDate = DateTime.tryParse(_lentDateController.text);
    final dueDays = int.tryParse(_dueDaysController.text) ?? 0;
    if (lentDate != null) {
      final dueDate = lentDate.add(Duration(days: dueDays));
      _dueDateController.text = DateFormat('yyyy-MM-dd').format(dueDate);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lineName = ref.watch(currentLineNameProvider);
    final partyName = ref.watch(currentPartyNameProvider);

    // final Int lenId = ref.watch(lenIdProvider as ProviderListenable<Int>);

    return Scaffold(
      appBar: CustomAppBar(
        title: "Lending to - ${partyName ?? ''}",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Financial Details Form Section
                Text(
                  "Financial Details",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _amtGivenController,
                  decoration: InputDecoration(
                    labelText: "Amount Given",
                    hintText: "Enter the amount given",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the amount given';
                    }
                    return null;
                  },
                  onChanged: (value) => _calculateTotal(),
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _profitController,
                  decoration: InputDecoration(
                    labelText: "Profit",
                    hintText: "Enter the profit",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the profit';
                    }
                    return null;
                  },
                  onChanged: (value) => _calculateTotal(),
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: _totalController,
                  labelText: "Total",
                  hintText: "Enter the total",
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the total';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 10),
                CustomDatePicker(
                  controller: _lentDateController,
                  labelText: "Lent Date",
                  hintText: "Pick a lent date",
                ),
                SizedBox(height: 10),
                TextFormField(
                  controller: _dueDaysController,
                  decoration: InputDecoration(
                    labelText: "Due Days",
                    hintText: "Enter the due days",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the due days';
                    }
                    return null;
                  },
                  onChanged: (value) => _calculateDueDate(),
                ),
                SizedBox(height: 10),
                CustomTextField(
                  controller: _dueDateController,
                  labelText: "Due Date",
                  hintText: "Due date will be calculated",
                  readOnly: true,
                ),
                SizedBox(height: 20),

                // Submit Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() == true) {
                        DatabaseHelper.getLenId(lineName!, partyName!)
                            .then((lenid) {
                          if (lenid != null) {
                            final lenStatus = ref.read(lenStatusProvider);
                            if (lenStatus == 'passive') {
                              _updateLending(
                                  context, lineName, partyName, lenid);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Form Submitted')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Error: Cannot lend amount to active state party')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: LenId is null')),
                            );
                          }
                        });
                      }
                    },
                    child: Text("Submit"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
