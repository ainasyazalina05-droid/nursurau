import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color themeColor = const Color(0xFF2E7D32);

  // ✅ Update Role
  Future<void> updateRole(String username, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('ajk_users').doc(username).update({
        'role': newRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Peranan pengguna dikemas kini kepada $newRole."),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ralat mengemas kini peranan: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ Update Status
  Future<void> updateStatus(String username, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('ajk_users').doc(username).update({
        'status': newStatus,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Status pengguna dikemas kini: $newStatus")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat mengemas kini status: $e"), backgroundColor: Colors.red),
      );
    }
  }

  // ✅ Delete user
  Future<void> deleteUser(String username) async {
    final confirm = await _confirmDelete(context, username);
    if (!confirm) return;

    try {
      await FirebaseFirestore.instance.collection('ajk_users').doc(username).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengguna berjaya dipadam."), backgroundColor: Colors.redAccent),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat memadam pengguna: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage AJK Users"),
        backgroundColor: themeColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ajk_users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!.docs;

          if (users.isEmpty) {
            return const Center(
              child: Text(
                "Tiada pengguna dijumpai.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final doc = users[index];
              final data = doc.data() as Map<String, dynamic>;

              final username = doc.id;
              final role = data['role'] ?? 'ajk';
              final status = data['status'] ?? 'pending';
              final surauName = data['surauName'] ?? '-';

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Role: $role\nSurau: $surauName\nStatus: $status"),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
                        deleteUser(username);
                      } else if (value == 'approve' || value == 'reject') {
                        updateStatus(username, value);
                      } else {
                        updateRole(username, value);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'ajk', child: Text("Jadikan AJK")),
                      const PopupMenuItem(value: 'admin_paid', child: Text("Jadikan Admin PAID")),
                      const PopupMenuItem(value: 'blocked', child: Text("Sekat Pengguna")),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'approve',
                        child: Text("Approve ✅", style: TextStyle(color: Colors.green)),
                      ),
                      const PopupMenuItem(
                        value: 'reject',
                        child: Text("Reject ❌", style: TextStyle(color: Colors.red)),
                      ),
                      const PopupMenuDivider(),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text("Padam Pengguna", style: TextStyle(color: Colors.red)),
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

  // ✅ Confirmation dialog before deleting user
  Future<bool> _confirmDelete(BuildContext context, String username) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Padam Pengguna"),
            content: Text("Adakah anda pasti untuk memadam pengguna '$username'?"),
            actions: [
              TextButton(
                child: const Text("Batal"),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                ),
                child: const Text("Padam"),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        ) ??
        false;
  }
}
