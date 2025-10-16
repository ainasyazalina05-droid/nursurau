import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'view_form.dart';

class AdminPaidPage extends StatelessWidget {
  const AdminPaidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFFAF8F0),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Color(0xFF2E7D32)),
        ),
      ),
      child: const OfficerDashboard(),
    );
  }
}

class OfficerDashboard extends StatelessWidget {
  const OfficerDashboard({super.key});

  Future<String> _getAjkName(String docId) async {
    try {
      final ajkDoc = await FirebaseFirestore.instance
          .collection("form")
          .doc(docId)
          .collection("ajk")
          .doc("ajk_data")
          .get();

      if (ajkDoc.exists) {
        return ajkDoc.data()?["ajkName"] ?? "-";
      } else {
        return "-";
      }
    } catch (e) {
      return "-";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("OFFICER DASHBOARD")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pending Surau AJK Applications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("form")
                    .where("status", isEqualTo: "pending")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text("No pending applications."));
                  }

                  var docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      var docId = docs[index].id;

                      return FutureBuilder<String>(
                        future: _getAjkName(docId),
                        builder: (context, ajkSnapshot) {
                          String ajkName = ajkSnapshot.data ?? "-";

                          return Card(
                            color: const Color(0xFFF5F2E7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.pending_actions,
                                  color: Color(0xFF2E7D32)),
                              title: Text(
                                data["surauName"] ?? "No name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              subtitle: Text("AJK: $ajkName"),
                              trailing: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E7D32),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  "View Form",
                                  style: TextStyle(color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ViewForm(docId: docId),
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
