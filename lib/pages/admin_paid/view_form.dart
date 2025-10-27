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

    Navigator.pop(context, true);
  }

  Future<void> _rejectForm(BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("form")
        .doc(docId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Form ditolak & dipadam.")),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final formRef = FirebaseFirestore.instance.collection("form").doc(docId);
    final ajkRef = formRef.collection("ajk").doc("ajk_data");

    return FutureBuilder(
      future: Future.wait([formRef.get(), ajkRef.get()]),
      builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData ||
            !snapshot.data![0].exists ||
            !snapshot.data![1].exists) {
          return const Scaffold(
            body: Center(child: Text("Maklumat tidak dijumpai.")),
          );
        }

        var formData = snapshot.data![0].data() as Map<String, dynamic>;
        var ajkData = snapshot.data![1].data() as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Maklumat Pendaftaran"),
            backgroundColor: const Color(0xFF2E7D32),
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
                  Text("Nama Surau: ${formData['surauName'] ?? '-'}"),
                  Text("Alamat: ${formData['surauAddress'] ?? '-'}"),
                  const SizedBox(height: 20),

                  const Text("Maklumat AJK",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text("Nama AJK: ${ajkData['ajkName'] ?? '-'}"),
                  Text("No. IC: ${ajkData['ic'] ?? '-'}"),
                  Text("Emel: ${ajkData['email'] ?? '-'}"),
                  Text("Telefon: ${ajkData['phone'] ?? '-'}"),
                  const SizedBox(height: 20),

                  // ✅ Fixed: Status from main form document
                  Text(
                    "Status: ${formData['status'] ?? 'pending'}",
                    style: TextStyle(
                      color: formData['status'] == 'approved'
                          ? Colors.green
                          : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle, color: Colors.white),
                        label: const Text("Lulus",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => _approveForm(context),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.cancel, color: Colors.white),
                        label: const Text("Tolak",
                            style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => _rejectForm(context),
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
