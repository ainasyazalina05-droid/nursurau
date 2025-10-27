import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/services/follow_service.dart';
import 'package:async/async.dart';
import 'package:nursurau/pages/users/surau_details_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> followedAjkIds = [];
  bool isLoading = true;

  // Optional: store last visit timestamp to highlight new posts
  DateTime lastVisit = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _loadFollowedAjkIds();
  }

  Future<void> _loadFollowedAjkIds() async {
    try {
      final ajkIds = await FollowService.getFollowedSurauIds();
      setState(() {
        followedAjkIds = ajkIds;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading followed ajkIds: $e");
      setState(() => isLoading = false);
    }
  }

  Stream<List<QueryDocumentSnapshot>> _getPostsStream() {
    if (followedAjkIds.isEmpty) return const Stream.empty().map((_) => []);

    final streams = followedAjkIds.map((ajkId) {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('ajkId', isEqualTo: ajkId) // only filter by ajkId
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });

    return StreamZip(streams).map((listOfDocs) {
      final allPosts = listOfDocs.expand((x) => x).toList();

      // Sort posts in Flutter by timestamp descending
      allPosts.sort((a, b) {
        final t1 = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        final t2 = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        return t2.compareTo(t1);
      });

      return allPosts;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (followedAjkIds.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Notifikasi")),
        body: const Center(
          child: Text("Anda belum mengikuti mana-mana surau."),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Ralat memuatkan notifikasi: ${snapshot.error}"),
            );
          }

          final posts = snapshot.data ?? [];

          if (posts.isEmpty) {
            return const Center(child: Text("Tiada notifikasi baru."));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Tiada tajuk';
              final desc = data['description'] ?? '';
              final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final ajkId = data['ajkId'] ?? '';

              final isNew = timestamp.isAfter(lastVisit);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () {
                    // Navigate to SurauDetailsPage
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurauDetailsPage(ajkId: ajkId),
                      ),
                    );
                  },
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Row(
                    children: [
                      if (isNew)
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Text(desc),
                  trailing: Text(
                    "${timestamp.day}/${timestamp.month}/${timestamp.year}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
