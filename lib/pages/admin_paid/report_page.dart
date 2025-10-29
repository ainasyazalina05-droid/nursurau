import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportsPage extends StatefulWidget {
  const AdminReportsPage({super.key});

  @override
  State<AdminReportsPage> createState() => _AdminReportsPageState();
}

class _AdminReportsPageState extends State<AdminReportsPage> {
  int totalSuraus = 0;
  int approvedSuraus = 0;
  int pendingSuraus = 0;
  int totalUsers = 0;
  int totalDonations = 0;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    try {
      // 🔹 Count total suraus
      var surauSnapshot =
          await FirebaseFirestore.instance.collection('form').get();
      totalSuraus = surauSnapshot.size;

      // 🔹 Count approved suraus
      var approvedSnapshot = await FirebaseFirestore.instance
          .collection('form')
          .where('status', isEqualTo: 'approved')
          .get();
      approvedSuraus = approvedSnapshot.size;

      // 🔹 Count pending suraus
      var pendingSnapshot = await FirebaseFirestore.instance
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingSuraus = pendingSnapshot.size;

      // 🔹 Count total users
      var userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      totalUsers = userSnapshot.size;

      // 🔹 Count total donations (if exists)
      try {
        var donationSnapshot =
            await FirebaseFirestore.instance.collection('donations').get();
        totalDonations = donationSnapshot.size;
      } catch (e) {
        totalDonations = 0; // skip if no collection yet
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading reports: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F0),
      appBar: AppBar(
        title: const Text(
          "System Reports",
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF2E7D32)),
      ),

      // 🔹 Main Content
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildReportCard(
                    icon: Icons.mosque,
                    title: "Total Suraus",
                    count: totalSuraus,
                    color: const Color(0xFF2E7D32),
                  ),
                  _buildReportCard(
                    icon: Icons.check_circle,
                    title: "Approved",
                    count: approvedSuraus,
                    color: Colors.green.shade600,
                  ),
                  _buildReportCard(
                    icon: Icons.hourglass_bottom,
                    title: "Pending",
                    count: pendingSuraus,
                    color: Colors.orange,
                  ),
                  _buildReportCard(
                    icon: Icons.people,
                    title: "Total Users",
                    count: totalUsers,
                    color: Colors.teal,
                  ),
                  _buildReportCard(
                    icon: Icons.volunteer_activism,
                    title: "Donations",
                    count: totalDonations,
                    color: Colors.blue,
                  ),
                ],
              ),
            ),
    );
  }

  // 🔹 Reusable card widget
  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return GestureDetector(
  onTap: () {
    if (title == "Total Suraus") {
      Navigator.pushNamed(context, "/manageSuraus", arguments: "All");
    } else if (title == "Pending") {
      Navigator.pushNamed(context, "/manageSuraus", arguments: "pending");
    } else if (title == "Approved") {
      Navigator.pushNamed(context, "/manageSuraus", arguments: "approved");
    }
  },
  child: Card(
    color: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}
