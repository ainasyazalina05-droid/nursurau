import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/admin_paid/layout.dart';

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
      var surauSnapshot =
          await FirebaseFirestore.instance.collection('form').get();
      totalSuraus = surauSnapshot.size;

      var approvedSnapshot = await FirebaseFirestore.instance
          .collection('form')
          .where('status', isEqualTo: 'approved')
          .get();
      approvedSuraus = approvedSnapshot.size;

      var pendingSnapshot = await FirebaseFirestore.instance
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingSuraus = pendingSnapshot.size;

      var userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      totalUsers = userSnapshot.size;

      try {
        var donationSnapshot =
            await FirebaseFirestore.instance.collection('donations').get();
        totalDonations = donationSnapshot.size;
      } catch (e) {
        totalDonations = 0;
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("Error loading reports: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PAID Dashboard",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // 🟩 Grid Cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                        title: "Users",
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

  Widget _buildReportCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
  }) {
    return Card(
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
    );
  }

  Widget _buildPieChart() {
    final double approved = approvedSuraus.toDouble();
    final double pending = pendingSuraus.toDouble();
    final double total = (approved + pending) == 0 ? 1 : (approved + pending);

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
              value: approved == 0 ? 0.01 : (approved / total) * 100,
              title: "Approved\n$approvedSuraus",
              radius: 70,
              titleStyle: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            PieChartSectionData(
              color: Colors.orange,
              value: pending == 0 ? 0.01 : (pending / total) * 100,
              title: "Pending\n$pendingSuraus",
              radius: 70,
              titleStyle: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
