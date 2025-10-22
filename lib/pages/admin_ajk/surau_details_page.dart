import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailsPage extends StatefulWidget {
  final String ajkId;
  const SurauDetailsPage({super.key, required this.ajkId});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _nazirNameController = TextEditingController();
  final _nazirPhoneController = TextEditingController();

  String? _docId;
  bool _isLoading = true;

  Future<void> _fetchSurauDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('suraus')
          .where('ajkId', isEqualTo: widget.ajkId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _docId = doc.id;
        final data = doc.data();

        _nameController.text = data['name'] ?? '';
        _addressController.text = data['address'] ?? '';
        _nazirNameController.text = data['nazirName'] ?? '';
        _nazirPhoneController.text = data['nazirPhone'] ?? '';
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maklumat surau tidak dijumpai.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat memuat data: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateSurau() async {
    if (_docId == null) return;

    try {
      await FirebaseFirestore.instance.collection('suraus').doc(_docId).update({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'nazirName': _nazirNameController.text.trim(),
        'nazirPhone': _nazirPhoneController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maklumat surau berjaya dikemas kini.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat mengemas kini: $e")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSurauDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maklumat Surau", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.mosque, size: 80, color: Color.fromARGB(255, 135, 172, 79)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Nama Surau",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "Alamat",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nazirNameController,
                    decoration: const InputDecoration(
                      labelText: "Nama Nazir",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _nazirPhoneController,
                    decoration: const InputDecoration(
                      labelText: "No. Telefon Nazir",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 135, 172, 79),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: _updateSurau,
                    icon: const Icon(Icons.save, color: Colors.white),
                    label: const Text(
                      "Kemas Kini Maklumat",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
