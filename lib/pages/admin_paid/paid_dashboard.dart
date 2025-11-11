import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/admin_paid/manage_users_page.dart';
import 'package:nursurau/pages/admin_paid/paid.dart';
import 'package:nursurau/pages/unified_login.dart';

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
  int totalAjk = 0;
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

      final surauSnapshot = await firestore.collection('form').get();
      final approvedSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'approved')
          .get();
      final pendingSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .get();
      final ajkSnapshot = await firestore.collection('ajk_users').get();

      setState(() {
        totalSuraus = surauSnapshot.size;
        approvedSuraus = approvedSnapshot.size;
        pendingSuraus = pendingSnapshot.size;
        totalAjk = ajkSnapshot.size;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading reports: $e");
      setState(() => isLoading = false);
    }
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UnifiedLoginPage()),
      (route) => false,
    );
  }

  // ✅ Function to show logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Log Keluar"),
          content: const Text("Adakah anda pasti mahu log keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF87AC4F),
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _logout(context); // Continue logout
              },
              child: const Text(
                "Log Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87AC4F), // Green background
      appBar: AppBar(
  backgroundColor: const Color(0xFF87AC4F), 
  centerTitle: true,
  title: const Text(
    "DASHBOARD PAID NURSURAU",
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
  ),
  actions: [
    IconButton(
      onPressed: () => _showLogoutDialog(context),
      icon: const Icon(
        Icons.logout,
        color: Colors.white,
        size: 30, // BESARKAN ICON
      ),
      mouseCursor: SystemMouseCursors.click, // cursor jari bila hover
    ),
  ],
),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF87AC4F)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SELAMAT DATANG , ADMIN PAID!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text to contrast green
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Report cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      ReportCard(
                        icon: Icons.mosque,
                        title: "KESELURUHAN SURAU",
                        count: totalSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () => _openAdminPage("All"),
                      ),
                      ReportCard(
                        icon: Icons.check_circle,
                        title: "DILULUSKAN",
                        count: approvedSuraus,
                        color: Colors.green.shade700,
                        onTap: () => _openAdminPage("Approved"),
                      ),
                      ReportCard(
                        icon: Icons.hourglass_bottom,
                        title: "MENUNGGU",
                        count: pendingSuraus,
                        color: Colors.orange.shade800,
                        onTap: () => _openAdminPage("Pending"),
                      ),
                      ReportCard(
                        icon: Icons.people,
                        title: "PENGGUNA",
                        count: totalAjk,
                        color: Colors.teal.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ManageUsersPage()),
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Pie chart
                 Center(
  child: const Text(
    "TABURAN STATUS SURAU",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
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
      height: 300,
      width: 300,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(show: false),
          sectionsSpace: 4,
          centerSpaceRadius: 45,
          sections: [
            PieChartSectionData(
              color: Colors.brown,
              value: (approved / total) * 100,
              title: "DILULUSKAN\n$approvedSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.orange.shade700,
              value: (pending / total) * 100,
              title: "MENUNGGU\n$pendingSuraus",
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
      MaterialPageRoute(builder: (_) => AdminPaidPage(filter: filter)),
    );
  }
}

// 🔹 Reusable ReportCard widget
class ReportCard extends StatefulWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ReportCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => hover = true),
            onExit: (_) => setState(() => hover = false),
            child: GestureDetector(
              onTap: widget.onTap,
              child: AnimatedScale(
                scale: hover ? 1.25 : 1.0,      // bigger bila hover
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                child: Icon(
                  widget.icon,
                  size: 46,
                  color: widget.color,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),

          const SizedBox(height: 6),

          Text(
            widget.count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
          ),
        ],
      ),
    );
  }
}


