import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color themeColor = const Color.fromARGB(255, 135, 172, 79);

  // ✅ Update Role
  Future<void> updateRole(String username, String newRole) async {
    await FirebaseFirestore.instance.collection('ajk_users').doc(username).update({
      'role': newRole,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Role ditukar ke $newRole ✅")),
    );
  }

  // ✅ Update Status
  Future<void> updateStatus(String username, String newStatus) async {
    await FirebaseFirestore.instance.collection('ajk_users').doc(username).update({
      'status': newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Status: $newStatus ✅")),
    );
  }

  // ✅ Delete user
  Future<void> deleteUser(String username) async {
    await FirebaseFirestore.instance.collection('ajk_users').doc(username).delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Pengguna dipadam ✅")),
    );
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

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var doc = users[index];
              var data = doc.data() as Map<String, dynamic>;

              String username = doc.id; // ✅ document ID = username
              String role = data['role'] ?? 'ajk';
              String status = data['status'] ?? 'pending';
              String surauName = data['surauName'] ?? '-';

              return Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.person, color: Colors.white),
                  ),

                  title: Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("Role: $role\nSurau: $surauName"),

                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
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
                          child: Text("Approve ✅", style: TextStyle(color: Colors.green))),
                      const PopupMenuItem(
                          value: 'reject',
                          child: Text("Reject ❌", style: TextStyle(color: Colors.red))),
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
}
