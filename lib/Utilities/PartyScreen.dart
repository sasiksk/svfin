import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/Utilities/CustomTextField.dart';
import 'package:svf/finance_provider.dart';

class PartyScreen extends ConsumerStatefulWidget {
  final String? partyName;
  final String? partyPhoneNumber;
  final String? address;

  PartyScreen({
    this.partyName,
    this.partyPhoneNumber,
    this.address,
  });

  @override
  _PartyScreenState createState() => _PartyScreenState();
}

class _PartyScreenState extends ConsumerState<PartyScreen> {
  final TextEditingController _partyidController = TextEditingController();
  final TextEditingController _partyNameController = TextEditingController();
  final TextEditingController _partyPhoneNumberController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late String _lineName;

  @override
  void initState() {
    super.initState();
    _lineName = ref.read(currentLineNameProvider.state).state ?? '';
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _partyPhoneNumberController.dispose();
    _addressController.dispose();
    _partyidController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _partyNameController.clear();
    _partyPhoneNumberController.clear();
    _partyidController.clear();
    _addressController.clear();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        await dbLending.insertParty(
          lenId: int.parse(_partyidController.text),
          lineName: _lineName,
          partyName: _partyNameController.text,
          partyPhoneNumber: _partyPhoneNumberController.text,
          address: _addressController.text,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Party added successfully')),
        );
        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Party Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 16.0),
                Text(
                  'Line Name: $_lineName',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _partyidController,
                  labelText: 'Party id',
                  hintText: 'Enter a unique Party id',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Party Id';
                    }
                    return null;
                  },
                ),
                CustomTextField(
                  controller: _partyNameController,
                  labelText: 'Party Name',
                  hintText: 'Enter Party Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Party Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _partyPhoneNumberController,
                  labelText: 'Party Phone Number',
                  hintText: 'Enter Party Phone Number',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Party Phone Number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Address',
                  hintText: 'Enter Address',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _submitForm();
                          }
                        },
                        child: Text('Submit'),
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _resetForm,
                        child: Text('Reset'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
