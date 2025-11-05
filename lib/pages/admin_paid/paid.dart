import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';
import 'view_surau_page.dart';

class AdminPaidPage extends StatefulWidget {
  final String filter;
  const AdminPaidPage({super.key, required this.filter});

  @override
  State<AdminPaidPage> createState() => _AdminPaidPageState();
}

class _AdminPaidPageState extends State<AdminPaidPage> {
  bool isLoading = true;
  List<QueryDocumentSnapshot> surauList = [];

  @override
  void initState() {
    super.initState();
    _fetchSuraus();
  }

  Future<void> _fetchSuraus() async {
    try {
      final firestore = FirebaseFirestore.instance;
      Query query = firestore.collection('form');

      if (widget.filter == 'Approved') {
        query = query.where('status', isEqualTo: 'approved');
      } else if (widget.filter == 'Pending') {
        query = query.where('status', isEqualTo: 'pending');
      }

      final snapshot = await query.get();
      setState(() {
        surauList = snapshot.docs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Gagal memuatkan senarai surau : $e");
      setState(() => isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87AC4F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.filter == 'Approved'
              ? "Senarai Surau Diluluskan"
              : widget.filter == 'Pending'
                  ? "Senarai Surau Menunggu"
                  : "Keseluruhan Surau",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF87AC4F)),
            )
          : surauList.isEmpty
              ? const Center(child: Text("Tiada data surau dijumpai."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: surauList.length,
                  itemBuilder: (context, index) {
                    final doc = surauList[index];
                    final surau = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    final status =
                        (surau['status'] ?? 'pending').toString().toLowerCase();
                    final isApproved = status == 'approved';

                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surau['surauName'] ?? 'Nama tidak tersedia',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF87AC4F),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              surau['surauAddress'] ?? '-',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 10),

                            if (widget.filter == 'All')
                              Text(
                                status == 'approved'
                                    ? "Diluluskan"
                                    : status == 'pending'
                                        ? "Menunggu"
                                        : status,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _statusColor(status),
                                ),
                              ),
                            const SizedBox(height: 12),

                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isApproved
                                      ? const Color(0xFF4E6C1E)
                                      : Colors.orange.shade800,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                icon: Icon(isApproved
                                    ? Icons.visibility
                                    : Icons.settings),
                                label: Text(
                                  isApproved
                                      ? "Lihat Surau"
                                      : "Urus Surau",
                                  style: const TextStyle(fontSize: 14),
                                ),
                                onPressed: () {
                                  if (isApproved) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ViewSurauPage(docId: docId),
                                      ),
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ManageSurauPage(docId: docId),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
