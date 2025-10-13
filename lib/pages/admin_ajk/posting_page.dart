import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({super.key, required String surauId, required String ajkId});

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  Future<void> _editPost(DocumentSnapshot? docSnapshot) async {
    final data = docSnapshot?.data() as Map<String, dynamic>?;
    final docId = docSnapshot?.id;

    final titleController = TextEditingController(text: data?['title']);
    final contentController = TextEditingController(text: data?['content']);
    File? imageFile;
    String? imageUrl = data?['imageUrl'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(docId == null ? "Tambah Posting" : "Kemaskini Posting"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Tajuk"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: "Kandungan"),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.image),
                  label: const Text("Pilih Gambar"),
                  onPressed: () async {
                    final picked =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setStateDialog(() => imageFile = File(picked.path));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 135, 172, 79),
                  ),
                ),
                const SizedBox(height: 8),
                if (imageFile != null)
                  Image.file(imageFile!, height: 120)
                else if (imageUrl != null)
                  Image.network(imageUrl!, height: 120),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Upload new image if selected
                if (imageFile != null) {
                  final ref = FirebaseStorage.instance.ref(
                      "post_images/${DateTime.now().millisecondsSinceEpoch}.png");
                  await ref.putFile(imageFile!);
                  imageUrl = await ref.getDownloadURL();
                }

                if (docId != null) {
                  // Update existing post
                  await _firestore.collection("posts").doc(docId).update({
                    "title": titleController.text,
                    "content": contentController.text,
                    "imageUrl": imageUrl,
                    "updatedAt": DateTime.now().toIso8601String(),
                  });
                } else {
                  // Add new post
                  await _firestore.collection("posts").add({
                    "title": titleController.text,
                    "content": contentController.text,
                    "imageUrl": imageUrl,
                    "createdAt": DateTime.now().toIso8601String(),
                  });
                }

                if (mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 135, 172, 79),
              ),
              child: const Text("Simpan"),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostCard(DocumentSnapshot docSnapshot) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    final createdAt = DateTime.parse(
        data["createdAt"] ?? DateTime.now().toIso8601String());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color.fromARGB(255, 135, 172, 79),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & edit button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data["title"] ?? "",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _editPost(docSnapshot),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 135, 172, 79),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    "Kemaskini",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Image
            if (data["imageUrl"] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  data["imageUrl"],
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 8),
            // Content
            Text("Kandungan: ${data["content"] ?? ""}"),
            const SizedBox(height: 4),
            // Date
            Text(
              "Tarikh: ${createdAt.day}-${createdAt.month}-${createdAt.year}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Senarai Posting",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.normal, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection("posts")
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("Belum ada posting, sila tambah."),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, index) => buildPostCard(docs[index]),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 135, 172, 79),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _editPost(null),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Tambah Posting",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
