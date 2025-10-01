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
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
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

              // 🕌 Surau Tersedia (setiap surau 1 kotak)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      "SURAU TERSEDIA:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),

                    // Surau 1
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
                        );
                      },
                    ),

                    // Surau 2
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
                        );
                      },
                    ),

                    // Surau 3
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
                        );
                      },
                    ),

                    // Surau 4
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
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // 📌 Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E2B8),
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

// 🔹 Widget reusable untuk Surau
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
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
            offset: Offset(2, 2),
          )
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
