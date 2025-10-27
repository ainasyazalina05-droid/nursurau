import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/services/follow_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> followedAjkIds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowedAjkIds();
  }

  Future<void> _loadFollowedAjkIds() async {
    try {
      // FollowService now stores ajkIds
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

    // Firestore `whereIn` supports max 10 items
    final limitedAjkIds = followedAjkIds.length > 10
        ? followedAjkIds.sublist(0, 10)
        : followedAjkIds;

    return Scaffold(
      appBar: AppBar(title: const Text("Notifikasi")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('ajkId', whereIn: limitedAjkIds)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text("Ralat memuatkan notifikasi."),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final posts = snapshot.data?.docs ?? [];

          if (posts.isEmpty) {
            return const Center(
              child: Text("Tiada notifikasi baru."),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Tiada tajuk';
              final desc = data['description'] ?? '';
              final timestamp = data['timestamp'] != null
                  ? (data['timestamp'] as Timestamp).toDate()
                  : DateTime.now();

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
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
