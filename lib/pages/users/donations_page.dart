import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/services/follow_service.dart';
import 'package:intl/intl.dart';
import 'home_page.dart';
import 'notifications_page.dart';
import 'help_page.dart';

class DonationsPage extends StatefulWidget {
  const DonationsPage({super.key});

  @override
  State<DonationsPage> createState() => _DonationsPageState();
}

class _DonationsPageState extends State<DonationsPage> {
  late Future<List<Map<String, dynamic>>> _donationsFuture;
  int _currentIndex = 2;
  final Color themeColor = const Color(0xFF87AC4F);

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

  void _onNavTap(int index) {
    if (index == _currentIndex) return;

    Widget nextPage;
    switch (index) {
      case 0:
        nextPage = const NotificationsPage();
        break;
      case 1:
        nextPage = const HomePage();
        break;
      case 2:
        nextPage = const DonationsPage();
        break;
      case 3:
        nextPage = const HelpPage();
        break;
      default:
        nextPage = const HomePage();
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],

      // ✅ Uniform AppBar style
      appBar: AppBar(
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleTextStyle: const TextStyle(),
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Sumbangan',
            style: TextStyle(
              fontWeight: FontWeight.w500, // ✅ Medium weight (not bold)
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Tiada sumbangan dari surau yang anda ikuti.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
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
              padding: const EdgeInsets.all(16),
              itemCount: donations.length,
              itemBuilder: (context, index) {
                final data = donations[index];
                final imageUrl = (data['imageUrl'] ?? '') as String;
                final title = (data['title'] ?? 'Tiada Tajuk') as String;
                final description = (data['description'] ?? '') as String;
                final surauName =
                    (data['surauName'] ?? 'Surau Tidak Dikenal') as String;
                final timestamp =
                    (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
                final formattedDate =
                    DateFormat('dd MMM yyyy, hh:mm a').format(timestamp);

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _showDonationDetails(context, data, themeColor),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18)),
                              child: Stack(
                                children: [
                                  Image.network(
                                    imageUrl,
                                    height: 200,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        height: 200,
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    left: 10,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        surauName,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedDate,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                description,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ElevatedButton.icon(
                                  onPressed: () => _showDonationDetails(
                                      context, data, themeColor),
                                  icon: const Icon(Icons.volunteer_activism,
                                      size: 18),
                                  label: const Text(
                                    "Lihat",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themeColor.withOpacity(0.15),
                                    foregroundColor: themeColor,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 8),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: themeColor,
        unselectedItemColor: Colors.grey.shade700,
        type: BottomNavigationBarType.fixed,
        onTap: _onNavTap,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: "Notifikasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: "Utama",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: "Donasi",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: "Bantuan",
          ),
        ],
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
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                surauName,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
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
                  color: themeColor.withOpacity(0.15),
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
              Center(
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
          child: Image.network(url, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
