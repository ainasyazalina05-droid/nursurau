import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notifications_page.dart';
import 'home_page.dart';
import 'help_page.dart';

class DonationsPage extends StatelessWidget {
  const DonationsPage({super.key});

  DateTime? _toDate(dynamic value) {
    if (value == null) return null;
    // Firestore Timestamp
    if (value is Timestamp) return value.toDate();
    // Already a DateTime
    if (value is DateTime) return value;
    // Numeric millis or seconds
    if (value is int) {
      // heuristics: if value looks like seconds (10 digits) convert to seconds *1000
      if (value < 1000000000000) {
        return DateTime.fromMillisecondsSinceEpoch(value * 1000);
      } else {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    }
    // ISO string
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  String _formatDatePretty(DateTime? dt) {
    if (dt == null) return "-";
    return "${dt.day}-${dt.month}-${dt.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sumbangan Terbuka"),
        backgroundColor: const Color(0xFF2F5D50),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('donations')
            .orderBy('createdAt', descending: true) // newest first
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Ralat: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada sumbangan terbuka."));
          }

          final donations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: donations.length,
            itemBuilder: (context, index) {
              final doc = donations[index];
              // data() may return Object? so we guard cast safely
              final rawData = doc.data();
              final data = (rawData is Map) ? Map<String, dynamic>.from(rawData) : <String, dynamic>{};

              final endDateDt = _toDate(data['endDate']);
              final createdAtDt = _toDate(data['createdAt']);

              return Card(
                color: const Color(0xFFF5EFD1),
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['title'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),

                      if (data['amount'] != null)
                        Text('Jumlah Sasaran: RM ${data['amount']}'),

                      if (data['description'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('Keterangan: ${data['description']}'),
                        ),

                      if (data['account'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('Bank / Akaun: ${data['account']}'),
                        ),

                      if (data['contact'] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text('No Telefon AJK: ${data['contact']}'),
                        ),

                      const SizedBox(height: 12),

                      if (data['qrUrl'] != null && (data['qrUrl'] as String).isNotEmpty)
                        Center(
                          child: Image.network(
                            data['qrUrl'],
                            height: 120,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const SizedBox(
                              height: 120,
                              child: Center(child: Text('Gagal muat QR')),
                            ),
                          ),
                        ),

                      const SizedBox(height: 4),

                      // End date safe printing
                      Text('Tamat: ${_formatDatePretty(endDateDt)}'),

                      const SizedBox(height: 6),

                      // CreatedAt: if stored as Timestamp or string, handle both
                      if (createdAtDt != null)
                        Text(
                          'Tarikh Cipta: ${_formatDatePretty(createdAtDt)}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else if (data['createdAt'] != null)
                        // fallback: show raw value if we can't parse
                        Text(
                          'Tarikh Cipta: ${data['createdAt'].toString()}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // 📌 Bottom Navigation (same as HomePage)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E2B8),
        currentIndex: 2, // ✅ highlight "Donasi" here
        selectedItemColor: const Color(0xFF2F5D50),
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()));
          } else if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HomePage()));
          } else if (index == 2) {
            // Already in Donations
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Utama"),
          BottomNavigationBarItem(icon: Icon(Icons.attach_money), label: "Donasi"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Bantuan"),
        ],
      ),
    );
  }
}
