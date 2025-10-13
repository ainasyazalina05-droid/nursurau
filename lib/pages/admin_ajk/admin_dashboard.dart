import 'package:flutter/material.dart';
import 'login_page.dart';
import 'donation_page.dart';
import 'surau_details_page.dart';
import 'posting_page.dart'; // 👈 new page import

class AdminDashboard extends StatefulWidget {
  final String ajkId; // pass AJK ID from login

  const AdminDashboard({super.key, required this.ajkId});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

<<<<<<< HEAD
  @override
  void initState() {
    super.initState();
    _pages = [
      const DonationAdminPage(ajkId: '',),
      SurauDetailsPage(ajkId: widget.ajkId), // pass ajkId
    ];
  }
=======
  // 👇 Add Posting page in the middle
  final List<Widget> _pages = [
    const DonationAdminPage(),
    const PostingPage(),
    const SurauDetailsPage(surauName: ''),
  ];
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Portal Pentadbir AJK",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color.fromARGB(255, 135, 172, 79),
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Derma",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add), // 👈 post icon
            label: "Posting",
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
