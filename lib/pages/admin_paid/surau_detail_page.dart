import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';
import 'view_surau_page.dart';

class SurauDetailPage extends StatefulWidget {
  final String ajkId;
  const SurauDetailPage({super.key, required this.ajkId});

  @override
  State<SurauDetailPage> createState() => _SurauDetailPageState();
}

class _SurauDetailPageState extends State<SurauDetailPage> {
  Map<String, dynamic>? ajkData;

  @override
  void initState() {
    super.initState();
    _fetchAjkData();
  }

  Future<void> _fetchAjkData() async {
    try {
      final surauDoc = await FirebaseFirestore.instance
          .collection('suraus')
          .doc(widget.ajkId)
          .get();

      final surauData = surauDoc.data();
      if (surauData != null && surauData['ajkId'] != null) {
        final ajkDoc = await FirebaseFirestore.instance
            .collection('ajk_users')
            .doc(surauData['ajkId'])
            .get();

        if (ajkDoc.exists) {
          setState(() {
            ajkData = ajkDoc.data();
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching AJK data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Maklumat Surau',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF87AC4F),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('suraus')
            .doc(widget.ajkId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Maklumat surau tidak dijumpai.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Tiada nama surau';
          final address = data['address'] ?? 'Tiada alamat';
          final imageUrl = data['imageUrl'] ?? '';
          final approved = data['approved'] ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ Gambar Surau
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => _placeholderImage(),
                        )
                      : _placeholderImage(),
                ),
                const SizedBox(height: 20),

                // ✅ Nama Surau
                Text(name,
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // ✅ Alamat
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on, color: Colors.green),
                    const SizedBox(width: 5),
                    Expanded(
                      child:
                          Text(address, style: const TextStyle(fontSize: 16)),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 10),

                // ✅ Maklumat Nazir (from ajk_users)
                const Text(
                  'Maklumat Nazir',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Nama Nazir: ${ajkData?['username'] ?? 'Tiada'}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                Text('No. IC: ${ajkData?['no_ic'] ?? 'Tiada'}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                Text('Emel: ${ajkData?['email'] ?? 'Tiada'}',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 5),
                Text('No. Telefon: ${ajkData?['phone'] ?? 'Tiada'}',
                    style: const TextStyle(fontSize: 16)),

                const SizedBox(height: 40),

                // ✅ Button
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: approved ? Colors.green : Colors.orange,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: Icon(approved ? Icons.visibility : Icons.settings),
                    label: Text(
                      approved ? 'View Surau' : 'Manage Surau',
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    onPressed: () {
                      if (approved) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ViewSurauPage(docId: widget.ajkId),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ManageSurauPage(docId: widget.ajkId),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: double.infinity,
      height: 200,
      color: Colors.grey[300],
      child: const Icon(Icons.image, size: 80, color: Colors.grey),
    );
  }
}
