import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailPage extends StatefulWidget {
  final String surauId; // auto ID dari koleksi 'suraus'
  const SurauDetailPage({super.key, required this.surauId});

  @override
  State<SurauDetailPage> createState() => _SurauDetailPageState();
}

class _SurauDetailPageState extends State<SurauDetailPage> {
  Map<String, dynamic>? surauData;
  Map<String, dynamic>? nazirData;

  @override
  void initState() {
    super.initState();
    _fetchSurauData();
  }

  Future<void> _fetchSurauData() async {
    try {
      final surauDoc = await FirebaseFirestore.instance
          .collection('suraus')
          .doc(widget.surauId)
          .get();

      if (surauDoc.exists) {
        final data = surauDoc.data() as Map<String, dynamic>;
        setState(() {
          surauData = data;
        });

        // kalau ada ajkId, ambil maklumat nazir dari ajk_users
        final ajkId = data['ajkId'];
        if (ajkId != null && ajkId.toString().isNotEmpty) {
          final nazirDoc = await FirebaseFirestore.instance
              .collection('ajk_users')
              .doc(ajkId)
              .get();

          if (nazirDoc.exists) {
            setState(() {
              nazirData = nazirDoc.data();
            });
          }
        }
      }
    } catch (e) {
      debugPrint('⚠ Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MAKLUMAT SURAU",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87AC4F),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: surauData == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Gambar Surau
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (surauData!['imageUrl'] != null &&
                            surauData!['imageUrl'].toString().isNotEmpty)
                        ? Image.network(
                            surauData!['imageUrl'],
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.image, size: 80, color: Colors.grey),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // ✅ Nama & alamat surau
                  Text(
                    surauData!['name'] ?? 'Nama tidak tersedia',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF87AC4F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          surauData!['address'] ?? '-',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  // ✅ Maklumat Nazir (daripada ajk_users)
                  const SizedBox(height: 10),
                  const Text(
                    "Maklumat Nazir",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _infoRow("Nama Nazir", surauData?['nazirName'] ?? 'Tiada'),
                  _infoRow("No. Telefon", surauData?['nazirPhone'] ?? 'Tiada'),

                  const SizedBox(height: 20),
                  const Divider(),

                  // ✅ Status
                  _infoRow(
                    "Status",
                    (surauData!['approved'] == true)
                        ? "Diluluskan"
                        : "Belum Dimasukkan",
                    valueColor: (surauData!['approved'] == true)
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              "$title:",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: valueColor ?? Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}