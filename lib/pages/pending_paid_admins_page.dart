import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== PendingPaidAdminsPage =====
class PendingPaidAdminsPage extends StatefulWidget {
  const PendingPaidAdminsPage({super.key});

  @override
  State<PendingPaidAdminsPage> createState() => _PendingPaidAdminsPageState();
}

class _PendingPaidAdminsPageState extends State<PendingPaidAdminsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        title: const Text(
          "ADMIN PAID MENUNGGU",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('userType', isEqualTo: 'PAID')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF87AC4F)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "Tiada admin PAID belum diluluskan.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final admins = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: admins.length,
            itemBuilder: (context, index) {
              final admin = admins[index];
              final data = admin.data() as Map<String, dynamic>;

              return Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(vertical: 10),
                shadowColor: Colors.black.withOpacity(0.1),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  leading: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF87AC4F),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    data['username'] ?? 'Tiada Nama',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Text(
                    "Surau: ${data['surauName'] ?? '-'}",
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ConfirmApprovalPage(
                            docId: admin.id,
                            username: data['username'] ?? '-',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87AC4F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Urus",
                      style: TextStyle(color: Colors.white),
                    ),
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

// ===== ConfirmApprovalPage =====
class ConfirmApprovalPage extends StatelessWidget {
  final String docId;
  final String username;

  const ConfirmApprovalPage(
      {super.key, required this.docId, required this.username});

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(docId)
          .update({'status': newStatus});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'active'
                ? 'Admin telah diluluskan ✅'
                : 'Admin telah ditolak ❌',
          ),
          backgroundColor: newStatus == 'active' ? Colors.green : Colors.red,
        ),
      );

      Navigator.pop(context); // kembali ke PendingPaidAdminsPage
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ralat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        title: const Text(
          "Pengesahan Admin",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF87AC4F),
                  child: const Icon(Icons.person_outline,
                      size: 50, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  "Adakah anda pasti ingin mengurus admin:\n\n$username?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, 'rejected'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Batal/Tolak",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateStatus(context, 'active'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87AC4F),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        "Luluskan",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
