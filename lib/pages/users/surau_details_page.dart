import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailsPage extends StatefulWidget {
  final String surauName;
  const SurauDetailsPage({super.key, required this.surauName});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  final _firestore = FirebaseFirestore.instance;
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    const Color deepGreen = Color(0xFF2F5D50);
    const Color cardGreen = Color(0xFF2F7D66);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surauName),
        backgroundColor: deepGreen,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isFollowing = !isFollowing;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFollowing
                          ? "You followed this surau!"
                          : "You unfollowed this surau!",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isFollowing ? Colors.grey[600] : Colors.orangeAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              child: Text(isFollowing ? "Following" : "Follow"),
            ),
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("surauDetails").doc("main").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Belum ada maklumat, sila tambah."));
          }

          final data = snapshot.data!.data()! as Map<String, dynamic>;

          // Format tarikh kemaskini
          final tarikhKemaskini =
              "${DateTime.parse(data["tarikhKemaskini"]).day}-${DateTime.parse(data["tarikhKemaskini"]).month}-${DateTime.parse(data["tarikhKemaskini"]).year}";

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // About Surau Card
                  Container(
                    decoration: BoxDecoration(
                      color: cardGreen,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Color(0x33000000), offset: Offset(0, 6), blurRadius: 10),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                            decoration: BoxDecoration(
                              color: deepGreen,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                widget.surauName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.7,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (data["imageUrl"] != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Image.network(
                                  data["imageUrl"],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          const SizedBox(height: 18),
                          _InfoRow(label: 'ALAMAT', value: data["lokasi"] ?? "-"),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'NO TELEFON', value: data["noTelefon"] ?? "-"),
                          const SizedBox(height: 10),
                          _InfoRow(label: 'NADZIR', value: data["nadzir"] ?? "-"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Posts Section
                  const Text(
                    "Posting",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: deepGreen),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection("surauDetails")
                        .doc("main")
                        .collection("subEntries")
                        .orderBy("createdAt", descending: true)
                        .snapshots(),
                    builder: (context, postSnapshot) {
                      if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                        return const Text("Tiada posting untuk ditunjukkan.");
                      }

                      final docs = postSnapshot.data!.docs;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final post = docs[index].data()! as Map<String, dynamic>;
                          return _buildPost(
                            title: post["title"] ?? "",
                            image: post["imageUrl"] ?? "",
                            description: post["description"] ?? "",
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 10),
                  Text(
                    "Tarikh Kemaskini: $tarikhKemaskini",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPost({
    required String title,
    required String image,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(2, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(12), child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.network(image, fit: BoxFit.cover),
            ),
          Padding(padding: const EdgeInsets.all(12), child: Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87))),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 4, child: Text('$label :', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, height: 1.4))),
        Expanded(flex: 7, child: Text(value, style: const TextStyle(color: Colors.white, height: 1.4, fontWeight: FontWeight.w500))),
      ],
    );
  }
}
