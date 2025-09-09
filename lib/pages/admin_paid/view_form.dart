import 'package:flutter/material.dart';

class ViewForm extends StatelessWidget {
  final String surauName;
  final String ajkName;

  const ViewForm({super.key, required this.surauName, required this.ajkName});

  void _showApprovedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Surau AJK Approved!"),
        content: Text("Surau: $surauName\n👤 Admin: $ajkName"),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showRejectedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Surau AJK Rejected"),
        content: Text("Application for $surauName has been rejected."),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Form"),
        backgroundColor: const Color(0xFFFAF8F0), // Teal hijau macam design
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Surau Info",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Name: $surauName"),
            const Text("Address: Sungai Ayer Tawar, Sabak Bernam"),
            const Text("Contact: 03-12345678"),
            const SizedBox(height: 20),

            const Text("AJK Info",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Name: $ajkName"),
            Text("Email: $ajkName@mail.com"),
            const Text("Phone: 012-3456789"),
            const Text("IC: 900101-14-1234"),
            const SizedBox(height:30),

           // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => _showApprovedDialog(context),
                  child: const Text("Approve",
                      style: TextStyle(color: Colors.white)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  onPressed: () => _showRejectedDialog(context),
                  child: const Text("Reject",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}