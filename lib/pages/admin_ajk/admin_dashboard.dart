import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart';
import 'donation_page.dart';
import 'surau_details_page.dart';
import 'posting_page.dart';

class AdminDashboard extends StatefulWidget {
  final String ajkId;
  final String surauId;

  const AdminDashboard({super.key, required this.ajkId, required this.surauId});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  String surauName = ""; // For dynamic AppBar title
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      DonationAdminPage(
        ajkId: widget.ajkId,
        surauId: widget.surauId,
      ),
      PostingPage(
        ajkId: widget.ajkId,
        surauId: widget.surauId, // ✅ Pass surauId here
      ),
      SurauDetailsPage(
        ajkId: widget.ajkId,
        surauId: widget.surauId,
      ),
    ];

    _fetchSurauName();
  }

  Future<void> _fetchSurauName() async {
    final doc = await FirebaseFirestore.instance
        .collection("surauDetails")
        .doc(widget.surauId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        surauName = data["namaSurau"] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 2 ? "Butiran Surau: $surauName" : "Portal Pentadbir AJK",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
            icon: Icon(Icons.post_add),
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
