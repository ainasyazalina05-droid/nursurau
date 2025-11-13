import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nursurau/pages/admin_paid/manage_users_page.dart';
import 'package:nursurau/pages/pending_paid_admins_page.dart';
import 'package:nursurau/pages/unified_login.dart';
import 'package:nursurau/pages/admin_paid/manage_surau_page.dart';

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
  int pendingPaids = 0;
  int totalUsers = 0;
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

      // 🔹 Surau data
      final surauSnapshot = await firestore.collection('form').get();
      final approvedSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'approved')
          .get();
      final pendingSnapshot = await firestore
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .get();

      // 🔹 PAID Admins
      final paidSnapshot = await firestore
          .collection('users')
          .where('userType', isEqualTo: 'PAID')
          .get();

      // 🔹 Pending PAID Admins
      final pendingPaidSnapshot = await firestore
          .collection('users')
          .where('userType', isEqualTo: 'PAID')
          .where('status', isEqualTo: 'pending')
          .get();

      // 🔹 AJK Users
      final userSnapshot = await firestore.collection('ajk_users').get();

      setState(() {
        totalSuraus = surauSnapshot.size;
        approvedSuraus = approvedSnapshot.size;
        pendingSuraus = pendingSnapshot.size;
        totalPaids = paidSnapshot.size;
        pendingPaids = pendingPaidSnapshot.size;
        totalUsers = userSnapshot.size;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading reports: $e");
      setState(() => isLoading = false);
    }
  }

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
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Batal",
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87AC4F),
              ),
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _logout(context); // Proceed logout
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

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UnifiedLoginPage()),
      (route) => false,
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
      backgroundColor: const Color(0xFF87AC4F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        title: const Text(
          "DASHBOARD SUPERADMIN NURSURAU",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                "LOG KELUAR",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF87AC4F),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SELAMAT DATANG, SUPERADMIN!",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
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
                        title: "KESELURUHAN SURAU",
                        count: totalSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () => _openSurauList("All"),
                      ),
                      ReportCard(
                        icon: Icons.check_circle,
                        title: "DILULUSKAN",
                        count: approvedSuraus,
                        color: const Color(0xFF87AC4F),
                        onTap: () => _openSurauList("Approved"),
                      ),
                      ReportCard(
                        icon: Icons.hourglass_bottom,
                        title: "MENUNGGU",
                        count: pendingSuraus,
                        color: Colors.orange.shade800,
                        onTap: () => _openSurauList("Pending"),
                      ),
                      ReportCard(
                        icon: Icons.business,
                        title: "ADMIN PAID",
                        count: totalPaids,
                        color: Colors.blue.shade700,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PendingPaidAdminsPage(),
                            ),
                          );
                        },
                      ),
                      ReportCard(
                        icon: Icons.people,
                        title: "PENGGUNA",
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
                  Center(
                    child: Text(
                      "TABURAN STATUS",
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
      height: 250,
      width: 250,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(show: false),
          sectionsSpace: 4,
          centerSpaceRadius: 45,
          sections: [
            PieChartSectionData(
              color: Colors.brown,
              value: (approved / total) * 100,
              title: "Diluluskan\n$approvedSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            PieChartSectionData(
              color: Colors.orange.shade700,
              value: (pending / total) * 100,
              title: "Surau Menunggu\n$pendingSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
            ),
            PieChartSectionData(
              color: const Color.fromARGB(255, 134, 176, 230),
              value: (pending / total) * 100,
              title: "Admin PAID Menunggu\n$pendingSuraus",
              radius: 70,
              titleStyle: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ ReportCard with hover effect
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: _isHovered
              ? (Matrix4.identity()..scale(1.03))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: widget.color.withOpacity(0.35)),
            boxShadow: [
              BoxShadow(
                color: _isHovered
                    ? Colors.black.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
                blurRadius: _isHovered ? 12 : 10,
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
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
        ),
      ),
    );
  }
}

// ✅ SurauListPage
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
      backgroundColor: const Color(0xFFF5F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        title: Text(
          statusFilter == "All"
              ? "Senarai Keseluruhan Surau"
              : "Surau ${statusFilter.toUpperCase()}",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: filteredQuery.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF87AC4F)),
            );
          }

          final suraus = snapshot.data!.docs;
          if (suraus.isEmpty) {
            return const Center(
              child: Text(
                "Tiada surau dijumpai.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: suraus.length,
            itemBuilder: (context, index) {
              final data = suraus[index].data() as Map<String, dynamic>? ?? {};
              final surauName = data['surauName'] ?? 'Nama tidak diketahui';
              final surauAddress =
                  data['surauAddress'] ?? 'Alamat tidak tersedia';
              final status = (data['status'] ?? '-').toString();

              Color statusColor;
              if (status == 'approved') {
                statusColor = Colors.green.shade700;
              } else if (status == 'pending') {
                statusColor = Colors.orange.shade700;
              } else {
                statusColor = Colors.red.shade700;
              }

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    surauName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E4A1E),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      surauAddress,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      border: Border.all(color: statusColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ManageSurauPage(docId: suraus[index].id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
