import 'package:flutter/material.dart';
import 'donation_page.dart';
import 'surau_details_page.dart';
import 'login_page.dart'; // untuk redirect semula ke login

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DonationPage(),
    const SurauDetailsPage(),
  ];

  // 👉 Fungsi logout ada dalam class ni
  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin AJK Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout, // panggil fungsi logout
            tooltip: "Logout",
          ),
        ],
      ),
      body: _pages[_currentIndex],
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
            label: "Donations",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance),
            label: "Surau Details",
          ),
        ],
      ),
    );
  }
}
