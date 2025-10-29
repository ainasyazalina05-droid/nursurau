import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/admin_paid/paid.dart';
import 'package:nursurau/pages/admin_paid/manage_users_page.dart';


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
      final userSnapshot = await firestore.collection('ajk_users').get();
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
      backgroundColor: const Color(0xFFF2F7F3),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "PAID Dashboard",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    width: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 30),

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
                        Colors.green.shade700,
                        onTap: () => _openAdminPage(context, "Approved"),
                      ),
                      _buildReportCard(
                        Icons.hourglass_bottom,
                        "Pending",
                        pendingSuraus,
                        Colors.orange.shade800,
                        onTap: () => _openAdminPage(context, "Pending"),
                      ),
                      _buildReportCard(
                        Icons.people,
                        "Users",
                        totalUsers,
                        Colors.teal.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ManageUsersPage()),
                            );
                            },
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
                  const SizedBox(height: 20),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF1B5E20).withOpacity(0.35),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B5E20).withOpacity(0.1),
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
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
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
              color: Colors.green.shade600,
              value: (approved / total) * 100,
              title: "Approved\n$approvedSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.orange.shade700,
              value: (pending / total) * 100,
              title: "Pending\n$pendingSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
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
