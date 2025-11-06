import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'surau_detail_page.dart';

class ViewSurauPage extends StatefulWidget {
  const ViewSurauPage({super.key});

  @override
  State<ViewSurauPage> createState() => _ViewSurauPageState();
}

class _ViewSurauPageState extends State<ViewSurauPage> {
  String selectedFilter = 'Approved';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lihat Surau'),
        backgroundColor: const Color(0xFF87AC4F),
        foregroundColor: Colors.white,
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔥 FILTER BUTTONS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _filterButton('Approved'),
              _filterButton('Pending'),
              _filterButton('Semua'),
            ],
          ),

          const SizedBox(height: 10),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tiada surau ditemui.'));
                }

                final surauList = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: surauList.length,
                  itemBuilder: (context, index) {
                    final surau = surauList[index];
                    final data = surau.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.mosque, color: Color(0xFF87AC4F)),
                        title: Text(data['name'] ?? 'Tiada nama'),
                        subtitle: Text(data['address'] ?? 'Tiada alamat'),

                        // 🔥 BUTTON TEKAN UNTUK LIHAT DETAILS SURAU
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SurauDetailPage(surauId: surau.id),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 FILTER STREAM
  Stream<QuerySnapshot> _getFilteredStream() {
    final collection = FirebaseFirestore.instance.collection('suraus');

    if (selectedFilter == 'Approved') {
      return collection.where('approved', isEqualTo: true).snapshots();
    } else if (selectedFilter == 'Pending') {
      return collection.where('approved', isEqualTo: false).snapshots();
    } else {
      return collection.snapshots(); // Semua
    }
  }

  // 🔥 FILTER BUTTON UI
  Widget _filterButton(String label) {
    final bool active = selectedFilter == label;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF87AC4F) : Colors.grey[300],
        foregroundColor: active ? Colors.white : Colors.black,
      ),
      onPressed: () {
        setState(() => selectedFilter = label);
      },
      child: Text(label),
    );
  }
}
