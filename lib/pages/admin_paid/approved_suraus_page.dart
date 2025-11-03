import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApprovedSurausPage extends StatelessWidget {
  const ApprovedSurausPage({super.key});

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return const Color(0xFF87AC4F);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Senarai Surau Diluluskan",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('suraus')
            .where('status', isEqualTo: 'approved')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text("Tiada surau diluluskan."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final imageUrl = data['imageUrl'] ?? '';
              final surauName = data['surauName'] ?? 'Nama tidak tersedia';
              final address = data['surauAddress'] ?? '-';
              final nazirName = data['nazirName'] ?? 'Tidak dinyatakan';
              final nazirPhone = data['nazirPhone'] ?? '-';
              final status = data['status'] ?? 'approved';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image section
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                      child: imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              width: double.infinity,
                              height: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 180,
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image,
                                    size: 60, color: Colors.grey),
                              ),
                            )
                          : Container(
                              height: 180,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported,
                                  size: 60, color: Colors.grey),
                            ),
                    ),
                    Padding(
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
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.location_on,
                                  color: Colors.grey, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Divider(thickness: 1),
                          const SizedBox(height: 6),
                          Text(
                            "Maklumat Nazir:",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Color(0xFF87AC4F), size: 18),
                              const SizedBox(width: 6),
                              Text(nazirName),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.phone,
                                  color: Color(0xFF87AC4F), size: 18),
                              const SizedBox(width: 6),
                              Text(nazirPhone),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
