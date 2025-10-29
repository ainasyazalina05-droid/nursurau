import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';
import '../admin_ajk/surau_details_page.dart';

class AdminPaidPage extends StatefulWidget {
  final String filter;

  const AdminPaidPage({super.key, this.filter = "Pending"});

  @override
  State<AdminPaidPage> createState() => _AdminPaidPageState();
}

class _AdminPaidPageState extends State<AdminPaidPage> {
  String selectedStatus = "Pending";

  @override
  void initState() {
    super.initState();
    selectedStatus = widget.filter;
  }

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
      debugPrint("Error fetching AJK name: $e");
      return "-";
    }
  }

  Stream<QuerySnapshot> _getStream() {
    final forms = FirebaseFirestore.instance.collection("form");
    if (selectedStatus == "All") return forms.snapshots();
    return forms
        .where("status", isEqualTo: selectedStatus.toLowerCase())
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // ✅ makes back arrow white
        title: const Text(
          "OFFICER PAID DASHBOARD",
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
                          (data["status"] ?? "").toString().toLowerCase();

                      return FutureBuilder<String>(
                        future: _getAjkName(docId),
                        builder: (context, ajkSnapshot) {
                          final ajkName = ajkSnapshot.data ?? "-";

                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(data["surauName"] ?? "No name"),
                              subtitle: Text("AJK: $ajkName"),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
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
                                      builder: (_) =>
                                          SurauDetailsPage(ajkId: docId),
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
