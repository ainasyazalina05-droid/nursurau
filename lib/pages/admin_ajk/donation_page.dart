import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class DonationAdminPage extends StatefulWidget {
  final String ajkId; // Only need AJK ID now

  const DonationAdminPage({super.key, required this.ajkId, required String surauName});

  @override
  State<DonationAdminPage> createState() => _DonationAdminPageState();
}

class _DonationAdminPageState extends State<DonationAdminPage> {
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  Future<void> _editDonation(DocumentSnapshot? docSnapshot) async {
    final data = docSnapshot?.data() as Map<String, dynamic>?;
    final docId = docSnapshot?.id;

    final titleController = TextEditingController(text: data?['title']);
    final amountController = TextEditingController(text: data?['amount']);
    final descriptionController = TextEditingController(text: data?['description']);
    final accountController = TextEditingController(text: data?['account']);
    final contactController = TextEditingController(text: data?['contact']);
    File? qrFile;
    String? qrUrl = data?['qrUrl'];

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(docId == null ? "Tambah Derma" : "Kemaskini Derma"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Judul Derma"),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Jumlah Sasaran (RM)"),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: "Keterangan"),
                maxLines: 3,
              ),
              TextField(
                controller: accountController,
                decoration: const InputDecoration(labelText: "No Akaun"),
              ),
              TextField(
                controller: contactController,
                decoration: const InputDecoration(labelText: "No Telefon AJK"),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                icon: const Icon(Icons.qr_code, color: Colors.white),
                label: const Text("Pilih QR", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  final picked = await _picker.pickImage(source: ImageSource.gallery);
                  if (picked != null && mounted) {
                    setState(() => qrFile = File(picked.path));
                  }
                },
              ),
              const SizedBox(height: 8),
              if (qrFile != null)
                Image.file(qrFile!, height: 120)
              else if (qrUrl != null && qrUrl!.isNotEmpty)
                Image.network(qrUrl!, height: 120)
              else
                const Text("Tiada QR dipilih"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (mounted) Navigator.pop(ctx);
            },
            child: const Text("Batal", style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () async {
              try {
                if (titleController.text.trim().isEmpty ||
                    amountController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty ||
                    accountController.text.trim().isEmpty ||
                    contactController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sila isi semua ruangan wajib."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (double.tryParse(amountController.text.trim()) == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Jumlah sasaran mesti dalam nombor."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                if (qrFile != null) {
                  final ref = FirebaseStorage.instance.ref(
                    "donation_qr/${DateTime.now().millisecondsSinceEpoch}.png",
                  );
                  await ref.putFile(qrFile!);
                  qrUrl = await ref.getDownloadURL();
                }

                final donationData = {
                  "title": titleController.text.trim(),
                  "amount": amountController.text.trim(),
                  "description": descriptionController.text.trim(),
                  "account": accountController.text.trim(),
                  "contact": contactController.text.trim(),
                  "qrUrl": qrUrl ?? "",
                  "ajkId": widget.ajkId,
                  "createdAt": FieldValue.serverTimestamp(),
                };

                final donationRef = _firestore
                    .collection("form")
                    .doc(widget.ajkId) // ✅ Use AJK ID as the document
                    .collection("donations");

                if (docId != null) {
                  await donationRef.doc(docId).update(donationData);
                } else {
                  await donationRef.add(donationData);
                }

                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Maklumat derma berjaya disimpan."),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Ralat: ${e.toString()}"),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget buildDonationCard(DocumentSnapshot docSnapshot) {
    final data = docSnapshot.data() as Map<String, dynamic>;
    final Timestamp? createdAtTs = data["createdAt"];
    final createdAt = createdAtTs != null ? createdAtTs.toDate() : DateTime.now();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 135, 172, 79), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    data["title"] ?? "",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _editDonation(docSnapshot),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 135, 172, 79),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text(
                    "Kemaskini",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (data["qrUrl"] != null && data["qrUrl"].toString().isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(data["qrUrl"], height: 150, fit: BoxFit.cover),
              ),
            const SizedBox(height: 8),
            Text("Jumlah Sasaran: RM ${data["amount"] ?? ""}"),
            Text("Keterangan: ${data["description"] ?? ""}"),
            Text("No Akaun: ${data["account"] ?? ""}"),
            Text("No Telefon AJK: ${data["contact"] ?? ""}"),
            Text(
              "Tarikh Cipta: ${createdAt.day}-${createdAt.month}-${createdAt.year}",
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final donationRef = _firestore
        .collection("form")
        .doc(widget.ajkId)
        .collection("donations")
        .orderBy("createdAt", descending: true);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Senarai Derma", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: donationRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Belum ada maklumat, sila tambah."));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, index) => buildDonationCard(docs[index]),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 135, 172, 79),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _editDonation(null),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tambah Derma", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}
