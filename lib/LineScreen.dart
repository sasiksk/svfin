import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:svf/Data/Databasehelper.dart';
import 'package:svf/Utilities/CustomTextField.dart';
import 'package:svf/home_screen.dart';
import 'package:svf/Utilities/FloatingActionButtonWithText.dart';

class LineScreen extends StatefulWidget {
  final Map<String, dynamic>? entry; // Add this line

  LineScreen({this.entry}); // Update the constructor

  @override
  _LineScreenState createState() => _LineScreenState();
}

class _LineScreenState extends State<LineScreen> {
  final TextEditingController _lineNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.entry != null) {
      _lineNameController.text = widget.entry!['Linename'];
    }
  }

  @override
  void dispose() {
    _lineNameController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _lineNameController.clear();
  }

  void _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        if (widget.entry != null) {
          // Update existing entry in Line table
          await dbline.updateLine(
            lineName: widget.entry!['Linename'],
            updatedValues: {
              'Linename': _lineNameController.text,
            },
          );
          await dbline.updateLineNameInLending(
            oldLineName: widget.entry!['Linename'],
            newLineName: _lineNameController.text,
          );
          // Update LineName in Lending table

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Line entry updated successfully')),
          );
        } else {
          // Insert new entry
          await dbline.insertLine(
            _lineNameController.text,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Line entry added successfully')),
          );
        }
        _resetForm();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
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
          'Line Screen',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _lineNameController,
                labelText: 'Line Name',
                hintText: 'Enter Line Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Line Name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text(widget.entry != null ? 'Update' : 'Submit'),
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
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                },
                child: Text('Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
