// surau_details_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SurauDetailsPage extends StatefulWidget {
  final String surauName;

  const SurauDetailsPage({super.key, required this.surauName});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  // --- Edit main fields (nama, lokasi, kapasiti) ---
  Future<void> _editField(String title, String currentValue, String fieldKey) async {
    final controller = TextEditingController(text: currentValue);

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
                fieldKey: controller.text,
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

  // --- Add new sub-entry (title, description, optional image) ---
  Future<void> _addSubEntry() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    File? imageFile;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: const Text("Tambah Maklumat Baru"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Tajuk"),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: "Keterangan"),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                  onPressed: () async {
                    final picked = await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setStateDialog(() => imageFile = File(picked.path));
                    }
                  },
                ),
                if (imageFile != null) Image.file(imageFile!, height: 120),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () async {
                String? imageUrl;
                if (imageFile != null) {
                  final ref = FirebaseStorage.instance
                      .ref("surau_sub_entries/${DateTime.now().millisecondsSinceEpoch}.jpg");
                  await ref.putFile(imageFile!);
                  imageUrl = await ref.getDownloadURL();
                }

                await _firestore
                    .collection("surauDetails")
                    .doc("main")
                    .collection("subEntries")
                    .add({
                  "title": titleController.text,
                  "description": descController.text,
                  "imageUrl": imageUrl,
                  "createdAt": DateTime.now().toIso8601String(),
                });

                await _firestore.collection("surauDetails").doc("main").update({
                  "tarikhKemaskini": DateTime.now().toIso8601String(),
                });

                if (mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- Reusable card untuk main fields ---
  Widget buildMainCard(String title, String value, String fieldKey) {
    return Card(
      color: const Color(0xFFF5EFD1),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.green),
          onPressed: () => _editField(title, value, fieldKey),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      appBar: AppBar(
        title: Text("Butiran Surau: ${widget.surauName}"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("surauDetails").doc("main").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Belum ada maklumat, sila tambah."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final tarikhKemaskini = data["tarikhKemaskini"] != null
              ? "${DateTime.parse(data["tarikhKemaskini"]).day}-${DateTime.parse(data["tarikhKemaskini"]).month}-${DateTime.parse(data["tarikhKemaskini"]).year}"
              : "-";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (data["imageUrl"] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(data["imageUrl"], height: 200, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),

              buildMainCard("Nama Surau", data["namaSurau"] ?? "-", "namaSurau"),
              buildMainCard("Lokasi", data["lokasi"] ?? "-", "lokasi"),
              buildMainCard("Kapasiti", data["kapasiti"] ?? "-", "kapasiti"),

              const SizedBox(height: 12),
              const Text("Maklumat Tambahan:", style: TextStyle(fontWeight: FontWeight.bold)),

              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("surauDetails")
                    .doc("main")
                    .collection("subEntries")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, subSnapshot) {
                  if (!subSnapshot.hasData || subSnapshot.data!.docs.isEmpty) {
                    return const Text("Tiada maklumat tambahan.");
                  }
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
                              if (subData["description"] != null)
                                Text(subData["description"]),
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
              Text("Tarikh Kemaskini: $tarikhKemaskini"),
            ],
          );
        },
      ),
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
          label: const Text("Tambah Butiran Baru", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
