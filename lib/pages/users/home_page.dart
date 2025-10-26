import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'surau_details_page.dart';
import 'donations_page.dart';
import 'notifications_page.dart';
import 'help_page.dart';
import 'follow_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    Future.delayed(Duration.zero, _setupPushNotifications);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() {});
    });
  }

  Future<void> _setupPushNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      final token = await messaging.getToken();
      print("📱 Device Token: $token");

      FirebaseMessaging.onMessage.listen((message) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.notification?.title ?? "Notifikasi baru diterima")),
          );
        }
      });
    } catch (e) {
      print("❌ Notification setup error: $e");
    }
  }

  Stream<List<Map<String, dynamic>>> _surausStream() {
    return FirebaseFirestore.instance
        .collection('suraus')
        .limit(20) // ✅ Limit for faster initial load
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          "id": doc.id,
          "name": data['name'] ?? '',
          "address": data['address'] ?? '',
          "image": data['imageUrl'] ?? '',
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F5F0),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _surausStream(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final suraus = snapshot.data!;
            final filtered = query.isEmpty
                ? []
                : suraus.where((s) => (s['name'] ?? '').toLowerCase().contains(query)).toList();

            return FutureBuilder<List<String>>(
              future: FollowService.loadFollowed(),
              builder: (context, followSnap) {
                if (!followSnap.hasData) return const Center(child: CircularProgressIndicator());
                final followedIds = followSnap.data!;
                final followed = suraus.where((s) => followedIds.contains(s['id'])).toList();

                return Stack(
                  children: [
                    // 🌿 Main Scroll
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔍 Search Bar
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocus,
                              decoration: InputDecoration(
                                hintText: "Cari Surau...",
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: query.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () => _searchController.clear(),
                                      )
                                    : null,
                              ),
                            ),
                          ),

                          // 💚 Followed Section
                          const SectionHeader(title: "Surau Diikuti", icon: Icons.favorite),
                          if (followed.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text("Tiada surau diikuti.",
                                  style: TextStyle(color: Colors.grey)),
                            )
                          else
                            SizedBox(
                              height: 230,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: followed.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, i) {
                                  final s = followed[i];
                                  return SurauCard(
                                    title: s['name'],
                                    imagePath: s['image'],
                                    onTap: () => _openSurauDetails(s),
                                    isCompact: true,
                                  );
                                },
                              ),
                            ),

                          // 💝 Donation Banner
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DonationsPage()),
                            ),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF8CC6A3), Color(0xFF2F5D50)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 3)),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.volunteer_activism, size: 48, color: Colors.white),
                                  SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      "Ikhlas Beramal,\nIndah Bersama",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // 🕌 Surau List
                          const SectionHeader(title: "Senarai Surau", icon: Icons.mosque),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: suraus
                                  .map((s) => Padding(
                                        padding: const EdgeInsets.only(bottom: 14),
                                        child: SurauCard(
                                          title: s['name'],
                                          imagePath: s['image'],
                                          onTap: () => _openSurauDetails(s),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 🔍 Search Suggestions
                    if (filtered.isNotEmpty)
                      Positioned(
                        left: 16,
                        right: 16,
                        top: 100,
                        child: Material(
                          elevation: 6,
                          borderRadius: BorderRadius.circular(12),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: filtered.length,
                            itemBuilder: (context, i) {
                              final s = filtered[i];
                              return ListTile(
                                leading: s['image'] != ''
                                    ? CircleAvatar(backgroundImage: NetworkImage(s['image']))
                                    : const CircleAvatar(child: Icon(Icons.mosque)),
                                title: Text(s['name']),
                                onTap: () => _openSurauDetails(s),
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                );
              },
            );
          },
        ),
      ),

      // 🧭 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: 1,
        selectedItemColor: const Color(0xFF2F5D50),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsPage()));
          if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationsPage()));
          if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Utama"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Donasi"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Bantuan"),
        ],
      ),
    );
  }

  void _openSurauDetails(Map<String, dynamic> surau) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurauDetailsPage(surauId: surau["id"])),
    );
    setState(() {});
    _searchController.clear();
    _searchFocus.unfocus();
  }
}

// 🌙 Section Header
class SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const SectionHeader({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2F5D50)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F5D50),
            ),
          ),
        ],
      ),
    );
  }
}

// 🕌 Modern Surau Card
class SurauCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;
  final bool isCompact;

  const SurauCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            CachedNetworkImage(
              imageUrl: imagePath.isNotEmpty ? imagePath : 'https://via.placeholder.com/400x200',
              height: isCompact ? 200 : 220,
              width: isCompact ? 280 : double.infinity,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
              errorWidget: (_, __, ___) => const Icon(Icons.error),
            ),
            Container(
              height: 80,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black54, Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
