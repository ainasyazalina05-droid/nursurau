import 'package:flutter/material.dart';
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
      PostingPage(ajkId: widget.ajkId),  // ✅ no parameter now
      SurauDetailsPage(ajkId: widget.ajkId),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color.fromARGB(255, 135, 172, 79),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Posts',
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
