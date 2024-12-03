import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/Utilities/CustomTextField.dart';
import 'package:svf/finance_provider.dart';
import 'package:svf/linedetailScreen.dart';

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

  bool _sms = false; // Default value for SMS

  @override
  void initState() {
    super.initState();

    _lineName = ref.read(currentLineNameProvider) ?? '';

    if (widget.partyName != null) {
      _loadPartyDetails();
    }
  }

  Future<void> _loadPartyDetails() async {
    final linename = ref.read(currentLineNameProvider);
    final partyName = ref.read(currentPartyNameProvider);
    final lenId = ref.read(lenIdProvider);

    if (lenId != null) {
      final partyDetails = await dbLending.getPartyDetails(lenId);
      if (partyDetails != null) {
        setState(() {
          _partyidController.text = partyDetails['LenId'].toString();
          _partyNameController.text = partyDetails['PartyName'];
          _partyPhoneNumberController.text = partyDetails['PartyPhnone'];
          _addressController.text = partyDetails['PartyAdd'];
          _sms = partyDetails['sms'] == 1;
        });
      }
    }
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
    setState(() {
      _sms = false; // Reset SMS to default value
    });
  }

  Future<void> _submitForm() async {
    final linename = ref.read(currentLineNameProvider);

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final lenId = int.parse(_partyidController.text);
        final partyDetails = {
          'LineName': _lineName,
          'PartyName': _partyNameController.text,
          'PartyPhnone': _partyPhoneNumberController.text,
          'PartyAdd': _addressController.text,
          'sms': _sms ? 1 : 0,
        };

        if (widget.partyName != null) {
          // Update existing entry
          await dbLending.updatePartyDetails(
            lineName: linename!,
            partyName: _partyNameController.text,
            lenId: lenId,
            updatedValues: partyDetails,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Party updated successfully')),
          );
        } else {
          // Insert new entry
          await dbLending.insertParty(
            lenId: lenId,
            lineName: _lineName,
            partyName: _partyNameController.text,
            partyPhoneNumber: _partyPhoneNumberController.text,
            address: _addressController.text,
            sms: _sms,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Party added successfully')),
          );
        }

        _resetForm();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LineDetailScreen()),
        );
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
                SizedBox(
                  height: 10,
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
                Text(
                  'SMS Notifications',
                  style: TextStyle(fontSize: 16.0),
                ),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('Yes'),
                        value: true,
                        groupValue: _sms,
                        onChanged: (value) {
                          setState(() {
                            _sms = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: Text('No'),
                        value: false,
                        groupValue: _sms,
                        onChanged: (value) {
                          setState(() {
                            _sms = value!;
                          });
                        },
                      ),
                    ),
                  ],
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
                        child: Text(
                            widget.partyName != null ? 'Update' : 'Submit'),
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
