import 'package:flutter/material.dart';

class FloatingActionButtonWithText extends StatelessWidget {
  final String label;
  final Widget navigateTo;
  final IconData? icon;
  final String? heroTag; // Optional heroTag

  const FloatingActionButtonWithText({
    super.key,
    required this.label,
    required this.navigateTo,
    this.icon,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => navigateTo),
        );
      },
      icon: icon != null ? Icon(icon) : null,
      label: Text(label),
      backgroundColor: Colors.teal,
      heroTag: heroTag, // Set the heroTag if provided
    );
  }
}
