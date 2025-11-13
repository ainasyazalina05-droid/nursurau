import 'package:flutter/material.dart';

class ConfirmApprovalPage extends StatelessWidget {
  final String username;
  final String docId;
  final String action; // 'approve' or 'reject'
  final Function(String docId, String newStatus) onConfirm;

  const ConfirmApprovalPage({
    super.key,
    required this.username,
    required this.docId,
    required this.action,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isApprove = action == 'approve';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isApprove ? Colors.green : Colors.red,
        title: Text(isApprove ? 'Sahkan Kelulusan' : 'Sahkan Penolakan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 80,
              color: isApprove ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              "Adakah anda pasti ingin ${isApprove ? 'meluluskan' : 'menolak'} admin:\n\n$username?",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey),
                  child: const Text("Batal"),
                ),
                ElevatedButton(
                  onPressed: () {
                    onConfirm(docId, isApprove ? 'active' : 'rejected');
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: isApprove ? Colors.green : Colors.red),
                  child: const Text("Ya", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
