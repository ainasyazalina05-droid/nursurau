import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/admin_paid/login_page.dart';
import 'package:nursurau/pages/admin_paid/manage_users_page.dart';
import 'package:nursurau/pages/admin_paid/paid.dart';

class PaidDashboard extends StatefulWidget {
  final String paidId;
  const PaidDashboard({super.key, required this.paidId});

  @override
  State<PaidDashboard> createState() => _PaidDashboardState();
}

class _PaidDashboardState extends State<PaidDashboard> {
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
    setState(() => isLoading = true);
    try {
      final firestore = FirebaseFirestore.instance;

      // 🔹 Semua surau (tak kira siapa submit)
      final surauSnapshot = await firestore.collection('form').get();
      final approvedSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'approved')
          .get();
      final pendingSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .get();

      // 🔹 Users/admin PAID hanya diri sendiri
      final userSnapshot = await firestore
          .collection('admin_pejabat_agama')
          .where('paidId', isEqualTo: widget.paidId)
          .get();

      // 🔹 Donations ikut paidId
      final donationSnapshot = await firestore
          .collection('donations')
          .where('paidId', isEqualTo: widget.paidId)
          .get();

      setState(() {
        totalSuraus = surauSnapshot.size;
        approvedSuraus = approvedSnapshot.size;
        pendingSuraus = pendingSnapshot.size;
        totalUsers = userSnapshot.size;
        totalDonations = donationSnapshot.size;
        isLoading = false;
      });

    } catch (e) {
      debugPrint("Error loading reports: $e");
      setState(() => isLoading = false);
    }
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const PaidLoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        title: const Text(
          "Dashboard PAID NurSurau",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang, Admin PAID!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF87AC4F)),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ReportCard(
                        icon: Icons.mosque,
                        title: "Keseluruhan Surau",
                        count: totalSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () => _openAdminPage("All"),
                      ),
                      ReportCard(
                        icon: Icons.check_circle,
                        title: "Diluluskan",
                        count: approvedSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () => _openAdminPage("Approved"),
                      ),
                      ReportCard(
                        icon: Icons.hourglass_bottom,
                        title: "Menunggu",
                        count: pendingSuraus,
                        color: Colors.orange.shade800,
                        onTap: () => _openAdminPage("Pending"),
                      ),
                      ReportCard(
                        icon: Icons.people,
                        title: "Pengguna",
                        count: totalUsers,
                        color: Colors.teal.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ManageUsersPage()),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Taburan Status Surau",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF87AC4F)),
                  ),
                  const SizedBox(height: 10),
                  Center(child: _buildPieChart()),
                ],
              ),
            ),
    );
  }

  Widget _buildPieChart() {
    final approved = approvedSuraus.toDouble();
    final pending = pendingSuraus.toDouble();
    final total = (approved + pending) == 0 ? 1 : (approved + pending);

    return SizedBox(
      height: 250,
      width: 250,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(show: false),
          sectionsSpace: 4,
          centerSpaceRadius: 45,
          sections: [
            PieChartSectionData(
              color: const Color(0xFF87AC4F),
              value: (approved / total) * 100,
              title: "Diluluskan\n$approvedSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.orange.shade700,
              value: (pending / total) * 100,
              title: "Menunggu\n$pendingSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  void _openAdminPage(String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPaidPage(filter: filter),
      ),
    );
  }
}

// 🔹 Reusable ReportCard widget
class ReportCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;
  final VoidCallback? onTap;

  const ReportCard({
    super.key,
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: color),
            const SizedBox(height: 10),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(count.toString(),
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
