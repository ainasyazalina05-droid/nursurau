import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';
import 'surau_detail_page.dart'; // class SurauDetailPage({required this.surauId})

class AdminPaidPage extends StatefulWidget {
  final String filter; // 'All', 'Approved', 'Pending'
  const AdminPaidPage({super.key, required this.filter});

  @override
  State<AdminPaidPage> createState() => _AdminPaidPageState();
}

class _AdminPaidPageState extends State<AdminPaidPage> {
  Stream<QuerySnapshot> _getStreamForFilter() {
    final firestore = FirebaseFirestore.instance;
    if (widget.filter == 'Pending') {
      return firestore.collection('form').where('status', isEqualTo: 'pending').snapshots();
    } else if (widget.filter == 'Approved') {
      // Approved page uses suraus collection
      return firestore.collection('suraus').snapshots();
    } else {
      // All → we will use form collection (stream) as requested
      return firestore.collection('form').snapshots();
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPendingPage = widget.filter == 'Pending';
    final isApprovedPage = widget.filter == 'Approved';
    final isAllPage = widget.filter == 'All';

    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // arrow putih
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          isPendingPage
              ? 'Senarai Surau Menunggu'
              : isApprovedPage
                  ? 'Senarai Surau Diluluskan'
                  : 'Keseluruhan Surau',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getStreamForFilter(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF87AC4F)));
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
              final data = (doc.data() as Map<String, dynamic>?) ?? {};
              final docId = doc.id;

              // Different sources:
              // - Approved page: collection 'suraus' (fields likely: name, address, imageUrl, approved)
              // - Pending / All pages: collection 'form' (fields likely: surauName, surauAddress, status, surauId)
              if (isApprovedPage) {
                // suraus doc
                final name = data['name'] ?? '-';
                final address = data['address'] ?? '-';
                final imageUrl = (data['imageUrl'] ?? '').toString();

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.mosque, color: Color(0xFF87AC4F), size: 40),
                    title: Text(
                      name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4E6C1E)),
                    ),
                    subtitle: Text(address),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E6C1E),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        // suraus docId is the surauId expected by SurauDetailPage
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => SurauDetailPage(surauId: docId)),
                        );
                      },
                      child: const Text("Lihat Surau"),
                    ),
                  ),
                );
              } else {
                // is Pending or All -> docs from collection 'form'
                final surauName = data['surauName'] ?? data['name'] ?? '-';
                final surauAddress = data['surauAddress'] ?? data['address'] ?? '-';
                final status = (data['status'] ?? '').toString().toLowerCase();
                final isApproved = status == 'approved';
                final showStatus = isAllPage; // show status only on All page

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surauName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF87AC4F)),
                        ),
                        const SizedBox(height: 6),
                        Text(surauAddress, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        if (showStatus)
                          Text(
                            isApproved ? "Diluluskan" : "Menunggu",
                            style: TextStyle(fontWeight: FontWeight.bold, color: _statusColor(status)),
                          ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isApproved ? const Color(0xFF4E6C1E) : Colors.orange.shade800,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(isApproved ? Icons.visibility : Icons.settings),
                            label: Text(isApproved ? "Lihat Surau" : "Urus Surau"),
                            onPressed: () {
                              if (isApproved) {
                                // For approved forms we expect a field 'surauId' that points to the suraus collection doc id.
                                final surauId = data['surauId'] ?? data['surausId'] ?? data['surau_id'];
                                if (surauId != null && surauId.toString().isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => SurauDetailPage(surauId: surauId.toString())),
                                  );
                                } else {
                                  // fallback: inform user and open Manage page to let admin sync/create surau doc
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tiada surauId. Sila buka halaman Urus untuk sync data.')),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ManageSurauPage(docId: docId)),
                                  );
                                }
                              } else {
                                // pending -> Manage page uses form docId
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ManageSurauPage(docId: docId)),
                                );
                              }
                            },
                          ),
                        ),
                      ],
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
