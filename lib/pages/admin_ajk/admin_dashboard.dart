import 'package:flutter/material.dart';
import 'package:nursurau/pages/unified_login.dart';
import 'donation_page.dart';
import 'posting_page.dart';
import 'surau_details_page.dart';

class AdminDashboard extends StatefulWidget {
  final String ajkId; // Passed from login page

  const AdminDashboard({super.key, required this.ajkId});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DonationPage(ajkId: widget.ajkId),
      PostingPage(ajkId: widget.ajkId),
      SurauDetailsPage(ajkId: widget.ajkId),
    ];
  }

  // ✅ Function to show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Log Keluar"),
          content: const Text("Adakah anda pasti mahu log keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF87AC4F),
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _logout(context); // Continue logout
              },
              child: const Text(
                "Log Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ Function to log out and return to LoginPage
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UnifiedLoginPage()),
      (route) => false,
    );
  }

  // ✅ Dynamic title based on selected tab
  String get _pageTitle {
    switch (_currentIndex) {
      case 0:
        return "Sumbangan";
      case 1:
        return "Hebahan";
      case 2:
        return "Maklumat Surau";
      default:
        return "Dashboard";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // ✅ Centers the title
        title: Text(
          _pageTitle,
          style: const TextStyle(
            color: Colors.white, // ✅ Makes title white
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:  Color(0xFF87AC4F),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: "Log Keluar",
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor:  Color(0xFF87AC4F),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Sumbangan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Hebahan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mosque),
            label: 'Surau',
          ),
        ],
      ),
    );
  }
}
