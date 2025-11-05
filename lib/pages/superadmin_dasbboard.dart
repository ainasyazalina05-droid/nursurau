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

      final surauSnapshot = await firestore.collection('form').get();
      final approvedSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'approved')
          .get();
      final pendingSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .get();
      final paidSnapshot = await firestore.collection('admin_pejabat_agama').get();
      final userSnapshot = await firestore.collection('users').get();

      setState(() {
        totalSuraus = surauSnapshot.size;
        approvedSuraus = approvedSnapshot.size;
        pendingSuraus = pendingSnapshot.size;
        totalPaids = paidSnapshot.size;
        totalUsers = userSnapshot.size;
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
      MaterialPageRoute(builder: (_) => const UnifiedLoginPage()),
      (route) => false,
    );
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

  void _openSurauList(String statusFilter) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurauListPage(statusFilter: statusFilter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F3),
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
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Log Keluar",
                  style: TextStyle(color: Colors.white)),
            ),
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
                    children: [
                      ReportCard(
                        icon: Icons.mosque,
                        title: "Keseluruhan Surau",
                        count: totalSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () => _openSurauList("All"),
                      ),
                      ReportCard(
                        icon: Icons.check_circle,
                        title: "Diluluskan",
                        count: approvedSuraus,
                        color: Colors.green.shade700,
                        onTap: () => _openSurauList("Approved"),
                      ),
                      ReportCard(
                        icon: Icons.hourglass_bottom,
                        title: "Menunggu",
                        count: pendingSuraus,
                        color: Colors.orange.shade800,
                        onTap: () => _openSurauList("Pending"),
                      ),
                      ReportCard(
                        icon: Icons.business,
                        title: "Pejabat Agama (PAID)",
                        count: totalPaids,
                        color: Colors.blue.shade700,
                        onTap: () {},
                      ),
                      ReportCard(
                        icon: Icons.people,
                        title: "Pengguna",
                        count: totalUsers,
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

                  const Text(
                    "Taburan Status Surau",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF87AC4F),
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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, size: 46, color: widget.color),
                const SizedBox(height: 10),
                Text(widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(widget.count.toString(),
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🔹 Senarai Surau untuk setiap status
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
              final surau = suraus[index];
              return ListTile(
                title: Text(surau['surauName'] ?? '-'),
                subtitle: Text(surau['surauAddress'] ?? '-'),
                trailing: Text(
                  (surau['status'] ?? '-').toUpperCase(),
                  style: TextStyle(
                    color: surau['status'] == 'approved'
                        ? Colors.green
                        : surau['status'] == 'pending'
                            ? Colors.orange
                            : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManageSurauPage(docId: surau.id),
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
