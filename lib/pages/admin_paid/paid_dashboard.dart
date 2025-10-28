import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/admin_paid/paid.dart';

class PaidDashboard extends StatefulWidget {
  const PaidDashboard({super.key});

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
    try {
      final firestore = FirebaseFirestore.instance;

      final surauSnapshot = await firestore.collection('form').get();
      final approvedSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'approved')
          .get();
      final pendingSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .get();
      final userSnapshot = await firestore.collection('users').get();
      final donationSnapshot = await firestore.collection('donations').get();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PAID Dashboard",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Report Cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildReportCard(
                        Icons.mosque,
                        "All Suraus",
                        totalSuraus,
                        const Color(0xFF2E7D32),
                        onTap: () => _openAdminPage(context, "All"),
                      ),
                      _buildReportCard(
                        Icons.check_circle,
                        "Approved",
                        approvedSuraus,
                        Colors.green.shade600,
                        onTap: () => _openAdminPage(context, "Approved"),
                      ),
                      _buildReportCard(
                        Icons.hourglass_bottom,
                        "Pending",
                        pendingSuraus,
                        Colors.orange,
                        onTap: () => _openAdminPage(context, "Pending"),
                      ),
                      _buildReportCard(
                        Icons.people,
                        "Users",
                        totalUsers,
                        Colors.teal,
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  const Text(
                    "Surau Status Distribution",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Center(child: _buildPieChart()),
                ],
              ),
            ),
    );
  }

  Widget _buildReportCard(
    IconData icon,
    String title,
    int count,
    Color color, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                count.toString(),
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
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
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              color: Colors.green.shade600,
              value: (approved / total) * 100,
              title: "Approved\n$approvedSuraus",
              radius: 70,
              titleStyle: const TextStyle(
                  fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: (pending / total) * 100,
              title: "Pending\n$pendingSuraus",
              radius: 70,
              titleStyle: const TextStyle(
                  fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _openAdminPage(BuildContext context, String filter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminPaidPage(filter: filter),
      ),
    );
  }
}
