import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/services/follow_service.dart';
import 'package:timeago/timeago.dart' as timeago;

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
      final followedAjkIds = await FollowService.loadFollowed();
      if (followedAjkIds.isEmpty) return [];

      List<Map<String, dynamic>> allDonations = [];

      for (final ajkId in followedAjkIds) {
        final query = await FirebaseFirestore.instance
            .collection('suraus')
            .where('ajkId', isEqualTo: ajkId)
            .limit(1)
            .get();

        if (query.docs.isEmpty) continue;

        final surauDoc = query.docs.first;
        final surauName = surauDoc.data()['name'] ?? 'Surau';
        final surauDocId = surauDoc.id;

        final donationsSnapshot = await FirebaseFirestore.instance
            .collection('suraus')
            .doc(surauDocId)
            .collection('donations')
            .get();

        for (var doc in donationsSnapshot.docs) {
          final data = doc.data();
          data['surauId'] = surauDocId;
          data['surauName'] = surauName;
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
      debugPrint('❌ Error fetching donations: $e');
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

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _donationsFuture = _fetchFollowedDonations();
              });
              await _donationsFuture;
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final data = donations[index];
                final imageUrl = (data['imageUrl'] ?? '') as String;
                final title = (data['title'] ?? 'Tiada Tajuk') as String;
                final description = (data['description'] ?? '') as String;
                final surauName = (data['surauName'] ?? 'Surau Tidak Dikenal') as String;
                final timestamp = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                final timeAgo = timeago.format(timestamp);

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section
                      if (imageUrl.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullScreenImage(url: imageUrl),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              SizedBox(
                                height: 200,
                                width: double.infinity,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, progress) {
                                    if (progress == null) return child;
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    );
                                  },
                                ),
                              ),
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.35),
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 8,
                                left: 12,
                                child: Text(
                                  surauName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      shadows: [
                                        Shadow(
                                            offset: Offset(0, 1),
                                            blurRadius: 3,
                                            color: Colors.black54)
                                      ]),
                                ),
                              )
                            ],
                          ),
                        ),
                      // Text section
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              timeAgo,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              description,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black87),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () => _showDonationDetails(
                                      context, data, themeColor),
                                  icon: Icon(Icons.volunteer_activism,
                                      color: themeColor),
                                  label: const Text(
                                    "Lihat",
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.grey.shade200.withOpacity(0.8),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 8),
                                  ),
                                )
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDonationDetails(
      BuildContext context, Map<String, dynamic> data, Color themeColor) {
    final imageUrl = (data['imageUrl'] ?? '') as String;
    final qrUrl = (data['qrUrl'] ?? '') as String;
    final title = (data['title'] ?? 'Maklumat Sumbangan') as String;
    final description =
        (data['description'] ?? 'Tiada keterangan disediakan.') as String;
    final bankAccount = (data['bankAccount'] ?? '-') as String;
    final surauName = (data['surauName'] ?? 'Surau Tidak Dikenal') as String;

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
              Text(title,
                  style:
                      const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(surauName,
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 10),
              if (imageUrl.isNotEmpty)
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FullScreenImage(url: imageUrl)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Text(description,
                  style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('Akaun Bank: $bankAccount',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.black87)),
              ),
              const SizedBox(height: 16),
              if (qrUrl.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Imbas Kod QR untuk Menyumbang",
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FullScreenImage(url: qrUrl)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          qrUrl,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
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
