import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/pages/admin_paid/paid_appbar.dart';

class PendingPaidAdminsPage extends StatefulWidget {
  const PendingPaidAdminsPage({super.key});

  @override
  State<PendingPaidAdminsPage> createState() => _PendingPaidAdminsPageState();
}

class _PendingPaidAdminsPageState extends State<PendingPaidAdminsPage> {
  final CollectionReference paidCollection =
      FirebaseFirestore.instance.collection('users');

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
     // ✅ Use PaidAppBar with white back button
      appBar: const PaidAppBar(
        title: "ADMIN PAID PENDING",
        showBackButton: true, // This makes the back icon white
      ),


      body: StreamBuilder<QuerySnapshot>(
        stream: paidCollection
            .where('userType', isEqualTo: 'PAID')
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text("Tiada admin PAID untuk diluluskan."));
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
