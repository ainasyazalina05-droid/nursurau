import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';

class SurauListPage extends StatelessWidget {
  final String filter;
  const SurauListPage({super.key, required this.filter});

  // Tajuk ikut filter
  String getTitle() {
    switch (filter.toLowerCase()) {
      case 'approved':
        return 'Surau Diluluskan';
      case 'pending':
        return 'Surau Menunggu Kelulusan';
      case 'rejected':
        return 'Surau Ditolak';
      default:
        return 'Keseluruhan Surau';
    }
  }

  String translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Diluluskan';
      case 'pending':
        return 'Menunggu Kelulusan';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Color(0xFF87AC4F);
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance.collection("form");

    if (filter != "all") {
      query = query.where("status", isEqualTo: filter);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF87AC4F),
        title: Text(
          getTitle(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text("Tiada data surau tersedia"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docSnapshot = docs[index];
              final Map<String, dynamic> docData =
                  (docSnapshot.data() as Map<String, dynamic>?) ?? {};

              final String name =
                  (docData['surauName'] ?? 'Tiada Nama').toString();
              final String status =
                  (docData['status'] ?? 'Unknown').toString();
              final String address =
                  (docData['address'] ?? '').toString();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF87AC4F),
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (address.isNotEmpty)
                        Text(
                          address,
                          style: const TextStyle(fontSize: 14),
                        ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: getStatusColor(status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          translateStatus(status).toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(status),
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ManageSurauPage(docId: docSnapshot.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings, size: 18),
                    label: const Text("Urus Surau"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF87AC4F),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
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
