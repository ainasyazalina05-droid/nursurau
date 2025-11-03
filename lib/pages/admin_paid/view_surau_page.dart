import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewSurauPage extends StatelessWidget {
  final String docId;
  const ViewSurauPage({super.key, required this.docId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Maklumat Surau",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF87AC4F),
        iconTheme: const IconThemeData(color: Colors.white), // ⬅️ back arrow white
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('suraus')
            .doc(docId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                "Maklumat surau tidak dijumpai.",
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

          final String name = data['name'] ?? 'Nama tidak tersedia';
          final String address = data['address'] ?? '-';
          final String? imageUrl = data['imageUrl'];
          final bool approved = data['approved'] ?? false;
          final String nazirName = data['nazirName'] ?? 'Tidak dinyatakan';
          final String nazirPhone = data['nazirPhone'] ?? 'Tidak dinyatakan';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ Gambar Surau
                if (imageUrl != null && imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.image_not_supported,
                        size: 80, color: Colors.grey),
                  ),

                const SizedBox(height: 20),

                // 📍 Nama Surau
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF87AC4F),
                  ),
                ),
                const SizedBox(height: 10),

                // 📫 Alamat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        address,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),

                // 🧍‍♂️ Nama Nazir
                ListTile(
                  leading: const Icon(Icons.person, color: Color(0xFF87AC4F)),
                  title: const Text("Nama Nazir"),
                  subtitle: Text(
                    nazirName,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // ☎️ No Telefon Nazir
                ListTile(
                  leading: const Icon(Icons.phone, color: Color(0xFF87AC4F)),
                  title: const Text("No. Telefon Nazir"),
                  subtitle: Text(
                    nazirPhone,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),

                // 📋 Status
                ListTile(
                  leading: const Icon(Icons.verified, color: Color(0xFF87AC4F)),
                  title: const Text("Status"),
                  subtitle: Text(
                    approved ? "Maklumat Telah Dimasukkan " : "Maklumat Belum Dimasukkan",
                    style: TextStyle(
                      color: approved ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // 🕒 Tarikh Dicipta
                if (data['createdAt'] != null)
                  ListTile(
                    leading: const Icon(Icons.calendar_today,
                        color: Color(0xFF87AC4F)),
                    title: const Text("Tarikh Dicipta"),
                    subtitle: Text(
                      data['createdAt'].toDate().toString(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
