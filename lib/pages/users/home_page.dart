import 'dart:async';
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
  Timer? _debounce;

  int _currentIndex = 1;
  bool _isSearching = false;
  bool _hasNewNotifications = false;

  final Color _primaryColor = const Color(0xFF808000);
  final Color _darkTextColor = const Color(0xFF3B3B3B);

  @override
  void initState() {
    super.initState();
    _loadAvailableSuraus().then((_) => _loadFollowed());
    _searchController.addListener(_onSearchChanged);
    Future.delayed(Duration.zero, _setupPushNotifications);
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
            setState(() => _hasNewNotifications = true);
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
          Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
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
      _followed = _availableSuraus.where((s) => followedIds.contains(s['ajkId'])).toList();
    });
  }

  void _filterSuraus(String query) {
    final q = query.toLowerCase();
    setState(() {
      _filteredSuraus = q.isEmpty
          ? []
          : _availableSuraus.where((s) => (s['name'] ?? '').toLowerCase().contains(q)).toList();
    });
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    setState(() => _isSearching = _searchController.text.isNotEmpty);
    _debounce = Timer(const Duration(milliseconds: 250), () {
      _filterSuraus(_searchController.text);
    });
  }

  void _handleNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) Navigator.push(context, MaterialPageRoute(builder: (_) => NotificationsPage()));
    if (index == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationsPage()));
    if (index == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
  }

  void _openSurauDetails(Map<String, dynamic> surau) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SurauDetailsPage(ajkId: surau['ajkId'])),
    );
    await _loadFollowed();
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() {
      _filteredSuraus.clear();
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // 🌿 Redesigned Header + Search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: const AssetImage('assets/logo.png'),
                                backgroundColor: _primaryColor.withOpacity(0.1),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'NurSurau',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _darkTextColor,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => _handleNavTap(0),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(Icons.notifications_outlined, size: 26, color: _darkTextColor),
                                    if (_hasNewNotifications)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          width: 9,
                                          height: 9,
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 1.5),
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _buildSearchBar(),
                        ],
                      ),
                    ),
                  ),
                ),

                // 🕌 Followed + Available Surau Lists
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFollowedSection(),
                        const SizedBox(height: 20),
                        _buildDonationBanner(),
                        const SizedBox(height: 20),
                        const Text(
                          "SURAU TERSEDIA:",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4B4B4B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._availableSuraus.map((s) => SurauCard(
                              title: s['name'] ?? '',
                              imagePath: s['image'] ?? '',
                              onTap: () => _openSurauDetails(s),
                            )),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // 🔍 Search Results Overlay
            if (_isSearching && _filteredSuraus.isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                top: 130,
                child: Material(
                  color: Colors.white,
                  elevation: 6,
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredSuraus.length,
                    itemBuilder: (context, index) {
                      final s = _filteredSuraus[index];
                      return ListTile(
                        leading: s['image'] != '' ? CircleAvatar(backgroundImage: NetworkImage(s['image'])) : null,
                        title: Text(s['name'] ?? '', style: const TextStyle(color: Color(0xFF3B3B3B))),
                        onTap: () => _openSurauDetails(s),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),

      // 🧭 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey.shade700,
        type: BottomNavigationBarType.fixed,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications_outlined), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Utama"),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: "Donasi"),
          BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: "Bantuan"),
        ],
      ),
    );
  }

  // 🌿 Search Bar
  Widget _buildSearchBar() {
    return Focus(
      onFocusChange: (_) => setState(() {}),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: _searchFocus.hasFocus ? Colors.white : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _searchFocus.hasFocus ? _primaryColor : Colors.grey.shade300,
            width: 1.4,
          ),
          boxShadow: _searchFocus.hasFocus
              ? [BoxShadow(color: _primaryColor.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 3))]
              : [const BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          decoration: InputDecoration(
            hintText: 'Cari surau berdekatan...',
            hintStyle: TextStyle(color: Colors.grey.shade500),
            prefixIcon: Icon(Icons.search, color: _primaryColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close),
                    color: Colors.grey.shade600,
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _isSearching = false;
                        _filteredSuraus.clear();
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  // 💚 Followed Section
  Widget _buildFollowedSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _primaryColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("SURAU DIIKUTI:",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_followed.isEmpty)
            const Text("Tiada surau diikuti", style: TextStyle(color: Colors.white70))
          else
            ..._followed.map((s) => GestureDetector(
                  onTap: () => _openSurauDetails(s),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: s['image'] != ''
                            ? Image.network(s['image'], height: 180, width: double.infinity, fit: BoxFit.cover)
                            : Image.asset('assets/surau1.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        s['name'] ?? '',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  // 🤲 Donation Banner
  Widget _buildDonationBanner() {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationsPage())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.volunteer_activism, size: 40, color: Color(0xFF808000)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Ikhlas Beramal,\nIndah Bersama",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _darkTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 🕌 Surau Card
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(2, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B4B4B))),
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
