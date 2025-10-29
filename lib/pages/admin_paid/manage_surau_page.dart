import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSurauPage extends StatefulWidget {
  final String docId;
  const ManageSurauPage({super.key, required this.docId});

  @override
  State<ManageSurauPage> createState() => _ManageSurauPageState();
}

class _ManageSurauPageState extends State<ManageSurauPage> {
  String surauName = "-";
  String address = "-";
  String ajkName = "-";
  String status = "-";

  @override
  void initState() {
    super.initState();
    _fetchFormData();
  }

  Future<void> _fetchFormData() async {
    var formData = await FirebaseFirestore.instance
        .collection("form")
        .doc(widget.docId)
        .get();

    var ajkData = await FirebaseFirestore.instance
        .collection("form")
        .doc(widget.docId)
        .collection("ajk")
        .doc("ajk_data")
        .get();

    setState(() {
      surauName = formData.data()?["surauName"] ?? "-";
      address = formData.data()?["address"] ?? "-";
      status = formData.data()?["status"] ?? "-";
      ajkName = ajkData.data()?["ajkName"] ?? "-";
    });
  }

  Future<void> updateStatus(String newStatus) async {
    await FirebaseFirestore.instance
        .collection("form")
        .doc(widget.docId)
        .update({"status": newStatus});

    setState(() => status = newStatus);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Surau")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Surau Name: $surauName",
                style: const TextStyle(fontSize: 18)),
            Text("Address: $address", style: const TextStyle(fontSize: 18)),
            Text("AJK Name: $ajkName", style: const TextStyle(fontSize: 18)),
            Text("Status: $status", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),

            if (status == "pending") ...[
              ElevatedButton(
                onPressed: () => updateStatus("approved"),
                child: const Text("Approve"),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => updateStatus("rejected"),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red),
                child: const Text("Reject"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
