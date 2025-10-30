import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/services/follow_service.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nursurau/pages/users/surau_details_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> followedAjkIds = [];
  bool isLoading = true;

  /// Locally hidden notifications (stored persistently)
  Set<String> removedNotifs = {};

  @override
  void initState() {
    super.initState();
    _loadFollowedAjkIds();
    _loadRemovedNotifs();
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

  /// Load removed notifications from SharedPreferences
  Future<void> _loadRemovedNotifs() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('removedNotifs') ?? [];
    setState(() {
      removedNotifs = ids.toSet();
    });
  }

  /// Save removed notifications to SharedPreferences
  Future<void> _saveRemovedNotifs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('removedNotifs', removedNotifs.toList());
  }

  /// Remove from display and save locally
  void _removeNotif(String notifId) {
    setState(() {
      removedNotifs.add(notifId);
    });
    _saveRemovedNotifs();
  }

  Stream<List<QueryDocumentSnapshot>> _getPostsStream() {
    if (followedAjkIds.isEmpty) return const Stream.empty().map((_) => []);

    final streams = followedAjkIds.map((ajkId) {
      return FirebaseFirestore.instance
          .collection('posts')
          .where('ajkId', isEqualTo: ajkId)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    });

    return StreamZip(streams).map((listOfDocs) {
      final allPosts = listOfDocs.expand((x) => x).toList();
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
        appBar: AppBar(
          title: const Text("Notifikasi"),
          backgroundColor: const Color(0xFF808000),
          centerTitle: true,
        ),
        body: const Center(
          child: Text("Anda belum mengikuti mana-mana surau."),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Notifikasi"),
        backgroundColor: const Color(0xFF808000),
        centerTitle: true,
      ),
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
          final visiblePosts = posts
              .where((doc) => !removedNotifs.contains(doc.id))
              .toList();

          if (visiblePosts.isEmpty) {
            return const Center(
              child: Text(
                "Tiada notifikasi.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            itemCount: visiblePosts.length,
            itemBuilder: (context, index) {
              final data = visiblePosts[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? 'Tiada tajuk';
              final desc = data['description'] ?? '';
              final timestamp =
                  (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
              final ajkId = data['ajkId'] ?? '';
              final notifId = visiblePosts[index].id;

              return Dismissible(
                key: ValueKey(notifId),
                direction: DismissDirection.horizontal,
                background: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red.shade400,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => _removeNotif(notifId),
                child: Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${timestamp.day}/${timestamp.month}/${timestamp.year}",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: const Color(0xFF808000),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SurauDetailsPage(ajkId: ajkId),
                                  ),
                                );
                              },
                              child: const Text(
                                "Lihat",
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
