import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'follow_service.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  late Future<List<Map<String, dynamic>>> _donationsFuture;

  @override
  void initState() {
    super.initState();
    _donationsFuture = _fetchFollowedDonations();
  }

  Future<List<Map<String, dynamic>>> _fetchFollowedDonations() async {
    try {
      final followedIds = await FollowService.loadFollowed();
      if (followedIds.isEmpty) return [];

      List<Map<String, dynamic>> allDonations = [];

      for (final surauId in followedIds) {
        final snapshot = await FirebaseFirestore.instance
            .collection('suraus')
            .doc(surauId)
            .collection('donations')
            .get();

        for (var doc in snapshot.docs) {
          final data = doc.data();
          data['surauId'] = surauId;
          data['docId'] = doc.id;
          allDonations.add(data);
        }
      }

      allDonations.sort((a, b) {
        final t1 = (a['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        final t2 = (b['timestamp'] as Timestamp?)?.toDate() ?? DateTime(2000);
        return t2.compareTo(t1);
      });

      return allDonations;
    } catch (e) {
      debugPrint('Error fetching donations: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF87AC4F);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sumbangan'),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _donationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final donations = snapshot.data ?? [];

          if (donations.isEmpty) {
            return const Center(
              child: Text(
                'Tiada sumbangan dari surau yang anda ikuti.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final data = donations[index];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _showDonationDetails(context, data, themeColor),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImage(url: data['imageUrl']),
                              ),
                            );
                          },
                          child: Image.network(
                            data['imageUrl'],
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? 'Tiada Tajuk',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              data['description'] ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: themeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.volunteer_activism, color: themeColor, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Lihat",
                                        style: TextStyle(
                                          color: themeColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
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
            },
          );
        },
      ),
    );
  }

  void _showDonationDetails(BuildContext context, Map<String, dynamic> data, Color themeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                data['title'] ?? 'Maklumat Sumbangan',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (data['imageUrl'] != null && data['imageUrl'].isNotEmpty)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenImage(url: data['imageUrl']),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      data['imageUrl'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Text(
                data['description'] ?? 'Tiada keterangan disediakan.',
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Akaun Bank: ${data['bankAccount'] ?? '-'}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
              if (data['qrUrl'] != null && data['qrUrl'].isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Imbas Kod QR untuk Menyumbang",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImage(url: data['qrUrl']),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          data['qrUrl'],
                          width: 220,
                          height: 220,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String url;
  const FullScreenImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(
            url,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
