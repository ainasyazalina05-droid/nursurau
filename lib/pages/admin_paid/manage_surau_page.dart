import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageSurauPage extends StatefulWidget {
  final String docId;
  const ManageSurauPage({super.key, required this.docId});

  @override
  State<ManageSurauPage> createState() => _ManageSurauPageState();
}

class _ManageSurauPageState extends State<ManageSurauPage> {
  Map<String, dynamic>? surauData;
  Map<String, dynamic>? ajkData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchFormData();
  }

  Future<void> _fetchFormData() async {
    try {
      final docRef =
          FirebaseFirestore.instance.collection('form').doc(widget.docId);

      final formSnap = await docRef.get();
      final ajkSnap = await docRef.collection('ajk').doc('ajk_data').get();

      if (!formSnap.exists) {
        throw Exception("Data surau tidak dijumpai.");
      }

      setState(() {
        surauData = formSnap.data();
        ajkData = ajkSnap.data();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _confirmAndUpdateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              newStatus == 'approved'
                  ? Icons.check_circle
                  : Icons.cancel_outlined,
              color:
                  newStatus == 'approved' ? Colors.green[700] : Colors.red[700],
            ),
            const SizedBox(width: 10),
            Text(
              newStatus == 'approved'
                  ? 'Sahkan Kelulusan'
                  : 'Sahkan Penolakan',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Adakah anda pasti mahu ${newStatus == 'approved' ? 'meluluskan' : 'menolak'} surau ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  newStatus == 'approved' ? Colors.green[700] : Colors.red[700],
              minimumSize: const Size(100, 45),
            ),
            child: const Text('Ya', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('form')
            .doc(widget.docId)
            .update({'status': newStatus});

        if (mounted) {
          setState(() {
            surauData?['status'] = newStatus;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status dikemas kini kepada $newStatus'),
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
      default:
        return Colors.orange;
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
            ...info.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text("${e.key} : ${e.value}",
                      style: const TextStyle(fontSize: 16)),
                ))
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
          title: const Text("Manage Surau"),
          backgroundColor: Colors.green[700],
        ),
        body: Center(
          child: Text(
            "Ralat: $errorMessage",
            style: const TextStyle(color: Colors.red),
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
        title: const Text("Manage Surau"),
        backgroundColor: Colors.green[700],
      ),
      backgroundColor: const Color(0xFFF2F7F3),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard("Maklumat Surau", {
              "Nama Surau": surauData?['surauName'] ?? '-',
              "Alamat": surauData?['surauAddress'] ?? '-',
            }),
            if (ajkData != null)
              _buildInfoCard("Maklumat AJK", {
                "Nama AJK": ajkData?['ajkName'] ?? '-',
                "Email": ajkData?['email'] ?? '-',
                "No. IC": ajkData?['ic'] ?? '-',
                "No. Telefon": ajkData?['phone'] ?? '-',
                "Kata Laluan": ajkData?['password'] ?? '-',
              }),
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Text(
                    "Status: ${surauData?['status']?.toUpperCase() ?? '-'}",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(surauData?['status']),
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ✅ Butang Approve & Reject (Besar & kemas)
                  if ((surauData?['status'] ?? '') == 'pending')
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () =>
                              _confirmAndUpdateStatus("approved"),
                          icon: const Icon(Icons.check_circle_outline, size: 26),
                          label: const Text(
                            "Approve",
                            style: TextStyle(fontSize: 17),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _confirmAndUpdateStatus("rejected"),
                          icon: const Icon(Icons.cancel_outlined, size: 26),
                          label: const Text(
                            "Reject",
                            style: TextStyle(fontSize: 17),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[600],
                            foregroundColor: Colors.white,
                            minimumSize: const Size(150, 55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
  }
}
