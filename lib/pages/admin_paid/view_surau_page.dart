import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailsPage extends StatefulWidget {
  final String docId; // ID dokumen dalam 'suraus'

  const SurauDetailsPage({super.key, required this.docId});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  Map<String, dynamic>? surauData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSurauDetails();
  }

  Future<void> _fetchSurauDetails() async {
    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('suraus')
          .doc(widget.docId)
          .get();

      if (docSnap.exists) {
        setState(() {
          surauData = docSnap.data();
          isLoading = false;
        });
      } else {
        setState(() {
          surauData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching surau details: $e');
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

    if (surauData == null) {
      return const Scaffold(
        body: Center(child: Text("Tiada maklumat surau dijumpai")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(surauData?['surauName'] ?? 'Maklumat Surau'),
        backgroundColor: Colors.green[700],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              surauData?['address'] ?? 'Alamat tidak tersedia',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),

            _buildInfoRow('AJK ID', surauData?['ajkId']),
            _buildInfoRow('Status', surauData?['approved'] == true ? 'Approved' : 'Pending'),
            const Divider(height: 30, thickness: 1),

            const Text(
              "Maklumat Lain",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            _buildInfoRow('Followers Tokens',
                (surauData?['followersTokens'] as List?)?.join('\n')),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value ?? '-', textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }
}
