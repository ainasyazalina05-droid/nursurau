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
      final docRef = FirebaseFirestore.instance.collection('form').doc(widget.docId);
      final formSnap = await docRef.get();
      final ajkSnap = await docRef.collection('ajk').doc('ajk_data').get();

      if (!formSnap.exists) throw Exception("Data surau tidak dijumpai.");

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
        title: Text(newStatus == 'approved' ? 'Sahkan Kelulusan' : 'Sahkan Penolakan'),
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
              backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
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
              content: Text('Status telah dikemas kini kepada ${_translateStatus(newStatus)}'),
              backgroundColor: newStatus == 'approved' ? Colors.green : Colors.red,
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
        return Color(0xFF87AC4F);
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  // ✅ Fungsi ni letak SINI (bukan dalam build)
  String _translateStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return 'DILULUSKAN';
      case 'pending':
        return 'MENUNGGU';
      case 'rejected':
        return 'DITOLAK';
      default:
        return '-';
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
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF87AC4F)),
            ),
            const Divider(),
            ...info.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text("${e.key} : ${e.value}", style: const TextStyle(fontSize: 16)),
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
        appBar: AppBar(
          backgroundColor: Color(0xFF87AC4F),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Pengurusan Surau",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
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
        backgroundColor: Color(0xFF87AC4F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Pengurusan Surau",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard("Maklumat Surau", {
                "Nama Surau": surauData?['surauName'] ?? '-',
                "Alamat": surauData?['surauAddress'] ?? '-',
              }),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Status: ", style: TextStyle(fontSize: 16)),
                  Text(
                    _translateStatus(surauData?['status']),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _statusColor(surauData?['status']),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              if (ajkData != null)
                _buildInfoCard("Maklumat AJK", {
                  "Nama AJK": ajkData?['ajkName'] ?? '-',
                  "No. IC": ajkData?['ic'] ?? '-',
                  "No. Telefon": ajkData?['phone'] ?? '-',
                  "Emel": ajkData?['email'] ?? '-',
                  "Kata Laluan": ajkData?['password'] ?? '-',
                }),
              const SizedBox(height: 40),

              if ((surauData?['status'] ?? '') == "pending")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _confirmAndUpdateStatus("approved"),
                      icon: const Icon(Icons.check_circle_outline, size: 28),
                      label: const Text("Luluskan", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Color(0xFF87AC4F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _confirmAndUpdateStatus("rejected"),
                      icon: const Icon(Icons.cancel_outlined, size: 28),
                      label: const Text("Ditolak", style: TextStyle(fontSize: 18)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
