import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🕌 Halaman utama — senarai semua surau
class ManageSurauPage extends StatelessWidget {
  const ManageSurauPage({super.key});

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Surau"),
        backgroundColor: Colors.green[700],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('suraus').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Ralat: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada surau dijumpai"));
          }

          final surauList = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: surauList.length,
            itemBuilder: (context, index) {
              final data = surauList[index].data() as Map<String, dynamic>;
              final docId = surauList[index].id;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
                child: ListTile(
                  title: Text(
                    data['surauName'] ?? 'Tanpa Nama',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Alamat: ${data['surauAddress'] ?? '-'}"),
                      const SizedBox(height: 4),
                      Text(
                        "Status: ${data['status'] ?? '-'}",
                        style: TextStyle(
                          color: _statusColor(data['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.white, // ← make the arrow white
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            SurauDetailPage(docId: docId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// 🧾 Halaman detail — info surau + fungsi approve / reject
class SurauDetailPage extends StatefulWidget {
  final String docId;
  const SurauDetailPage({super.key, required this.docId});

  @override
  State<SurauDetailPage> createState() => _SurauDetailPageState();
}

class _SurauDetailPageState extends State<SurauDetailPage> {
  Map<String, dynamic>? surauData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchSurauData();
  }

  /// 🔹 Ambil data surau berdasarkan docId
  Future<void> _fetchSurauData() async {
    try {
      final docSnap = await FirebaseFirestore.instance
          .collection('suraus')
          .doc(widget.docId)
          .get();

      if (!docSnap.exists) {
        throw Exception("Data surau tidak dijumpai.");
      }

      setState(() {
        surauData = docSnap.data();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  /// 🔹 Kemaskini status (approved / rejected)
  Future<void> _confirmAndUpdateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(newStatus == 'approved'
            ? 'Sahkan Kelulusan'
            : 'Sahkan Penolakan'),
        content: Text(
          'Adakah anda pasti untuk ${newStatus == 'approved' ? 'meluluskan' : 'menolak'} surau ini?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'approved' ? Colors.green : Colors.red,
            ),
            child: const Text('Ya', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('suraus')
            .doc(widget.docId)
            .update({'status': newStatus});

        if (mounted) {
          setState(() {
            surauData?['status'] = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status telah dikemas kini kepada $newStatus'),
              backgroundColor:
                  newStatus == 'approved' ? Colors.green : Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ralat: $e')),
        );
      }
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildInfoCard(String title, Map<String, String> info) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green)),
            const Divider(),
            ...info.entries.map((e) {
              final isStatus = e.key.toLowerCase() == 'status';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  "${e.key} : ${e.value}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isStatus ? FontWeight.bold : FontWeight.normal,
                    color: isStatus
                        ? _statusColor(e.value.toLowerCase())
                        : Colors.black,
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Detail Surau"),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Text(
            "Ralat: $errorMessage",
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (surauData == null) {
      return const Scaffold(
        body: Center(child: Text("Tiada data dijumpai")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Surau"),
        backgroundColor: Colors.green[700],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildInfoCard("Maklumat Surau", {
                "Nama Surau": surauData?['surauName'] ?? '-',
                "Alamat": surauData?['surauAddress'] ?? '-',
                "Status": surauData?['status']?.toUpperCase() ?? '-',
              }),
              const SizedBox(height: 30),
              if (surauData?['status'] == "pending")
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmAndUpdateStatus("approved"),
                        label: const Text(
                          "Approve",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: () => _confirmAndUpdateStatus("rejected"),
                        label: const Text(
                          "Reject",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
