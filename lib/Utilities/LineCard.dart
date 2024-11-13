import 'package:flutter/material.dart';

class LineCard extends StatelessWidget {
  final String lineName;
  final double screenWidth;
  final VoidCallback onLineSelected;

  LineCard({
    required this.lineName,
    required this.screenWidth,
    required this.onLineSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onLineSelected, // Correctly invoke the callback
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10.0),
        width: screenWidth - 40, // Full width minus padding (20 on each side)
        child: Card(
          elevation: 10.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Rounded corners
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                colors: [
                  Colors.teal.shade400,
                  Colors.teal.shade900,
                ], // Gradient background
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(
                  20.0), // Increased padding for consistency
              child: Text(
                lineName,
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text color
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
