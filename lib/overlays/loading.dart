import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  final String text = "Loading...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  "Developers:",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
                Text(
                  "April Mactal",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  "Cassandra Kaye Honrada",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  "Joseph 'Cutie' Tiglao",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
            Text(
              "Loading...",
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
