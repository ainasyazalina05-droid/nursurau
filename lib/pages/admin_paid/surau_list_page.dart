import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';

class SurauListPage extends StatelessWidget {
  final String filter;
  const SurauListPage({super.key, required this.filter});

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection("form");

    if (filter != "all") {
      query = query.where("status", isEqualTo: filter);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Surau - ${filter.toUpperCase()}")),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No surau found"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docSnapshot = docs[index];
              final Map<String, dynamic> docData =
                  (docSnapshot.data() as Map<String, dynamic>?) ?? {};

              final String name =
                  (docData['surauName'] ?? 'Unnamed').toString();
              final String status =
                  (docData['status'] ?? 'Unknown').toString();
              final String address =
                  (docData['address'] ?? '').toString();

              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: ListTile(
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (address.isNotEmpty) Text(address),
                      Text("Status: $status"),
                    ],
                  ),
                  isThreeLine: address.isNotEmpty,
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ManageSurauPage(docId: docSnapshot.id),
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
