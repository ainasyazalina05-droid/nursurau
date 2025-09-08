import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Surau App',
      theme: ThemeData(
        primaryColor: const Color(0xFF2F5D50),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 1; // default index (Home)

  // Bottom navigation bar page list (you can replace with your pages)
  final List<Widget> _pages = [
    const NotificationPage(),
    const HomePageContent(),
    const DonationPage(),
    const InfoPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // switch between pages
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2F5D50),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: "Derma",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: "Info",
          ),
        ],
      ),
    );
  }
}

//
// 🏡 Home Page Content
//
class HomePageContent extends StatelessWidget {
  const HomePageContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search Button
            ElevatedButton.icon(
              onPressed: () {
                // 👉 Navigate to Search Page here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F5D50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              icon: const Icon(Icons.search, color: Colors.white),
              label: const Text("CARI SURAU", style: TextStyle(color: Colors.white)),
            ),

            const SizedBox(height: 20),

            // Surau Diikuti
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2F5D50),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SURAU DIIKUTI :", style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset("assets/surau1.jpg", height: 120, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text("Surau At-Taufik", style: TextStyle(color: Colors.white))),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.circle, size: 10, color: Colors.white),
                      SizedBox(width: 6),
                      Icon(Icons.circle_outlined, size: 10, color: Colors.white),
                      SizedBox(width: 6),
                      Icon(Icons.circle_outlined, size: 10, color: Colors.white),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Donation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF75B5A8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: const [
                  Icon(Icons.volunteer_activism, size: 40, color: Colors.black),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text("Ikhlas Beramal,\nIndah Bersama",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Surau Tersedia
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE9DAB2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("SURAU TERSEDIA :"),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset("assets/surau2.jpg", height: 120, fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 8),
                  const Center(child: Text("Surau Raudhatul Jannah", style: TextStyle(fontWeight: FontWeight.bold))),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.circle, size: 10, color: Color(0xFF2F5D50)),
                      SizedBox(width: 6),
                      Icon(Icons.circle, size: 10, color: Color(0xFF4BA696)),
                      SizedBox(width: 6),
                      Icon(Icons.circle, size: 10, color: Color(0xFF75B5A8)),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// Other Pages (to link from bottom menu)
//
class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Notifikasi Page"));
  }
}

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Derma Page"));
  }
}

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Info Page"));
  }
}
