import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/unified_login.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int totalSuraus = 0;
  int approvedSuraus = 0;
  int pendingSuraus = 0;
  int totalUsers = 0;
  int totalDonations = 0;
  List<Map<String, dynamic>> pendingAdmins = [];
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

      // 🔹 Surau
      final surauSnapshot = await firestore.collection('form').get();
      final approvedSnapshot = await firestore.collection('form')
          .where('status', isEqualTo: 'approved').get();
      final pendingSnapshot = await firestore.collection('form')
          .where('status', isEqualTo: 'pending').get();

      // 🔹 Users
      final userSnapshot = await firestore.collection('ajk_users').get();
      final donationSnapshot = await firestore.collection('donations').get();

      // 🔹 Pending Admin PAID
      final pendingAdminsSnapshot = await firestore
          .collection('admin_pejabat_agama')
          .where('status', isEqualTo: 'pending')
          .get();
      pendingAdmins = pendingAdminsSnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

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

  // 🔹 Approve/Reject Admin PAID
  Future<void> approveAdmin(String docId) async {
    await FirebaseFirestore.instance
        .collection('admin_pejabat_agama')
        .doc(docId)
        .update({'status': 'active'});
    _fetchReportData();
  }

  Future<void> rejectAdmin(String docId) async {
    await FirebaseFirestore.instance
        .collection('admin_pejabat_agama')
        .doc(docId)
        .delete();
    _fetchReportData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          _pageTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF87AC4F),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Text & icon color
              ),
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "Log Keluar",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang, SuperAdmin!",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF87AC4F)),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      buildReportCard(
                        icon: Icons.mosque,
                        title: "Keseluruhan Surau",
                        count: totalSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () {
                          // Boleh buka page semua surau
                        },
                      ),
                      buildReportCard(
                        icon: Icons.check_circle,
                        title: "Diluluskan",
                        count: approvedSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () {},
                      ),
                      buildReportCard(
                        icon: Icons.hourglass_bottom,
                        title: "Menunggu",
                        count: pendingSuraus,
                        color: Colors.orange.shade800,
                        onTap: () {},
                      ),
                      buildReportCard(
                        icon: Icons.people,
                        title: "Pengguna",
                        count: totalUsers,
                        color: Colors.teal.shade700,
                        onTap: () {},
                      ),
                      buildReportCard(
                        icon: Icons.admin_panel_settings,
                        title: "Admin PAID Pending",
                        count: pendingAdmins.length,
                        color: Colors.redAccent,
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.7,
                                  child: ListView.builder(
                                    itemCount: pendingAdmins.length,
                                    itemBuilder: (context, index) {
                                      final admin = pendingAdmins[index];
                                      return ListTile(
                                        title: Text(admin['username']),
                                        subtitle: Text(admin['email'] ?? ''),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.check, color: Colors.green),
                                              onPressed: () => approveAdmin(admin['id']),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.close, color: Colors.red),
                                              onPressed: () => rejectAdmin(admin['id']),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "Taburan Status Surau",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Center(
                    child: SizedBox(
                      height: 250,
                      width: 250,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: const Color(0xFF87AC4F),
                              value: approvedSuraus.toDouble(),
                              title: "Diluluskan\n$approvedSuraus",
                              radius: 70,
                              titleStyle: const TextStyle(color: Colors.white),
                            ),
                            PieChartSectionData(
                              color: Colors.orange.shade700,
                              value: pendingSuraus.toDouble(),
                              title: "Menunggu\n$pendingSuraus",
                              radius: 70,
                              titleStyle: const TextStyle(color: Colors.white),
                            ),
                          ],
                          borderData: FlBorderData(show: false),
                          centerSpaceRadius: 45,
                          sectionsSpace: 4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // 🔹 ReportCard function sama macam Admin PAID
  Widget buildReportCard({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.35)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 46, color: color),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(count.toString(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutDialog(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UnifiedLoginPage()),
      (route) => false,
    );
  }
}

String get _pageTitle {
    var _currentIndex;
    switch (_currentIndex) {
      case 0:
        return "Sumbangan";
      case 1:
        return "Hebahan";
      case 2:
        return "Maklumat Surau";
      default:
        return "Dashboard";
    }
  }
