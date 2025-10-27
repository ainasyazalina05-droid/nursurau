import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color themeColor = const Color(0xFF2E7D32); // unified with PAID Dashboard theme

  // ✅ Update Role
  Future<void> updateRole(String username, String newRole) async {
    await FirebaseFirestore.instance.collection('ajk_users').doc(username).update({
      'role': newRole,
    });

<<<<<<< HEAD
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

  // ✅ Function to delete user
  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengguna berjaya dipadam."),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ralat memadam pengguna: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
=======
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
>>>>>>> 82a214dc11ea47cc824b919c08df497ed11207ee
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
<<<<<<< HEAD
        title: const Text("Admin - Pengurusan Pengguna"),
=======
        title: const Text("Manage AJK Users"),
>>>>>>> 82a214dc11ea47cc824b919c08df497ed11207ee
        backgroundColor: themeColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('ajk_users').snapshots(),
        builder: (context, snapshot) {
<<<<<<< HEAD
          if (snapshot.hasError) {
            return const Center(child: Text("Ralat memuat data pengguna."));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
=======
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
>>>>>>> 82a214dc11ea47cc824b919c08df497ed11207ee

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
<<<<<<< HEAD
              final user = users[index];
              final userId = user.id;
              final name = user['name'] ?? 'Tiada Nama';
              final email = user['email'] ?? '-';
              final role = user['role'] ?? 'normal';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: themeColor,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text("$email\nPeranan: $role"),
                  isThreeLine: true,
=======
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

>>>>>>> 82a214dc11ea47cc824b919c08df497ed11207ee
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'delete') {
<<<<<<< HEAD
                        final confirm = await _confirmDelete(context, name);
                        if (confirm) deleteUser(userId);
=======
                        deleteUser(username);
                      } else if (value == 'approve' || value == 'reject') {
                        updateStatus(username, value);
>>>>>>> 82a214dc11ea47cc824b919c08df497ed11207ee
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
<<<<<<< HEAD
                        value: 'ajk',
                        child: Text("Jadikan AJK"),
                      ),
                      const PopupMenuItem(
                        value: 'admin_paid',
                        child: Text("Jadikan Admin PAID"),
                      ),
=======
                          value: 'reject',
                          child: Text("Reject ❌", style: TextStyle(color: Colors.red))),
>>>>>>> 82a214dc11ea47cc824b919c08df497ed11207ee
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
  Future<bool> _confirmDelete(BuildContext context, String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Padam Pengguna"),
            content: Text("Adakah anda pasti untuk memadam pengguna '$name'?"),
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
