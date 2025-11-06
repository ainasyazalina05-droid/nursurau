import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';
import 'surau_detail_page.dart';

class AdminPaidPage extends StatefulWidget {
  final String filter; // 'Pending' or 'Approved' or 'All'
  const AdminPaidPage({super.key, required this.filter});

  @override
  State<AdminPaidPage> createState() => _AdminPaidPageState();
}

class _AdminPaidPageState extends State<AdminPaidPage> {
  // choose stream depending on filter
  Stream<QuerySnapshot> _getStream() {
    final firestore = FirebaseFirestore.instance;
    if (widget.filter == 'Pending') {
      // pending items come from 'form' collection (status == 'pending')
      return firestore
          .collection('form')
          .where('status', isEqualTo: 'pending')
          .snapshots();
    } else {
      // Approved/All → list from 'suraus' collection (all docs)
      return firestore.collection('suraus').snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPendingPage = widget.filter == 'Pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        centerTitle: true,
        title: Text(
          widget.filter == 'Pending'
              ? 'Senarai Surau Menunggu'
              : widget.filter == 'Approved'
                  ? 'Senarai Surau (dari suraus)'
                  : 'Keseluruhan Surau',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF87AC4F)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada data surau dijumpai."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              // UI differences:
              // - Pending page: data comes from 'form' and we show status pending + Urus Surau
              // - Other pages: data comes from 'suraus' and we show Lihat Surau (open SurauDetailPage)
              if (isPendingPage) {
                // fields in 'form' collection (adjust keys if your fields named differently)
                final surauName = data['surauName'] ?? data['name'] ?? 'Nama tidak tersedia';
                final surauAddress = data['surauAddress'] ?? data['address'] ?? '-';
                // status is pending by query, show it explicitly
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surauName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF87AC4F),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(surauAddress, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // status label
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text("Status: Menunggu", style: TextStyle(color: Colors.orange)),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              icon: const Icon(Icons.settings),
                              label: const Text("Urus Surau"),
                              onPressed: () {
                                // Manage page works with form docId
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ManageSurauPage(docId: docId),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // from 'suraus' collection
                final surauName = data['name'] ?? 'Nama tidak tersedia';
                final surauAddress = data['address'] ?? '-';
                final imageUrl = data['imageUrl'] as String? ?? '';

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: ListTile(
                      leading: imageUrl.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                            )
                          : const Icon(Icons.mosque, color: Color(0xFF87AC4F), size: 40),
                      title: Text(
                        surauName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4E6C1E)),
                      ),
                      subtitle: Text(surauAddress),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E6C1E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text("Lihat Surau"),
                        onPressed: () {
                          // Open SurauDetailPage which reads from 'suraus' collection via surauId
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurauDetailPage(surauId: docId),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
