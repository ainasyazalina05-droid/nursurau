import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'donations_page.dart';
import 'help_page.dart';
import 'surau_details_page.dart';
import 'follow_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> _followed = [];

  // all available surau
  final List<Map<String, String>> _availableSurau = [
    {"name": "Surau At-Taufik", "image": "assets/surau1.jpg"},
    {"name": "Surau Raudhatul Jannah", "image": "assets/surau2.jpg"},
    {"name": "Musolla As-Solihin", "image": "assets/surau3.jpg"},
    {"name": "Surau Falakhiah", "image": "assets/surau4.webp"},
    {"name": "Surau Nurul Iman", "image": "assets/surau5.jpg"},
  ];

  List<Map<String, String>> _filteredSurau = [];

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // local mapping of surau -> asset image
  static const Map<String, String> _defaultAssets = {
    "Surau At-Taufik": "assets/surau1.jpg",
    "Surau Raudhatul Jannah": "assets/surau2.jpg",
    "Musolla As-Solihin": "assets/surau3.jpg",
    "Surau Falakhiah": "assets/surau4.webp",
    "Surau Nurul Iman": "assets/surau5.jpg",
  };

  @override
  void initState() {
    super.initState();
    _loadFollowed();

    _searchController.addListener(() {
      final query = _searchController.text.toLowerCase();
      setState(() {
        if (query.isEmpty) {
          _filteredSurau = [];
        } else {
          _filteredSurau = _availableSurau
              .where((s) => s["name"]!.toLowerCase().contains(query))
              .toList();
        }
      });
    });
  }

  Future<void> _loadFollowed() async {
    final raw = await FollowService.loadFollowed();
    final parsed = raw.map((r) => FollowService.decode(r)).toList();
    final list = parsed.map((m) {
      final name = m["name"] ?? "";
      final image = (m["image"] ?? "").trim();
      return {"name": name, "image": image};
    }).toList();

    setState(() {
      _followed = list;
    });
  }

  void _openSurauDetails(Map<String, String> surau) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurauDetailsPage(surauName: surau["name"]!),
      ),
    ).then((_) => _loadFollowed());

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
                  // 🔎 Floating Search Bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      style: const TextStyle(color: Colors.black87),
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

                  // 🕌 Surau Diikuti
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F5D50),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(2, 2))
                      ],
                    ),
                    child: Column(
                      children: [
                        const Text(
                          "SURAU DIIKUTI:",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),

                        if (_followed.isEmpty)
                          const Text("Tiada surau diikuti",
                              style: TextStyle(color: Colors.white))
                        else
                          ..._followed.map((entry) {
                            final name = entry["name"] ?? "";
                            final image = entry["image"] ?? "";

                            Widget imageWidget;
                            if (image.isNotEmpty &&
                                (image.startsWith("http") ||
                                    image.startsWith("https"))) {
                              imageWidget = Image.network(image,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover);
                            } else {
                              final assetPath =
                                  _defaultAssets[name] ?? "assets/surau1.jpg";
                              imageWidget = Image.asset(assetPath,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover);
                            }

                            return Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              SurauDetailsPage(surauName: name)),
                                    ).then((_) => _loadFollowed());
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: imageWidget,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(name,
                                    style:
                                        const TextStyle(color: Colors.white)),
                                const SizedBox(height: 12),
                              ],
                            );
                          }).toList(),
                      ],
                    ),
                  ),

                  // ❤️ Donation Banner
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DonationsPage()));
                    },
                    child: Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8CC6A3),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 4,
                              offset: Offset(2, 2))
                        ],
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.volunteer_activism,
                              size: 40, color: Colors.brown),
                          SizedBox(width: 12),
                          Expanded(
                              child: Text("Ikhlas Beramal,\nIndah Bersama",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold))),
                        ],
                      ),
                    ),
                  ),

                  // 🕌 Surau Tersedia
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text("SURAU TERSEDIA:",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 12),

                        SurauCard(
                          title: "Surau Raudhatul Jannah",
                          imagePath: "assets/surau2.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SurauDetailsPage(
                                    surauName: "Surau Raudhatul Jannah"),
                              ),
                            ).then((_) => _loadFollowed());
                          },
                        ),
                        SurauCard(
                          title: "Musolla As-Solihin",
                          imagePath: "assets/surau3.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SurauDetailsPage(
                                    surauName: "Musolla As-Solihin"),
                              ),
                            ).then((_) => _loadFollowed());
                          },
                        ),
                        SurauCard(
                          title: "Surau Falakhiah",
                          imagePath: "assets/surau4.webp",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SurauDetailsPage(
                                    surauName: "Surau Falakhiah"),
                              ),
                            ).then((_) => _loadFollowed());
                          },
                        ),
                        SurauCard(
                          title: "Surau Nurul Iman",
                          imagePath: "assets/surau5.jpg",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SurauDetailsPage(
                                    surauName: "Surau Nurul Iman"),
                              ),
                            ).then((_) => _loadFollowed());
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔎 Floating suggestions overlay
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
                    final surau = _filteredSurau[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(surau["image"]!),
                      ),
                      title: Text(surau["name"]!),
                      onTap: () => _openSurauDetails(surau),
                    );
                  },
                ),
              ),
            ),
        ],
      ),

      // 📌 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E2B8),
        currentIndex: 1,
        selectedItemColor: const Color(0xFF2F5D50),
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationsPage()));
          } else if (index == 1) {
            // Already Home
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DonationsPage()));
          } else if (index == 3) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HelpPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Utama"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Donasi"),
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

  const SurauCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5E2B8),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
        ],
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
