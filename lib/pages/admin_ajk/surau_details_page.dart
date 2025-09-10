import 'package:flutter/material.dart';

class SurauDetailsPage extends StatelessWidget {
  const SurauDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildDetailCard("Nama Surau", "Surau Al-Falah"),
        buildDetailCard("Lokasi", "Taman Seri Murni, Selangor"),
        buildDetailCard("Pengerusi", "En. Ahmad Bin Ali"),
        buildDetailCard("Bendahari", "Pn. Siti Binti Abu"),
      ],
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
            // TODO: Edit surau details
          },
        ),
      ),
    );
  }
}
