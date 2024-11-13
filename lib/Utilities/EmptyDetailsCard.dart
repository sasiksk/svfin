import 'package:flutter/material.dart';

class EmptyCard extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;
  final String title;
  final Widget content;

  EmptyCard({
    required this.screenHeight,
    required this.screenWidth,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10, left: 10, right: 10),
      height:
          screenHeight * 0.15, // Slightly increased height to avoid overflow
      width: screenWidth - 25, // Full width minus padding (20 on each side)
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
            padding: const EdgeInsets.all(20.0), // Increased padding
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align content to start
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.white, // White text color
                  ),
                ),
                SizedBox(height: 15), // Increased spacing for better layout
                DefaultTextStyle(
                  style: TextStyle(
                      color: Colors.white), // Set default text color to white
                  child: content, // Add content here
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
