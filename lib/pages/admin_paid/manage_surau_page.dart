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

      if (!formSnap.exists) throw Exception("Data surau tidak dijumpai.");

      setState(() {
        surauData = formSnap.data();
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
        title: Text(newStatus == 'approved'
            ? 'Sahkan Kelulusan'
            : 'Sahkan Penolakan'),
        content: Text(
          'Adakah anda pasti untuk ${newStatus == 'approved' ? 'meluluskan' : 'menolak'} surau ini?',
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
        return const Color(0xFF87AC4F);
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF87AC4F),
              ),
            ),
            const Divider(),
            ...info.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text("${e.key} : ${e.value}"),
              ),
            ),
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
        appBar: AppBar(title: const Text("Pengurusan Surau")),
        body: Center(
          child: Text("Ralat: $errorMessage",
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }

    final data = surauData ?? {};

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        title: const Text("Pengurusan Surau",
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard("Maklumat Surau", {
              "Nama Surau": data['surauName'] ?? '-',
              "Alamat": data['surauAddress'] ?? '-',
            }),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Status: ", style: TextStyle(fontSize: 16)),
                Text(
                  (data['status'] ?? '-').toString().toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _statusColor(data['status']),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            if ((data['status'] ?? '') == 'pending')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _confirmAndUpdateStatus("approved"),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text("Luluskan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87AC4F),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _confirmAndUpdateStatus("rejected"),
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text("Tolak"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
