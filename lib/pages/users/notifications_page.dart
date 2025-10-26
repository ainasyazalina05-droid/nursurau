import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'follow_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> followedSurauIds = [];

  @override
  void initState() {
    super.initState();
    _loadFollowed();
  }

  Future<void> _loadFollowed() async {
    final ids = await FollowService.getFollowedSurauIds();
    setState(() {
      followedSurauIds = ids;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: const Color(0xFF87AC4F),
      ),
      body: followedSurauIds.isEmpty
          ? const Center(
              child: Text(
                "Anda belum mengikuti mana-mana surau.",
                style: TextStyle(fontSize: 16),
              ),
            )
          : StreamBuilder<QuerySnapshot>(
              // ✅ Fetch posts where surauId is in followed list
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('surauId', whereIn: followedSurauIds)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Ralat memuatkan notifikasi"));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return const Center(
                      child: Text("Tiada notifikasi baru."));
                }

                // Sort posts by timestamp descending
                posts.sort((a, b) {
                  final t1 = (a['timestamp'] as Timestamp?)?.toDate();
                  final t2 = (b['timestamp'] as Timestamp?)?.toDate();
                  return (t2 ?? DateTime.now())
                      .compareTo(t1 ?? DateTime.now());
                });

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final p = posts[index].data() as Map<String, dynamic>;
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
                                backgroundColor: Colors.green.shade50,
                                side: BorderSide.none,
                              ),
                            const SizedBox(height: 6),
                            Text(p['description'] ?? ''),
                            const SizedBox(height: 8),
                            if (p['imageUrl'] != null &&
                                (p['imageUrl'] as String).isNotEmpty)
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
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
