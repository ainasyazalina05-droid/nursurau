import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final Color themeColor = const Color.fromARGB(255, 135, 172, 79);

  // ✅ Function to update user role
  Future<void> updateRole(String userId, String newRole) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'role': newRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Role pengguna dikemas kini kepada $newRole")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat mengemas kini role: $e")),
      );
    }
  }

  // ✅ Function to delete user document
  Future<void> deleteUser(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pengguna berjaya dipadam.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat memadam pengguna: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin - Manage Users"),
        backgroundColor: themeColor,
      ),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text("Ralat memuat data pengguna."));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              String userId = user.id;
              String name = user['name'] ?? 'Tiada Nama';
              String email = user['email'] ?? '-';
              String role = user['role'] ?? 'normal';

              return Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person, color: Colors.white),
                    backgroundColor: Color.fromARGB(255, 135, 172, 79),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(email),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'delete') {
                        deleteUser(userId);
                      } else {
                        updateRole(userId, value);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'normal',
                        child: Text("Jadikan Normal User"),
                      ),
                      const PopupMenuItem(
                        value: 'ajk',
                        child: Text("Jadikan AJK"),
                      ),
                      const PopupMenuItem(
                        value: 'admin_paid',
                        child: Text("Jadikan Admin PAID"),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          "Padam Pengguna",
                          style: TextStyle(color: Colors.red),
                        ),
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
