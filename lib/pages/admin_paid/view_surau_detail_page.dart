import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailsPage extends StatefulWidget {
  final String docId; // 🔥 ubah nama dari ajkId → docId

  const SurauDetailsPage({super.key, required this.docId});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  Map<String, dynamic>? surauData;
  Map<String, dynamic>? ajkData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    try {
      final formRef =
          FirebaseFirestore.instance.collection('form').doc(widget.docId); // ✅ betul

      final surauSnap = await formRef.get();
      final ajkSnap = await formRef.collection('ajk').doc('ajk_data').get();

      if (mounted) {
        setState(() {
          surauData = surauSnap.data();
          ajkData = ajkSnap.data();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Maklumat Surau"),
        backgroundColor: Colors.green[700],
      ),
      body: surauData == null
          ? const Center(child: Text("Tiada data dijumpai"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  if (surauData?['imageUrl'] != null &&
                      (surauData?['imageUrl'] as String).isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        surauData!['imageUrl'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    surauData?['surauName'] ?? '-',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(surauData?['surauAddress'] ?? '-',
                      style: const TextStyle(fontSize: 16)),
                  const Divider(height: 30, thickness: 1),
                  const Text(
                    "Maklumat AJK",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildInfoRow("Nama Nazir", ajkData?['ajkName']),
                  _buildInfoRow("No. IC", ajkData?['ic']),
                  _buildInfoRow("No. Telefon", ajkData?['phone']),
                  _buildInfoRow("Email", ajkData?['email']),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
          Flexible(
            child: Text(value ?? '-',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
