import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
=======
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
>>>>>>> 2261b72136d0326c96e4a6aca6287c35867fab14

class SurauDetailsPage extends StatefulWidget {
  const SurauDetailsPage({super.key});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
<<<<<<< HEAD
  // Function untuk tambah details baru
  void _addDetail() {
    final titleController = TextEditingController();
    final valueController = TextEditingController();
=======
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  // --- Edit main fields individually ---
  Future<void> _editField(String title, String currentValue, Map<String, dynamic> data) async {
    final controller = TextEditingController(text: currentValue);
>>>>>>> 2261b72136d0326c96e4a6aca6287c35867fab14

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Kemaskini $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection("surauDetails").doc("main").update({
                if (title == "Nama Surau") "namaSurau": controller.text,
                if (title == "Lokasi") "lokasi": controller.text,
                if (title == "Kapasiti") "kapasiti": controller.text,
                "tarikhKemaskini": DateTime.now().toIso8601String(),
              });
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // --- Add new sub-entry (title, description, image) ---
  Future<void> _addSubEntry() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    File? imageFile;

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Tambah Maklumat Baru"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Tajuk")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Keterangan"), maxLines: 3),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pilih Gambar"),
                onPressed: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null && mounted) setState(() => imageFile = File(picked.path));
                },
              ),
              if (imageFile != null) Image.file(imageFile!, height: 120),
            ],
          ),
<<<<<<< HEAD
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
=======
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              String? imageUrl;
              if (imageFile != null) {
                final ref = FirebaseStorage.instance
                    .ref("surau_sub_entries/${DateTime.now().millisecondsSinceEpoch}.jpg");
                await ref.putFile(imageFile!);
                imageUrl = await ref.getDownloadURL();
              }

              await _firestore.collection("surauDetails").doc("main")
                  .collection("subEntries").add({
                "title": titleController.text,
                "description": descController.text,
                "imageUrl": imageUrl,
                "createdAt": DateTime.now().toIso8601String(),
              });

              // Update main doc's tarikhKemaskini automatically
              await _firestore.collection("surauDetails").doc("main").update({
                "tarikhKemaskini": DateTime.now().toIso8601String(),
              });

              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  // --- Build main detail card ---
  Widget buildDetailCard(String title, String value, Map<String, dynamic> data) {
    return Card(
      color: const Color(0xFFF5EFD1),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.green),
          onPressed: () => _editField(title, value, data),
        ),
      ),
>>>>>>> 2261b72136d0326c96e4a6aca6287c35867fab14
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
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
=======
      appBar: AppBar(title: const Text("Maklumat Surau")),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("surauDetails").doc("main").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Belum ada maklumat, sila tambah."));
          }
>>>>>>> 2261b72136d0326c96e4a6aca6287c35867fab14

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // Format tarikh kemaskini
          final tarikhKemaskini =
              "${DateTime.parse(data["tarikhKemaskini"]).day}-${DateTime.parse(data["tarikhKemaskini"]).month}-${DateTime.parse(data["tarikhKemaskini"]).year}";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Main surau image
              if (data["imageUrl"] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(data["imageUrl"], height: 200, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),

              // Main fields
              buildDetailCard("Nama Surau", data["namaSurau"], data),
              buildDetailCard("Lokasi", data["lokasi"], data),
              buildDetailCard("Kapasiti", data["kapasiti"], data),

              const SizedBox(height: 12),

              // --- Sub-entries ---
              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("surauDetails")
                    .doc("main")
                    .collection("subEntries")
                    .orderBy("createdAt", descending: true) // newest on top
                    .snapshots(), // <--- add this!
                builder: (context, subSnapshot) {
                  if (!subSnapshot.hasData || subSnapshot.data!.docs.isEmpty) return const SizedBox();
                  final docs = subSnapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) {
                      final subData = doc.data()! as Map<String, dynamic>;
                      return Card(
                        color: const Color(0xFFF5EFD1),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(subData["title"] ?? ""),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subData["description"] != null) Text(subData["description"]),
                              if (subData["imageUrl"] != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Image.network(subData["imageUrl"], height: 120),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),


              const SizedBox(height: 10),

              // Tarikh Kemaskini fixed at bottom
              Text(
                "Tarikh Kemaskini: $tarikhKemaskini",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          );
        },
      ),
      // --- Bottom button only adds sub-entry ---
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _addSubEntry,
          icon: const Icon(Icons.add, color: Colors.white),
<<<<<<< HEAD
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
=======
          label: const Text("Tambah Maklumat Baru", style: TextStyle(color: Colors.white)),
>>>>>>> 2261b72136d0326c96e4a6aca6287c35867fab14
        ),
      ),
    );
  }
}
