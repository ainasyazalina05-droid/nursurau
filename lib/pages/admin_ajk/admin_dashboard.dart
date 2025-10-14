import 'package:flutter/material.dart';
import 'login_page.dart';
import 'donation_page.dart';
import 'posting_page.dart';
import 'surau_details_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDashboard extends StatefulWidget {
  final String ajkId;

  const AdminDashboard({super.key, required this.ajkId});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  String surauName = "";
  bool isLoading = true;

  late List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _fetchSurauName();
  }

  Future<void> _fetchSurauName() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.ajkId)
          .get();

      if (doc.exists && doc.data()!.containsKey('surauName')) {
        surauName = doc['surauName'];
      }

      setState(() {
        isLoading = false;
        _pages = [
          DonationAdminPage(ajkId: widget.ajkId, surauName: surauName),
          PostingPage(
            ajkId: widget.ajkId,
            surauName: surauName,
            surauId: '',
          ),
          SurauDetailsPage(ajkId: widget.ajkId, surauName: surauName, surauId: '',),
        ];
      });
    } catch (e) {
      print("Error fetching surau name: $e");
      setState(() => isLoading = false);
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentIndex == 2 && surauName.isNotEmpty
              ? "Butiran Surau: $surauName"
              : "Portal Pentadbir AJK",
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pages[_currentIndex],
      bottomNavigationBar: isLoading
          ? null
          : BottomNavigationBar(
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
