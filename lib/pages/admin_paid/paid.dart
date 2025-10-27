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
  String selectedStatus = "Pending"; // Default filter

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
      debugPrint("Error fetching AJK name for $docId: $e");
      return "-";
    }
  }

  Stream<QuerySnapshot> _getStream() {
    final forms = FirebaseFirestore.instance.collection("form");
    if (selectedStatus == "All") {
      return forms.snapshots();
    }
    return forms
        .where("status", isEqualTo: selectedStatus.toLowerCase())
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "OFFICER DASHBOARD",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2E7D32),
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔽 Dropdown Filter
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedStatus,
                    dropdownColor: Colors.white,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                    items: const ['All', 'Pending', 'Approved', 'Rejected']
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedStatus = value);
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),

            // 📋 Data List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _getStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No $selectedStatus applications found.",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;
                      final status =
                          (data["status"] ?? "pending").toString().toLowerCase();

                      return FutureBuilder<String>(
                        future: _getAjkName(docId),
                        builder: (context, ajkSnapshot) {
                          final ajkName = ajkSnapshot.data ?? "-";

                          return Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: Colors.green.shade100,
                                width: 1,
                              ),
                            ),
                            elevation: 2,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Icon(
                                status == "approved"
                                    ? Icons.mosque
                                    : Icons.pending_actions,
                                color: const Color(0xFF2E7D32),
                                size: 32,
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
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  status == "approved" ? "View" : "Manage",
                                  style: const TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => status == "approved"
                                          ? SurauDetailsPage(ajkId: docId)
                                          : ManageSurauPage(docId: docId),
                                    ),
                                  );
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
