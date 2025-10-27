import 'package:flutter/material.dart';
import 'package:nursurau/pages/admin_paid/report_page.dart';
import 'paid_dashboard.dart';


class AdminLayout extends StatefulWidget {
  final Widget child;
  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  int selectedIndex = 0;

  void _navigate(int index) {
    setState(() => selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const PaidDashboard()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ManageSurauPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const ManageUserPage()));
        break;
      case 3:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminReportsPage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // 🟩 Sidebar
          Container(
            width: 220,
            color: const Color(0xFF2E7D32),
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  "PAID Admin",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _buildMenuItem(Icons.dashboard, "Dashboard", 0),
                _buildMenuItem(Icons.mosque, "Manage Surau", 1),
                _buildMenuItem(Icons.people, "Manage User", 2),
                _buildMenuItem(Icons.bar_chart, "Reports", 3),
              ],
            ),
          ),

          // 🧾 Main content
          Expanded(
            child: Container(
              color: const Color(0xFFF7F9F8),
              padding: const EdgeInsets.all(24.0),
              child: widget.child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, int index) {
    bool isSelected = selectedIndex == index;
    return InkWell(
      onTap: () => _navigate(index),
      child: Container(
        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 10),
            Text(title,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
