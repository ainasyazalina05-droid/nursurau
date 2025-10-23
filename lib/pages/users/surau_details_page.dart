import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'follow_service.dart';

class SurauDetailsPage extends StatefulWidget {
  final String surauId;
  const SurauDetailsPage({super.key, required this.surauId});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  bool _isFollowed = false;

  @override
  void initState() {
    super.initState();
    _checkFollowed();
  }

  Future<void> _checkFollowed() async {
    final followed = await FollowService.isFollowedById(widget.surauId);
    setState(() => _isFollowed = followed);
  }

  Future<void> _toggleFollow() async {
    await FollowService.toggleFollowById(widget.surauId);
    _checkFollowed();
  }

  @override
  Widget build(BuildContext context) {
    final surauRef = FirebaseFirestore.instance.collection('suraus').doc(widget.surauId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maklumat Surau'),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: surauRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) return const Center(child: Text("Surau tidak ditemui"));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Surau Image
                if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data['imageUrl'],
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.mosque, size: 80),
                    ),
                  )
                else
                  const Icon(Icons.mosque, size: 80, color: Colors.green),
                const SizedBox(height: 12),

                // Name & Follow
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['name'] ?? '', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: Icon(_isFollowed ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                      onPressed: _toggleFollow,
                    ),
                  ],
                ),

                // Address & Nazir
                Text(data['address'] ?? ''),
                const SizedBox(height: 4),
                Text("Nazir: ${data['nazirName'] ?? ''}"),
                Text("Tel: ${data['nazirPhone'] ?? ''}"),
                const Divider(height: 20),

                // 🔹 Posts
                const Text("Posting Surau", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('surauId', isEqualTo: widget.surauId)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, postSnap) {
                    if (!postSnap.hasData) return const CircularProgressIndicator();
                    final posts = postSnap.data!.docs;
                    if (posts.isEmpty) return const Text("Tiada posting setakat ini");

                    return Column(
                      children: posts.map((doc) {
                        final p = doc.data() as Map<String, dynamic>;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(p['description'] ?? ''),
                                if (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        p['imageUrl'],
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Text(
                                  p['timestamp'] != null
                                      ? (p['timestamp'] as Timestamp).toDate().toString()
                                      : '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
