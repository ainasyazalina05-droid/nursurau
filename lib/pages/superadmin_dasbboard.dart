import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/admin_paid/manage_users_page.dart';
import 'package:nursurau/pages/admin_paid/manage_surau_page.dart';
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
  int totalPaids = 0;
  int totalUsers = 0;
  int totalDonations = 0;
  List<Map<String, dynamic>> pendingAdmins = [];
  bool isLoading = true;

  final String _pageTitle = "Dashboard SuperAdmin NurSurau";

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

      final paidSnapshot =
          await firestore.collection('admin_pejabat_agama').get();

      // ✅ Fixed this line only — collection name changed to 'ajk_users'
      final userSnapshot = await firestore.collection('ajk_users').get();

      setState(() {
        totalSuraus = surauSnapshot.size;
        approvedSuraus = approvedSnapshot.size;
        pendingSuraus = pendingSnapshot.size;
        totalPaids = paidSnapshot.size;
        totalUsers = userSnapshot.size; // fixed to ajk_users
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading reports: $e");
      setState(() => isLoading = false);
    }
  }

  void _logout() {
    Navigator.pop(context); // Atau navigate ke login page
  }

  // 🔹 Approve/Reject Admin PAID
  Future<void> approveAdmin(String docId) async {
    await FirebaseFirestore.instance
        .collection('admin_pejabat_agama')
        .doc(docId)
        .update({'status': 'active'});
    _fetchReportData();
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Log Keluar"),
        content: const Text("Adakah anda pasti ingin log keluar?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text("Ya, Log Keluar"),
          ),
        ],
      ),
    );
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
        title: const Text("SuperAdmin Dashboard"),
        backgroundColor: const Color(0xFF87AC4F),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Log Keluar",
                  style: TextStyle(color: Colors.white)),
            ),
          ),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout))
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF87AC4F)),
            )
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Selamat Datang, SuperAdmin!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF87AC4F),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Grid cards
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      ReportCard(
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
                        color: Colors.green.shade700,
                        onTap: () => _openSurauList("Approved"),
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
                      ReportCard(
                        icon: Icons.business,
                        title: "Pejabat Agama (PAID)",
                        count: totalPaids,
                        color: Colors.blue.shade700,
                        onTap: () {},
                      ),
                      ReportCard(
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF87AC4F),
                    ),
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
}

// 🔹 Kad laporan dengan animasi hover
class ReportCard extends StatefulWidget {
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
  State<ReportCard> createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
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
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(count.toString(),
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}

class SurauListPage extends StatelessWidget {
  final String statusFilter;

  const SurauListPage({super.key, required this.statusFilter});

  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance.collection('form');
    final filteredQuery = statusFilter.toLowerCase() == "all"
        ? query
        : query.where('status', isEqualTo: statusFilter.toLowerCase());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        title: Text(
          statusFilter == "All" ? "Semua Surau" : "Surau $statusFilter",
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: filteredQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final suraus = snapshot.data!.docs;
          if (suraus.isEmpty) {
            return const Center(child: Text("Tiada surau dijumpai."));
          }

          return ListView.builder(
            itemCount: suraus.length,
            itemBuilder: (context, index) {
              final data = suraus[index].data() as Map<String, dynamic>? ?? {};

              return ListTile(
                title: Text(data['surauName'] ?? '-'),
                subtitle: Text(data['surauAddress'] ?? '-'),
                trailing: Text(
                  (data['status'] ?? '-').toString().toUpperCase(),
                  style: TextStyle(
                    color: data['status'] == 'approved'
                        ? Colors.green
                        : data['status'] == 'pending'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageSurauPage(docId: suraus[index].id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
