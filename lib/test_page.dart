import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  Future<void> createSampleData() async {
    final firestore = FirebaseFirestore.instance;

    // ===== Admin Pejabat Agama =====
    await firestore.collection('admin_pejabat_agama').doc('admin01').set({
      'name': 'Pejabat Agama Daerah KL',
      'email': 'admin@pejabatkl.gov.my',
      'role': 'pejabat',
    });

    // ===== Surau Registrations (Pending) =====
    await firestore.collection('surau_registrations').add({
      'surauName': 'Surau Al-Falah',
      'address': 'Jalan Damai 5, Kuala Lumpur',
      'nazirName': 'Hj Ahmad',
      'nazirPhone': '0123456789',
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
    });

    // ===== Approved Suraus =====
    final surau1 = await firestore.collection('suraus').add({
      'name': 'Surau Al-Amin',
      'address': 'Taman Seri Murni, Selangor',
      'nazirName': 'Hj Salleh',
      'nazirPhone': '0198888888',
      'ajkId': 'ajk_alamin01',
      'approved': true,
    });

    final surau2 = await firestore.collection('suraus').add({
      'name': 'Surau An-Nur',
      'address': 'Bandar Baru Bangi, Selangor',
      'nazirName': 'Hj Rahman',
      'nazirPhone': '0177777777',
      'ajkId': 'ajk_annur01',
      'approved': true,
    });

    // ===== Posts for each surau =====
    await surau1.collection('posts').add({
      'programName': 'Gotong Royong Perdana',
      'description': 'Mari bersama membersihkan kawasan surau pada hari Sabtu ini!',
      'imageUrl': 'https://example.com/gotong_royong.jpg',
      'dateUploaded': FieldValue.serverTimestamp(),
    });

    await surau2.collection('posts').add({
      'programName': 'Kuliah Maghrib Bulanan',
      'description': 'Disampaikan oleh Ustaz Halim pada setiap Jumaat pertama bulan.',
      'imageUrl': 'https://example.com/kuliah.jpg',
      'dateUploaded': FieldValue.serverTimestamp(),
    });

    // ===== Donations =====
    await surau1.collection('donations').add({
      'donationName': 'Derma Ramadan',
      'description': 'Sumbangan untuk juadah berbuka puasa.',
      'bankAccount': '1234567890',
      'qrUrl': 'https://example.com/qr_ramadan.png',
    });

    await surau2.collection('donations').add({
      'donationName': 'Tabung Pembangunan Surau',
      'description': 'Dana untuk naik taraf tandas dan tempat wuduk.',
      'bankAccount': '9876543210',
      'qrUrl': 'https://example.com/qr_pembangunan.png',
    });

    // ===== AJK Users =====
    await firestore.collection('ajk_users').doc('ajk_alamin01').set({
      'username': 'ajk_alamin01',
      'password': '123456',
      'surauName': 'Surau Al-Amin',
      'role': 'ajk',
    });

    await firestore.collection('ajk_users').doc('ajk_annur01').set({
      'username': 'ajk_annur01',
      'password': '123456',
      'surauName': 'Surau An-Nur',
      'role': 'ajk',
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Firestore Setup")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await createSampleData();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sample data created successfully!')),
            );
          },
          child: const Text("Create Sample Data"),
        ),
      ),
    );
  }
}
