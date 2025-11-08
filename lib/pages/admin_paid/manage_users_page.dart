import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nursurau/pages/unified_login.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color themeColor = const Color(0xFF87AC4F);

  // ✅ Logout function
  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const UnifiedLoginPage()),
      (route) => false,
    );
  }

  // ✅ Logout confirmation dialog
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
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
              ),
              onPressed: () {
                Navigator.pop(context);
                _logout(context);
              },
              child: const Text("Log Keluar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserRoleAndStatus(String username, String newRole,
      {String? newStatus}) async {
    try {
      final updateData = {
        'role': newRole,
        if (newStatus != null) 'status': newStatus,
      };

      await FirebaseFirestore.instance
          .collection('ajk_users')
          .doc(username)
          .update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Peranan dikemas kini kepada $newRole${newStatus != null ? ' & status $newStatus' : ''}"),
          backgroundColor: themeColor,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat: $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> updateStatus(String username, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('ajk_users')
          .doc(username)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status dikemas kini kepada $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Ralat mengemas kini status: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> deleteUser(String username) async {
    final confirm = await _confirmDelete(context, username);
    if (!confirm) return;

    try {
      await FirebaseFirestore.instance
          .collection('ajk_users')
          .doc(username)
          .delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Pengguna dipadam."), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Ralat memadam pengguna: $e"),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context, String username) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Padam Pengguna"),
            content: Text("Adakah anda pasti untuk memadam '$username'?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text("Batal")),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                child: const Text("Padam"),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Senarai Ahli Jawatankuasa Surau",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text("Log Keluar", style: TextStyle(color: Colors.white)),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ajk_users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Ralat: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada pengguna dijumpai."));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;

              final username = data['username'] ?? doc.id;
              final role = data['role'] ?? '-';
              final status = data['status'] ?? '-';
              final surauName = data['surauName'] ?? '-';

              return Card(
                elevation: 3,
                color: const Color(0xFFF7F4FB),
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Color(0xFF87AC4F),
                        child: Icon(Icons.person, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(username,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black)),
                            const SizedBox(height: 4),
                            Text("Peranan : ${role == 'ajk' ? 'AJK Surau' : role}",
                                style: const TextStyle(fontSize: 14)),
                            Text(
                              "Status : ${status == 'approved' ? 'Diluluskan' : status == 'blocked' ? 'Disekat' : status == 'pending' ? 'Menunggu Kelulusan' : status == 'rejected' ? 'Ditolak' : status}",
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text("Nama Surau : $surauName",
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF87AC4F)),
                        onSelected: (value) async {
                          switch (value) {
                            case 'ajk':
                              await updateUserRoleAndStatus(username, 'ajk',
                                  newStatus: 'approved');
                              break;
                            case 'blocked':
                              await updateUserRoleAndStatus(username, role,
                                  newStatus: 'blocked');
                              break;
                            case 'approve':
                              await updateStatus(username, 'approved');
                              break;
                            case 'reject':
                              await updateStatus(username, 'rejected');
                              break;
                            case 'delete':
                              await deleteUser(username);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                              value: 'ajk', child: Text("Jadikan AJK")),
                          const PopupMenuItem(
                              value: 'blocked', child: Text("Sekat Pengguna")),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'approve',
                            child: Text("Diluluskan",
                                style: TextStyle(color: Color(0xFF87AC4F))),
                          ),
                          const PopupMenuItem(
                            value: 'reject',
                            child: Text("Ditolak",
                                style: TextStyle(color: Colors.red)),
                          ),
                          const PopupMenuDivider(),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text("Padam Pengguna",
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
