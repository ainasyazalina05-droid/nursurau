import 'package:flutter/material.dart';

class DonationPage extends StatelessWidget {
  const DonationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        buildDonationCard("Sejadah", "RM200", "01 Sept 2025"),
        buildDonationCard("Telekung", "RM150", "28 Aug 2025"),
        buildDonationCard("Kerusi Surau", "RM500", "25 Aug 2025"),
      ],
    );
  }

  Widget buildDonationCard(String item, String amount, String date) {
    return Card(
      color: const Color(0xFFF5EFD1),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.volunteer_activism, color: Colors.green),
        title: Text(item,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black87)),
        subtitle: Text("Disumbang pada $date"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              amount,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.green),
            ),
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () {
                // TODO: Edit donation
              },
            ),
          ],
        ),
      ),
    );
  }
}
