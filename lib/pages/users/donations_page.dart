import 'package:flutter/material.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Donasi")),
      body: const Center(child: Text("Senarai program donasi tersedia.")),
    );
  }
}
