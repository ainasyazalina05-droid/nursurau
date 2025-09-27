import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sumbangan Terbuka"),
        backgroundColor: const Color(0xFF2F5D50),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .orderBy('createdAt', descending: true) // newest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada sumbangan terbuka."));
          }

          final donations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final data = donations[index].data() as Map<String, dynamic>;

              return Card(
                color: const Color(0xFFF5EFD1),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'] ?? '',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (data['amount'] != null)
                        Text('Jumlah Sasaran: RM ${data['amount']}'),
                      if (data['description'] != null)
                        Text('Keterangan: ${data['description']}'),
                      if (data['account'] != null)
                        Text('Bank / Akaun: ${data['account']}'),
                      if (data['contact'] != null)
                        Text('No Telefon AJK: ${data['contact']}'),
                      const SizedBox(height: 12),
                      if (data['qrUrl'] != null && data['qrUrl'] != "")
                        Center(
                          child: Image.network(
                            data['qrUrl'],
                            height: 120,
                            fit: BoxFit.contain,
                          ),
                        ),
                      const SizedBox(height: 4),
                      if (data['createdAt'] != null)
                        Text(
                          'Tarikh Cipta: ${DateTime.parse(data["createdAt"]).day}-${DateTime.parse(data["createdAt"]).month}-${DateTime.parse(data["createdAt"]).year}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
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
