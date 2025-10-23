import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Map<String, dynamic>> _availableSurau = [];
  List<Map<String, dynamic>> _filteredSurau = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadFollowed();
    _loadAvailableSuraus();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        _filteredSurau = query.isEmpty
            ? []
            : _availableSurau
                .where((s) => (s["name"] ?? "").toLowerCase().contains(query))
                .toList();
      });
    });
  }

  Future<void> _loadAvailableSuraus() async {
    final snapshot = await FirebaseFirestore.instance.collection('suraus').get();
    final list = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        "id": doc.id,
        "name": data['name'] ?? '',
        "address": data['address'] ?? '',
        "image": data['imageUrl'] ?? ''
      };
    }).toList();
    setState(() => _availableSurau = list);
  }

  Future<void> _loadFollowed() async {
    final followedIds = await FollowService.loadFollowed();
    setState(() {
      _followed = _availableSurau
          .where((s) => followedIds.contains(s['id']))
          .toList();
    });
  }

  void _openSurauDetails(Map<String, dynamic> surau) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => SurauDetailsPage(surauId: surau["id"])),
    );
    _loadFollowed();
    _searchController.clear();
    _searchFocus.unfocus();
    setState(() => _filteredSurau = []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔎 Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
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

                  // 🕌 Followed Suraus
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F5D50),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
                      ],
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
                          ..._followed.map((s) {
                            return GestureDetector(
                              onTap: () => _openSurauDetails(s),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: s['image'] != null && s['image'] != ''
                                        ? Image.network(s['image'], height: 180, width: double.infinity, fit: BoxFit.cover)
                                        : Image.asset('assets/surau1.jpg', height: 180, width: double.infinity, fit: BoxFit.cover),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(s['name'] ?? '', style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 12),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  ),

                  // ❤️ Donation Banner
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DonationsPage())),
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8CC6A3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.volunteer_activism, size: 40, color: Colors.brown),
                          SizedBox(width: 12),
                          Expanded(child: Text("Ikhlas Beramal,\nIndah Bersama", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ),

                  // 🕌 Available Suraus
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("SURAU TERSEDIA:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),
                        ..._availableSurau.map((s) => SurauCard(
                              title: s['name'] ?? '',
                              imagePath: s['image'] ?? '',
                              onTap: () => _openSurauDetails(s),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔎 Search suggestions overlay
          if (_filteredSurau.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              top: 90,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredSurau.length,
                  itemBuilder: (context, index) {
                    final s = _filteredSurau[index];
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

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E2B8),
        currentIndex: 1,
        selectedItemColor: const Color(0xFF2F5D50),
        unselectedItemColor: Colors.black87,
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
}

// 🔹 SurauCard reusable widget
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
