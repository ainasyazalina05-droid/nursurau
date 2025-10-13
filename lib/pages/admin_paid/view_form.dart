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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Form diluluskan.")),
    );

    Navigator.pop(context);
  }

  Future<void> _rejectForm(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("form")
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Form ditolak & dipadam.")),
    );

    Navigator.pop(context);
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
            body: Center(child: Text("Form tidak dijumpai.")),
          );
        }

        var data = snapshot.data!.data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Maklumat Pendaftaran"),
            backgroundColor: Colors.green,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Maklumat Surau",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Nama Surau: ${data['surauName'] ?? '-'}"),
                  Text("Alamat: ${data['address'] ?? '-'}"),
                  const SizedBox(height: 20),
                  const Text("Maklumat AJK",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Nama AJK: ${data['ajkName'] ?? '-'}"),
                  Text("Emel: ${data['email'] ?? '-'}"),
                  Text("Telefon: ${data['phone'] ?? '-'}"),
                  Text("No. IC: ${data['ic'] ?? '-'}"),
                  const SizedBox(height: 20),
                  Text("Status: ${data['status'] ?? 'pending'}",
                      style: TextStyle(
                        color: data['status'] == 'approved'
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      )),
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
                        child: const Text("Lulus",
                            style: TextStyle(color: Colors.white)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => _rejectForm(context),
                        child: const Text("Tolak",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
