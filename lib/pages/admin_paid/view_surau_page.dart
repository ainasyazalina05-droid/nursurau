import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSurauPage extends StatefulWidget {
  final String docId;
  const ViewSurauPage({super.key, required this.docId});

  @override
  State<ViewSurauPage> createState() => _ViewSurauPageState();
}

class _ViewSurauPageState extends State<ViewSurauPage> {
  Map<String, dynamic>? surauData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurau();
  }

  Future<void> _loadSurau() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('suraus')
          .doc(widget.docId)
          .get();

      if (doc.exists) {
        setState(() {
          surauData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Ralat paparan surau: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (surauData == null) {
      return const Scaffold(
        body: Center(child: Text("Maklumat surau tidak dijumpai.")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(surauData!['name'] ?? "Maklumat Surau"),
        backgroundColor: const Color(0xFF87AC4F),
      ),
      backgroundColor: const Color(0xFFF6F9F2),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (surauData!['imageUrl'] != null &&
                (surauData!['imageUrl'] as String).isNotEmpty)
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
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Maklumat Nazir",
                    style: TextStyle(
                      color: Color(0xFF87AC4F),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "Nama Nazir : ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        surauData!['nazirName'] ?? '-',
                        style: const TextStyle(color: Color(0xFF87AC4F)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        "Nombor Telefon : ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        surauData!['nazirPhone'] ?? '-',
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
