import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'donations_page.dart';
import 'help_page.dart';
import 'surau_details_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8), // cream background

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔎 Search bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5D50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: Row(
                  children: const [
                    Expanded(
                      child: Text(
                        "CARI SURAU",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Icon(Icons.search, color: Colors.white),
                  ],
                ),
              ),

              // 🕌 Surau Diikuti
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF2F5D50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "SURAU DIIKUTI:",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SurauDetailsPage(
                                surauName: "Surau At-Taufik"),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/surau1.jpg",
                          height: 180, // ⬆️ bigger
                          width: double.infinity, // take full width of container
                          fit: BoxFit.cover, // nicely fills space
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Surau At-Taufik",
                        style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),

              // ❤️ Donation Banner
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DonationsPage()),
                  );
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
                        offset: Offset(2, 2),
                      )
                    ],
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.volunteer_activism,
                          size: 40, color: Colors.brown),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Ikhlas Beramal,\nIndah Bersama",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // 🕌 Surau Tersedia
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5E2B8),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    const Text("SURAU TERSEDIA:",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SurauDetailsPage(
                                surauName: "Surau Raudhatul Jannah"),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "assets/surau2.jpg",
                          height: 180, // ⬆️ bigger
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text("Surau Raudhatul Jannah"),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Surau 2
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SurauDetailsPage(
                  surauName: "Musolla As-Solihin"),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            "assets/surau3.jpg",
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 8),
      const Text("Surau Al-Hidayah"),

      const SizedBox(height: 16),
            ],
          ),
        ),
      ),

      // 📌 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
      backgroundColor: const Color(0xFFF5E2B8), // ✅ match your original design
      currentIndex: 1,
      selectedItemColor: const Color(0xFF2F5D50),
      unselectedItemColor: Colors.black87,
      onTap: (index) {
        if (index == 0) {
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()));
        } else if (index == 1) {
          // Already Home
        } else if (index == 2) {
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => const DonationsPage()));
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
