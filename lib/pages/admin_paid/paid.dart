import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';
import 'approved_suraus_page.dart';

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
      Query query = firestore.collection('form'); // ubah nama koleksi jika perlu

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
        return const Color(0xFF87AC4F);
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
        actions: widget.filter == 'Approved'
            ? [
                IconButton(
                  icon: const Icon(Icons.visibility, color: Colors.white),
                  tooltip: "Senarai Surau Diluluskan",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ApprovedSurausPage(),
                      ),
                    );
                  },
                ),
              ]
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : surauList.isEmpty
              ? const Center(child: Text("Tiada data surau dijumpai."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: surauList.length,
                  itemBuilder: (context, index) {
                    final surau =
                        surauList[index].data() as Map<String, dynamic>;
                    final docId = surauList[index].id;

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      color: Colors.white,
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
                            Text(surau['surauAddress'] ?? '-'),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  surau['status']?.toUpperCase() ?? '-',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _statusColor(surau['status']),
                                  ),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF87AC4F),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ManageSurauPage(docId: docId),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.settings),
                                  label: const Text(
                                    "Urus Surau",
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
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
