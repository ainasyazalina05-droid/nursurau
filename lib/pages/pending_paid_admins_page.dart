import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PendingPaidAdminsPage extends StatefulWidget {
  const PendingPaidAdminsPage({super.key});

  @override
  State<PendingPaidAdminsPage> createState() => _PendingPaidAdminsPageState();
}

class _PendingPaidAdminsPageState extends State<PendingPaidAdminsPage> {
  final CollectionReference paidCollection =
      FirebaseFirestore.instance.collection('admin_pejabat_agama');

  Future<void> approveAdmin(String docId) async {
    await paidCollection.doc(docId).update({'status': 'active'});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Admin PAID berjaya diluluskan!")),
    );
    setState(() {}); // refresh the list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Superadmin - PAID Pending Approval"),
        backgroundColor: const Color(0xFF87AC4F),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: paidCollection.where('status', isEqualTo: 'pending').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada admin PAID untuk diluluskan."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['username'] ?? ''),
                  subtitle: Text(data['surauName'] ?? ''),
                  trailing: ElevatedButton(
                    onPressed: () => approveAdmin(docs[index].id),
                    child: const Text("Luluskan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87AC4F),
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
