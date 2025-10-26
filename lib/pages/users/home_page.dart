import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  List<Map<String, dynamic>> _followed = [];
  List<Map<String, dynamic>> _availableSuraus = [];
  List<Map<String, dynamic>> _filteredSuraus = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  int _currentIndex = 1; // BottomNavigationBar current index

  @override
  void initState() {
    super.initState();
    _loadAvailableSuraus().then((_) => _loadFollowed());
    _searchController.addListener(_onSearchChanged);
    Future.delayed(Duration.zero, _setupPushNotifications);
  }

  // Search logic
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

  // Push notifications
  Future<void> _setupPushNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      print("Permission status: ${settings.authorizationStatus}");

      String? token = await messaging.getToken();
      print("FCM Token: $token");

      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final surauId = message.data['ajkId'];
        final followedIds = _followed.map((s) => s['ajkId']).toList();

        if (followedIds.contains(surauId)) {
          // Save notification to Firestore
          await FirebaseFirestore.instance.collection('notifications').add({
            'title': message.notification?.title ?? 'Notifikasi Baru',
            'body': message.notification?.body ?? '',
            'surauId': surauId,
            'timestamp': FieldValue.serverTimestamp(),
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.notification?.title ?? 'Notifikasi baru')),
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
            MaterialPageRoute(builder: (_) => const NotificationsPage()),
          );
        }
      });
    } catch (e) {
      print("Error initializing notifications: $e");
    }
  }

  // Load all suraus
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

  // Load followed suraus
  Future<void> _loadFollowed() async {
    final followedIds = await FollowService.loadFollowed();
    setState(() {
      _followed = _availableSuraus.where((s) => followedIds.contains(s['ajkId'])).toList();
    });
  }

  // Open surau details
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
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Followed Suraus
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2F5D50),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                        ),
                        child: Column(
                          children: [
                            const Text(
                              "SURAU DIIKUTI:",
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            if (_followed.isEmpty)
                              const Text("Tiada surau diikuti", style: TextStyle(color: Colors.white))
                            else
                              ..._followed.map((s) => GestureDetector(
                                    onTap: () => _openSurauDetails(s),
                                    child: Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: s['image'] != ''
                                              ? Image.network(s['image'], height: 180, width: double.infinity, fit: BoxFit.cover)
                                              : Image.asset('assets/surau1.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(s['name'] ?? '', style: const TextStyle(color: Colors.white)),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  )),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Donation Banner
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationsPage())),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8CC6A3),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.volunteer_activism, size: 40, color: Colors.brown),
                              SizedBox(width: 12),
                              Expanded(
                                  child: Text(
                                "Ikhlas Beramal,\nIndah Bersama",
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Available Suraus
                      const Text("SURAU TERSEDIA:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 12),
                      ..._availableSuraus.map((s) => SurauCard(
                            title: s['name'] ?? '',
                            imagePath: s['image'] ?? '',
                            onTap: () => _openSurauDetails(s),
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
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredSuraus.length,
                    itemBuilder: (context, index) {
                      final s = _filteredSuraus[index];
                      return ListTile(
                        leading: s['image'] != '' ? CircleAvatar(backgroundImage: NetworkImage(s['image'])) : null,
                        title: Text(s['name'] ?? ''),
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
}

// SurauCard widget
class SurauCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final VoidCallback onTap;

  const SurauCard({super.key, required this.title, required this.imagePath, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E2B8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: imagePath != '' && (imagePath.startsWith('http') || imagePath.startsWith('https'))
                  ? Image.network(imagePath, height: 180, width: double.infinity, fit: BoxFit.cover)
                  : Image.asset('assets/surau1.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
        ],
      ),
    );
  }
}
