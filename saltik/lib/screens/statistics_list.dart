import 'package:flutter/material.dart';

class StatisticListPage extends StatelessWidget {
  const StatisticListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistics List"),
        backgroundColor: Colors.grey,
      ),
      body: const Center(
        child: Text(
          "NOT YET FINISH UI!",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
