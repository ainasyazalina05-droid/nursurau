import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donations'),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('donations')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data!.docs;

          if (donations.isEmpty) {
            return const Center(child: Text('No active donations.'));
          }

          return ListView.builder(
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final data = donations[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(data['name'] ?? 'No Title'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: data['imageUrl'] != null &&
                          data['imageUrl'].isNotEmpty
                      ? Image.network(data['imageUrl'],
                          width: 60, height: 60, fit: BoxFit.cover)
                      : null,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(data['name'] ?? ''),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['description'] ?? ''),
                            const SizedBox(height: 10),
                            Text('Bank Account: ${data['bankAccount'] ?? '-'}'),
                            if (data['qrUrl'] != null &&
                                data['qrUrl'].isNotEmpty)
                              Image.network(data['qrUrl'],
                                  width: 200, height: 200),
                          ],
                        ),
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
