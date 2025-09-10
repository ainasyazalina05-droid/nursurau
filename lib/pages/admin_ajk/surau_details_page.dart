import 'package:flutter/material.dart';

class SurauDetailsPage extends StatefulWidget {
  const SurauDetailsPage({super.key});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  // Simpan senarai details
  final List<Map<String, String>> _details = [
    {"title": "Nama Surau", "value": "Surau Al-Falah"},
    {"title": "Lokasi", "value": "Taman Seri Murni, Selangor"},
    {"title": "Pengerusi", "value": "En. Ahmad Bin Ali"},
    {"title": "Bendahari", "value": "Pn. Siti Binti Abu"},
  ];

  // Function untuk tambah details baru
  void _addDetail() {
    final titleController = TextEditingController();
    final valueController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Butiran Baru"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Tajuk"),
              ),
              TextField(
                controller: valueController,
                decoration: const InputDecoration(labelText: "Butiran"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("Simpan"),
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    valueController.text.isNotEmpty) {
                  setState(() {
                    _details.add({
                      "title": titleController.text,
                      "value": valueController.text,
                    });
                  });
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: _details
            .map((detail) =>
                buildDetailCard(detail["title"]!, detail["value"]!))
            .toList(),
      ),

      // 👉 Button paling bawah
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: _addDetail,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text(
            "Tambah Butiran Baru",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget buildDetailCard(String title, String value) {
    return Card(
      color: const Color(0xFFF5EFD1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.info, color: Colors.green),
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
          },
        ),
      ),
    );
  }
}
