import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/services/follow_service.dart';


class SurauDetailsPage extends StatefulWidget {
  final String ajkId; // 🔹 AJK ID digunakan untuk filter posting
  const SurauDetailsPage({super.key, required this.ajkId});

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
    final followed = await FollowService.isFollowedById(widget.ajkId);
    setState(() => _isFollowed = followed);
  }

  Future<void> _toggleFollow() async {
    await FollowService.toggleFollowById(widget.ajkId);
    final followed = await FollowService.isFollowedById(widget.ajkId);

    setState(() => _isFollowed = followed);

    // Show temporary popup/snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            followed ? "Anda kini mengikuti" : "Anda berhenti mengikuti",
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: followed ? Colors.green.shade600 : Colors.grey.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final surauRef = FirebaseFirestore.instance
        .collection('suraus')
        .where('ajkId', isEqualTo: widget.ajkId)
        .limit(1)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maklumat Surau'),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: surauRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Surau tidak ditemui"));

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Surau Image
                if (data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      data['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.mosque, size: 80, color: Colors.green),
                  ),
                const SizedBox(height: 16),

                // Surau Name & Follow Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        data['name'] ?? '',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _toggleFollow,
                      icon: Icon(_isFollowed ? Icons.check : Icons.add),
                      label: Text(_isFollowed ? "Mengikuti" : "Ikut"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFollowed ? Colors.green.shade600 : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Surau Details
                Text(data['address'] ?? '', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                const SizedBox(height: 4),
                Text("Nazir: ${data['nazirName'] ?? ''}"),
                Text("Tel: ${data['nazirPhone'] ?? ''}"),
                const Divider(height: 30, thickness: 1.2),

                // Posting Surau
                const Text(
                  "Posting Surau",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('ajkId', isEqualTo: widget.ajkId)
                      .snapshots(),
                  builder: (context, postSnap) {
                    if (postSnap.hasError) return const Text('Ralat memuatkan posting.');
                    if (!postSnap.hasData) return const Center(child: CircularProgressIndicator());

                    final posts = postSnap.data!.docs;
                    if (posts.isEmpty) return const Text("Tiada posting setakat ini");

                    return Column(
                      children: posts.map((doc) {
                        final p = doc.data() as Map<String, dynamic>;
                        final ts = p['timestamp'] != null
                            ? (p['timestamp'] as Timestamp).toDate()
                            : null;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['title'] ?? '',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 6),
                                if (p['category'] != null)
                                  Chip(
                                    label: Text(p['category']),
                                    backgroundColor: Colors.green.shade50,
                                    side: BorderSide.none,
                                  ),
                                const SizedBox(height: 6),
                                Text(p['description'] ?? ''),
                                const SizedBox(height: 8),
                                if (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      p['imageUrl'],
                                      height: 160,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Text(
                                  ts != null
                                      ? "${ts.day}/${ts.month}/${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}"
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
