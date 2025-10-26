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
    final surauRef =
        FirebaseFirestore.instance.collection('suraus').doc(widget.surauId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maklumat Surau', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF87AC4F),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: surauRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          if (data == null) {
            return const Center(child: Text("Surau tidak ditemui"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 🔹 Surau Info Card (with image)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: data['imageUrl'] != null &&
                                (data['imageUrl'] as String).isNotEmpty
                            ? Image.network(
                                data['imageUrl'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 200,
                                color: const Color.fromARGB(255, 232, 245, 233),
                                child: const Icon(
                                  Icons.mosque,
                                  size: 80,
                                  color: Color.fromARGB(255, 135, 172, 79),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data['name'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['address'] ?? '',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowed
                              ? Colors.grey.shade300
                              : const Color(0xFF87AC4F),
                          foregroundColor:
                              _isFollowed ? Colors.black87 : Colors.white,
                          minimumSize: const Size(double.infinity, 45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _toggleFollow,
                        icon: Icon(
                          _isFollowed ? Icons.check_circle : Icons.group_add,
                        ),
                        label: Text(
                          _isFollowed ? "Mengikuti" : "Ikuti Surau",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 🔹 Nazir Info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Maklumat Nazir",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text("Nama: ${data['nazirName'] ?? '-'}"),
                      Text("No. Telefon: ${data['nazirPhone'] ?? '-'}"),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // 🔹 Posts Section
                const Text(
                  "Posting Surau",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                StreamBuilder<DocumentSnapshot>(
                  stream: surauRef.snapshots(),
                  builder: (context, surauSnap) {
                    if (!surauSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final surauData =
                        surauSnap.data!.data() as Map<String, dynamic>?;
                    if (surauData == null || surauData['ajkId'] == null) {
                      return const Text("Tiada AJK dikaitkan dengan surau ini.");
                    }

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('posts')
                          .where('ajkId', isEqualTo: surauData['ajkId'])
                          .snapshots(),
                      builder: (context, postSnap) {
                        if (postSnap.hasError) {
                          return const Text('Ralat memuatkan posting.');
                        }
                        if (!postSnap.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final posts = postSnap.data!.docs;
                        if (posts.isEmpty) {
                          return const Text("Tiada posting setakat ini");
                        }

                        // ✅ Sort manually (no Firestore index needed)
                        posts.sort((a, b) {
                          final t1 = (a['timestamp'] as Timestamp?)?.toDate();
                          final t2 = (b['timestamp'] as Timestamp?)?.toDate();
                          return (t2 ?? DateTime.now())
                              .compareTo(t1 ?? DateTime.now());
                        });

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
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (p['category'] != null)
                                      Chip(
                                        label: Text(p['category']),
                                        backgroundColor:
                                            Colors.green.shade50,
                                        side: BorderSide.none,
                                      ),
                                    const SizedBox(height: 6),
                                    Text(p['description'] ?? ''),
                                    const SizedBox(height: 8),
                                    if (p['imageUrl'] != null &&
                                        (p['imageUrl'] as String)
                                            .isNotEmpty)
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(8),
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
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
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
