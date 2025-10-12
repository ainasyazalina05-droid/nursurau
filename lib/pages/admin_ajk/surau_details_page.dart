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

  // 🔧 Edit field in main surau info (nama, lokasi, kapasiti)
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 135, 172, 79),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🔧 Add or Edit Sub-Entry
  Future<void> _editSubEntry({DocumentSnapshot? doc}) async {
    final data = doc?.data() as Map<String, dynamic>?;

    final titleController = TextEditingController(text: data?['title'] ?? '');
    final descController = TextEditingController(text: data?['description'] ?? '');
    File? imageFile;
    String? existingImageUrl = data?['imageUrl'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(doc == null ? "Tambah Maklumat Baru" : "Kemaskini Maklumat"),
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
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text("Pilih Gambar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 135, 172, 79),
                  ),
                  onPressed: () async {
                    final picked = await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setStateDialog(() => imageFile = File(picked.path));
                    }
                  },
                ),
                if (imageFile != null)
                  Image.file(imageFile!, height: 120)
                else if (existingImageUrl != null)
                  Image.network(existingImageUrl, height: 120),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 135, 172, 79),
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                String? imageUrl = existingImageUrl;
                if (imageFile != null) {
                  final ref = FirebaseStorage.instance
                      .ref("surau_sub_entries/${DateTime.now().millisecondsSinceEpoch}.jpg");
                  await ref.putFile(imageFile!);
                  imageUrl = await ref.getDownloadURL();
                }

                if (doc == null) {
                  // Tambah baru
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
                } else {
                  // Kemaskini sedia ada
                  await _firestore
                      .collection("surauDetails")
                      .doc("main")
                      .collection("subEntries")
                      .doc(doc.id)
                      .update({
                    "title": titleController.text,
                    "description": descController.text,
                    "imageUrl": imageUrl,
                    "updatedAt": DateTime.now().toIso8601String(),
                  });
                }

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

  // 🧱 Main Info Card
  Widget buildMainCard(String title, String value, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 135, 172, 79), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))
        ],
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 135, 172, 79)),
          onPressed: () => _editField(title, value, fieldKey),
        ),
      ),
    );
  }

  // 🧱 Sub Info Card
  Widget buildSubCard(DocumentSnapshot doc) {
    final subData = doc.data()! as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 135, 172, 79), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))
        ],
      ),
      child: ListTile(
        title: Text(subData["title"] ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold)),
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
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 135, 172, 79)),
          onPressed: () => _editSubEntry(doc: doc),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Butiran Surau: ${widget.surauName}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
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
                  child:
                      Image.network(data["imageUrl"], height: 200, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),

              buildMainCard("Nama Surau", data["namaSurau"] ?? "-", "namaSurau"),
              buildMainCard("Lokasi", data["lokasi"] ?? "-", "lokasi"),
              buildMainCard("Kapasiti", data["kapasiti"] ?? "-", "kapasiti"),

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
                    children: docs.map((doc) => buildSubCard(doc)).toList(),
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
            backgroundColor: const Color.fromARGB(255, 135, 172, 79),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _editSubEntry(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tambah Butiran Baru",
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
