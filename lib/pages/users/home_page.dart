import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'surau_details_page.dart';
import 'donations_page.dart';
import 'notifications_page.dart';
import 'help_page.dart';
import 'package:nursurau/services/follow_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _followed = [];
  List<Map<String, dynamic>> _availableSuraus = [];
  List<Map<String, dynamic>> _filteredSuraus = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _loadAvailableSuraus().then((_) => _loadFollowed());
    _searchController.addListener(_onSearchChanged);
    Future.delayed(Duration.zero, _setupPushNotifications);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSuraus = query.isEmpty
          ? []
          : _availableSuraus
              .where((s) => (s['name'] ?? '').toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _setupPushNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);
      String? token = await messaging.getToken();
      print("FCM Token: $token");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final surauId = message.data['ajkId'];
        final followedIds = _followed.map((s) => s['ajkId']).toList();
        if (followedIds.contains(surauId)) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'title': message.notification?.title ?? 'Notifikasi Baru',
            'body': message.notification?.body ?? '',
            'surauId': surauId,
            'timestamp': FieldValue.serverTimestamp(),
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(message.notification?.title ?? 'Notifikasi baru')),
            );
          }
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        final surauId = message.data['ajkId'];
        final followedIds = _followed.map((s) => s['ajkId']).toList();
        if (followedIds.contains(surauId)) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => NotificationsPage()),
          );
        }
      });
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  Future<void> _loadAvailableSuraus() async {
    final snapshot = await FirebaseFirestore.instance.collection('suraus').get();
    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "ajkId": data['ajkId'] ?? '',
        "name": data['name'] ?? '',
        "address": data['address'] ?? '',
        "image": data['imageUrl'] ?? ''
      };
    }).toList();
    setState(() => _availableSuraus = list);
  }

  Future<void> _loadFollowed() async {
    final followedIds = await FollowService.loadFollowed();
    setState(() {
      _followed =
          _availableSuraus.where((s) => followedIds.contains(s['ajkId'])).toList();
    });
  }

  void _openSurauDetails(Map<String, dynamic> surau) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurauDetailsPage(ajkId: surau['ajkId'])),
    );
    await _loadFollowed();
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _filteredSuraus = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: "Cari Surau...",
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF2F5D50)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Followed Suraus Horizontal Scroll
                      if (_followed.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "SURAU DIIKUTI",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 220,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _followed.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 16),
                                itemBuilder: (context, index) {
                                  final s = _followed[index];
                                  return SizedBox(
                                    width: 200,
                                    child: SurauCard(
                                      title: s['name'] ?? '',
                                      imagePath: s['image'] ?? '',
                                      onTap: () => _openSurauDetails(s),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),

                      // Donation Banner
                      GestureDetector(
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const DonationsPage())),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB1E0C6), Color(0xFF8CC6A3)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(2, 4))
                            ],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.volunteer_activism,
                                  size: 48, color: Colors.brown),
                              SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  "Ikhlas Beramal,\nIndah Bersama",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Available Suraus List (single column)
                      const Text(
                        "SURAU TERSEDIA",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._availableSuraus.map((s) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SurauCard(
                              title: s['name'] ?? '',
                              imagePath: s['image'] ?? '',
                              onTap: () => _openSurauDetails(s),
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),

            // Search Suggestions
            if (_filteredSuraus.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                top: 90,
                child: Material(
                  color: Colors.white.withOpacity(0.95),
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredSuraus.length,
                    itemBuilder: (context, index) {
                      final s = _filteredSuraus[index];
                      return ListTile(
                        leading: s['image'] != ''
                            ? CircleAvatar(
                                backgroundImage: NetworkImage(s['image']))
                            : const Icon(Icons.location_on),
                        title: Text(s['name'] ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500)),
                        onTap: () => _openSurauDetails(s),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E2B8),
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFF2F5D50),
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
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
}

class SurauCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const SurauCard(
      {super.key, required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            children: [
              SizedBox.expand(
                child: imagePath != '' &&
                        (imagePath.startsWith('http') || imagePath.startsWith('https'))
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                        errorBuilder: (_, __, ___) {
                          return Image.asset('assets/surau1.jpg', fit: BoxFit.cover);
                        },
                      )
                    : Image.asset('assets/surau1.jpg', fit: BoxFit.cover),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black.withOpacity(0.35), Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [
                        Shadow(
                            offset: Offset(0, 1), blurRadius: 2, color: Colors.black54)
                      ]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
