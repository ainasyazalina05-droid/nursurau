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
<<<<<<< HEAD
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
=======
  Stream<QuerySnapshot> _getStreamForFilter() {
    final firestore = FirebaseFirestore.instance;
    if (widget.filter == 'Pending') {
      return firestore.collection('form').where('status', isEqualTo: 'pending').snapshots();
    } else if (widget.filter == 'Approved') {
      return firestore.collection('suraus').snapshots();
    } else {
      return firestore.collection('form').snapshots();
>>>>>>> 0e4038fc063700425527a7fdeee896dfe69815a9
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
<<<<<<< HEAD
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
=======
          isPendingPage
              ? 'SENARAI SURAU MENUNGGU'
              : isApprovedPage
                  ? 'SENARAI SURAU DILULUSKAN'
                  : 'KESELURUHAN SURAU',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getStreamForFilter(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF87AC4F)));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Tiada data surau dijumpai."));
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = (doc.data() as Map<String, dynamic>?) ?? {};
              final docId = doc.id;

              if (isApprovedPage) {
                final name = data['name'] ?? '-';
                final address = data['address'] ?? '-';
                final imageUrl = (data['imageUrl'] ?? '').toString();

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: imageUrl.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(imageUrl,
                                width: 56, height: 56, fit: BoxFit.cover),
                          )
                        : const Icon(Icons.mosque,
                            color: Color(0xFF87AC4F), size: 40),
                    title: Text(
                      name,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4E6C1E)),
                    ),
                    subtitle: Text(address),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4E6C1E),
                        foregroundColor: Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SurauDetailPage(surauId: docId)),
                        );
                      },
                      child: const Text("Lihat Surau"),
                    ),
                  ),
                );
              } else {
                final surauName = data['surauName'] ?? data['name'] ?? '-';
                final surauAddress = data['surauAddress'] ?? data['address'] ?? '-';
                final status = (data['status'] ?? '').toString().toLowerCase();
                final isApproved = status == 'approved';
                final showStatus = isAllPage;

                return Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          surauName,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF87AC4F)),
                        ),
                        const SizedBox(height: 6),
                        Text(surauAddress, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 10),
                        if (showStatus)
  Text(
    isApproved
        ? "Diluluskan"
        : status == 'rejected'
            ? "Ditolak"
            : "Menunggu",
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
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: Icon(isApproved ? Icons.visibility : Icons.settings),
                            label: Text(isApproved ? "Lihat Surau" : "Urus Surau"),
                            onPressed: () {
                              if (isApproved) {
                                final surauId =
                                    data['surauId'] ?? data['surausId'] ?? data['surau_id'];
                                if (surauId != null && surauId.toString().isNotEmpty) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            SurauDetailPage(surauId: surauId.toString())),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            '.')),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            ManageSurauPage(docId: docId)),
                                  );
                                }
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          ManageSurauPage(docId: docId)),
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        },
>>>>>>> 0e4038fc063700425527a7fdeee896dfe69815a9
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
