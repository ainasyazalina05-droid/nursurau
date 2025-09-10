import 'package:flutter/material.dart';
import 'donation_page.dart';
import 'surau_details_page.dart';
import 'login_page.dart'; // untuk logout nanti

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  // Senarai page yang ada dalam dashboard
  final List<Widget> _pages = [
    const DonationPage(),
    const SurauDetailsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin AJK Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Bila tekan logout → balik ke LoginPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),

      // Body akan ikut index yang dipilih
      body: _pages[_currentIndex],

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Derma",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque),
            label: "Surau",
          ),
        ],
      ),
    );
  }
}
