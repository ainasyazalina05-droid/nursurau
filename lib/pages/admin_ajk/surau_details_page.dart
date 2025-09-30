import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailsPage extends StatefulWidget {
  const SurauDetailsPage({super.key});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  // Function untuk tambah details baru
  void _addDetail() {
    final titleController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Butiran Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Tajuk"),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: "Butiran"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                if (titleController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  // 🔹 Simpan ke Firestore
                  await FirebaseFirestore.instance
                      .collection('surau_details')
                      .add({
                    "title": titleController.text,
                    "value": valueController.text,
                    "createdAt": FieldValue.serverTimestamp(),
                    "surauId": "surau1", // unik ID untuk setiap surau
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Butiran Surau (Admin)"),
        backgroundColor: Colors.green,
      ),

      // 🔹 Guna StreamBuilder untuk paparkan data Firestore
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('surau_details')
            .where("surauId", isEqualTo: "surau1") // tapis ikut surau
            .orderBy("createdAt", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada butiran surau lagi."));
          }

          final docs = snapshot.data!.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return buildDetailCard(data["title"], data["value"]);
            }).toList(),
          );
        },
      ),

      // 👉 Button paling bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _addDetail,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Tambah Butiran Baru",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget buildDetailCard(String title, String value) {
    return Card(
      color: const Color(0xFFF5EFD1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.info, color: Colors.green),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            // nanti boleh tambah edit function
          },
        ),
      ),
    );
  }
}
