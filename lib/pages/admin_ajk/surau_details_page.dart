import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailsPage extends StatelessWidget {
  final String ajkId; // unique AJK ID

  const SurauDetailsPage({super.key, required this.ajkId});

  @override
  Widget build(BuildContext context) {
    final surauQuery = FirebaseFirestore.instance
        .collection('suraus')
        .where('ajkId', isEqualTo: ajkId)
        .limit(1)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      appBar: AppBar(
        title: const Text('Butiran Surau'),
        backgroundColor: Colors.green,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.edit),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurauFormPage(ajkId: ajkId),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: surauQuery,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Maklumat surau belum dimasukkan.'));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          // ✅ safer date parsing
          final tarikhStr = data['tarikhKemaskini'];
          String tarikhKemaskini;
          if (tarikhStr != null && tarikhStr.toString().isNotEmpty) {
            final dt = DateTime.tryParse(tarikhStr);
            tarikhKemaskini = dt != null ? "${dt.day}-${dt.month}-${dt.year}" : "-";
          } else {
            tarikhKemaskini = "-";
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['imageUrl'] != null && data['imageUrl'] != '')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(data['imageUrl'], height: 200, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 12),
                Text(
                  data['namaSurau'] ?? '-',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text("Lokasi: ${data['lokasi'] ?? '-'}"),
                Text("Kapasiti: ${data['kapasiti'] ?? '-'}"),
                const SizedBox(height: 10),
                Text("Tarikh Kemaskini: $tarikhKemaskini",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ---------------- Surau Form Page ----------------

class SurauFormPage extends StatefulWidget {
  final String ajkId;

  const SurauFormPage({super.key, required this.ajkId});

  @override
  State<SurauFormPage> createState() => _SurauFormPageState();
}

class _SurauFormPageState extends State<SurauFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _kapasitiController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final CollectionReference surauCollection =
      FirebaseFirestore.instance.collection('suraus');

  @override
  void initState() {
    super.initState();
    // Load existing data if exists
    surauCollection.where('ajkId', isEqualTo: widget.ajkId).limit(1).get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        _namaController.text = data['namaSurau'] ?? '';
        _lokasiController.text = data['lokasi'] ?? '';
        _kapasitiController.text = (data['kapasiti'] ?? '').toString();
        _imageController.text = data['imageUrl'] ?? '';
      }
    });
  }

  void _saveSurau() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'ajkId': widget.ajkId,
        'namaSurau': _namaController.text.trim(),
        'lokasi': _lokasiController.text.trim(),
        'kapasiti': int.tryParse(_kapasitiController.text.trim()) ?? 0,
        'imageUrl': _imageController.text.trim(),
        'tarikhKemaskini': DateTime.now().toIso8601String(),
      };

      final query = await surauCollection.where('ajkId', isEqualTo: widget.ajkId).limit(1).get();

      if (query.docs.isEmpty) {
        await surauCollection.add(data);
      } else {
        await surauCollection.doc(query.docs.first.id).set(data, SetOptions(merge: true));
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Maklumat surau berjaya disimpan."),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah / Kemaskini Surau'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Surau'),
                validator: (value) => value!.isEmpty ? 'Sila isi nama surau' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) => value!.isEmpty ? 'Sila isi lokasi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _kapasitiController,
                decoration: const InputDecoration(labelText: 'Kapasiti'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Sila isi kapasiti' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _saveSurau,
                child: const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
