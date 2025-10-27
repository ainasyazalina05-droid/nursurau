import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';
import '../admin_ajk/surau_details_page.dart';

class AdminPaidPage extends StatefulWidget {
  const AdminPaidPage({super.key});

  @override
  State<AdminPaidPage> createState() => _AdminPaidPageState();
}

class _AdminPaidPageState extends State<AdminPaidPage> {
  String selectedStatus = "Pending"; // default filter

  Future<String> _getAjkName(String docId) async {
    try {
      final ajkDoc = await FirebaseFirestore.instance
          .collection("form")
          .doc(docId)
          .collection("ajk")
          .doc("ajk_data")
          .get();

      return ajkDoc.data()?["ajkName"] ?? "-";
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OFFICER DASHBOARD"),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Dropdown filter
            DropdownButton<String>(
              value: selectedStatus,
              items: ['All', 'Pending', 'Approved', 'Rejected']
                  .map((s) => DropdownMenuItem(
                        value: s,
                        child: Text(s),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: selectedStatus == "All"
                    ? FirebaseFirestore.instance.collection("form").snapshots()
                    : FirebaseFirestore.instance
                        .collection("form")
                        .where("status",
                            isEqualTo: selectedStatus.toLowerCase())
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text("No $selectedStatus applications."),
                    );
                  }

                  var docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      var docId = docs[index].id;
                      var status =
                          (data["status"] ?? "pending").toString().toLowerCase();

                      return FutureBuilder<String>(
                        future: _getAjkName(docId),
                        builder: (context, ajkSnapshot) {
                          String ajkName = ajkSnapshot.data ?? "-";

                          return Card(
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: Icon(
                                status == "approved"
                                    ? Icons.mosque
                                    : Icons.pending_actions,
                                color: const Color(0xFF2E7D32),
                                size: 30,
                              ),
                              title: Text(
                                data["surauName"] ?? "No name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                  fontSize: 16,
                                ),
                              ),
                              subtitle: Text("AJK: $ajkName"),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                ),
                                child: Text(
                                  status == "approved"
                                      ? "View Details"
                                      : "Manage",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onPressed: () async {
                                  if (status == "approved") {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            SurauDetailsPage(ajkId: docId),
                                      ),
                                    );
                                  } else {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ManageSurauPage(docId: docId),
                                      ),
                                    );
                                    if (result == true) {
                                      // StreamBuilder auto-refreshes
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
