import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewForm extends StatelessWidget {
  final String docId;

  const ViewForm({super.key, required this.docId});

  Future<void> _approveForm(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("form")
        .doc(docId)
        .update({"status": "approved"});

    Navigator.pop(context); // balik ke dashboard
  }

  Future<void> _rejectForm(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("form")
        .doc(docId)
        .delete();

    Navigator.pop(context); // balik ke dashboard
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection("form").doc(docId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text("Form not found.")),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text("View Form"),
            backgroundColor: const Color(0xFFFAF8F0),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Surau Info",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Name: ${data['surauName'] ?? '-'}"),
                Text("Address: ${data['address'] ?? '-'}"),
                Text("Contact: ${data['contact'] ?? '-'}"),
                const SizedBox(height: 20),
                const Text("AJK Info",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text("Name: ${data['ajkName'] ?? '-'}"),
                Text("Email: ${data['email'] ?? '-'}"),
                Text("Phone: ${data['phone'] ?? '-'}"),
                Text("IC: ${data['ic'] ?? '-'}"),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => _approveForm(context),
                      child: const Text("Approve",
                          style: TextStyle(color: Colors.white)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                      ),
                      onPressed: () => _rejectForm(context),
                      child: const Text("Reject",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
