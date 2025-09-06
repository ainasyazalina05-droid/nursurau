import 'package:flutter/material.dart';


void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const AdminHomePage(title: 'ADMIN PANEL'),
    );
  }
}

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key, required this.title});
  final String title;

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DonationsPage(),
    const AnnouncementsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F6E8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F6E8),
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(0xFF064E3B),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF9F6E8),
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Donations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
        ],
      ),
    );
  }
}

//
// Donations Page
//
class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildDonationCard("Ali Ahmad", "RM50", "01 Sept 2025"),
        buildDonationCard("Fatimah Binti Zain", "RM100", "28 Aug 2025"),
        buildDonationCard("Anonymous", "RM20", "25 Aug 2025"),
      ],
    );
  }

  Widget buildDonationCard(String donor, String amount, String date) {
    return Card(
      color: const Color(0xFFF5EFD1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.green),
        title: Text(donor,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text("Donated on $date"),
        trailing: Text(
          amount,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green),
        ),
      ),
    );
  }
}

//
// Announcements Page
//
class AnnouncementsPage extends StatelessWidget {
  const AnnouncementsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildAnnouncementCard("Majlis Bacaan Yasin",
            "Program akan berlangsung pada Jumaat ini, 8 malam."),
        buildAnnouncementCard("Gotong-Royong Surau",
            "Sila hadir pada hari Ahad, jam 9 pagi."),
        buildAnnouncementCard("Agihan Bubur Lambuk",
            "Agihan percuma selepas solat Asar."),
      ],
    );
  }

  Widget buildAnnouncementCard(String title, String content) {
    return Card(
      color: const Color(0xFFF5EFD1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.campaign, color: Colors.green),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text(content),
      ),
    );
  }
}
