import 'package:flutter/material.dart';

class CustomDatePicker extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;

  CustomDatePicker({
    required this.controller,
    required this.labelText,
    required this.hintText,
  });

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        border: OutlineInputBorder(),
      ),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (pickedDate != null) {
          setState(() {
            _selectedDate = pickedDate;
            widget.controller.text =
                "${pickedDate.toLocal()}".split(' ')[0]; // Format as yyyy-MM-dd
          });
        }
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please pick a date';
        }
        return null;
      },
    );
  }
}
