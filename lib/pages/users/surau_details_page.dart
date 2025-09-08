import 'package:flutter/material.dart';

class SurauDetailsPage extends StatelessWidget {
  final String surauName;
  const SurauDetailsPage({super.key, required this.surauName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(surauName)),
      body: Center(
        child: Text("Maklumat lanjut mengenai $surauName"),
      ),
    );
  }
}
