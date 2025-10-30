import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nursurau/pages/users/surau_details_page.dart';
import 'package:nursurau/services/follow_service.dart';
import 'home_page.dart';
import 'donations_page.dart';
import 'help_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  static const themeColor = Color(0xFF87AC4F); // unified app color 💚
  int _currentIndex = 0;

  List<String> followedAjkIds = [];
  bool isLoading = true;
  Set<String> removedNotifs = {}; // locally hidden notifications

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

  Future<void> _loadRemovedNotifs() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('removedNotifs') ?? [];
    setState(() {
      removedNotifs = ids.toSet();
    });
  }

  Future<void> _saveRemovedNotifs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('removedNotifs', removedNotifs.toList());
  }

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

  // ✅ unified navigation handler (shared with all pages)
  void _handleNavTap(int index) {
    if (index == _currentIndex) return;

    setState(() => _currentIndex = index);
    Widget nextPage;

    switch (index) {
      case 0:
        nextPage = const NotificationsPage();
        break;
      case 1:
        nextPage = const HomePage();
        break;
      case 2:
        nextPage = const DonationsPage();
        break;
      case 3:
        nextPage = const HelpPage();
        break;
      default:
        nextPage = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
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
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: const TextStyle(), // Reset bold style
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Notifikasi',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: const Center(
          child: Text(
            "Anda belum mengikuti mana-mana surau.",
            style: TextStyle(fontSize: 16),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F2),
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(), // Reset bold style
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Notifikasi',
            style: TextStyle(
              fontWeight: FontWeight.w500, // not bold
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
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
          final visiblePosts =
              posts.where((doc) => !removedNotifs.contains(doc.id)).toList();

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
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
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
                                backgroundColor: themeColor,
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
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ✅ Shared bottom nav builder
  BottomNavigationBar _buildBottomNavBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: _currentIndex,
      selectedItemColor: themeColor,
      unselectedItemColor: Colors.grey.shade700,
      type: BottomNavigationBarType.fixed,
      onTap: _handleNavTap,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined), label: "Notifikasi"),
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Utama"),
        BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism), label: "Donasi"),
        BottomNavigationBarItem(
            icon: Icon(Icons.help_outline), label: "Bantuan"),
      ],
    );
  }
}
