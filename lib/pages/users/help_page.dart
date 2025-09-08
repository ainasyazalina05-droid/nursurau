import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Bantuan")),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          "Tutorial cara menggunakan aplikasi NurSurau.",
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
