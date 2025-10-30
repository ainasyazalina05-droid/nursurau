import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'manage_surau_page.dart';

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
      debugPrint("Error fetching surau list: $e");
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
        backgroundColor: Colors.green[700],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // putih confirm
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "${widget.filter} Suraus",
          style: const TextStyle(
            color: Colors.white, // title putih
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : surauList.isEmpty
              ? const Center(
                  child: Text("Tiada data surau dijumpai."),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: surauList.length,
                  itemBuilder: (context, index) {
                    final surau = surauList[index].data() as Map<String, dynamic>;
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
                                color: Colors.green,
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
                                    backgroundColor: Colors.green[700],
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
                                    "Manage",
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
