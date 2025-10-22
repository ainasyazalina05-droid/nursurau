import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';

/// Uploads a local asset image to Firebase Storage and returns its download URL
Future<String> uploadToStorage(String localPath, String storagePath) async {
  final storage = FirebaseStorage.instance;
  Uint8List data = await rootBundle.load(localPath).then((byteData) => byteData.buffer.asUint8List());
  final ref = storage.ref(storagePath);
  await ref.putData(data);
  return await ref.getDownloadURL();
}

/// Seeds NurSurau sample data into Firestore + Storage
Future<void> seedNurSurauData() async {
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  // --- 1️⃣ Define sample suraus ---
  final surauList = [
    {
      'name': 'Surau Al-Amin',
      'address': 'Jalan Damai 5, Kuala Lumpur',
      'nazirName': 'Hj Ahmad',
      'nazirPhone': '0123456789',
      'ajkId': 'ajk_alamin',
      'email': 'alamin.ajk@gmail.com',
      'phone': '0123456789',
    },
    {
      'name': 'Surau An-Nur',
      'address': 'Taman Bukit Indah, Johor Bahru',
      'nazirName': 'Hj Yusuf',
      'nazirPhone': '0133334444',
      'ajkId': 'ajk_annur',
      'email': 'annur.ajk@gmail.com',
      'phone': '0133334444',
    },
    {
      'name': 'Surau As-Salam',
      'address': 'Kampung Baru, Penang',
      'nazirName': 'Hj Rahman',
      'nazirPhone': '0145556666',
      'ajkId': 'ajk_assalam',
      'email': 'assalam.ajk@gmail.com',
      'phone': '0145556666',
    },
  ];

  // --- 2️⃣ Create suraus, posts, donations, and link AJKs ---
  for (var surau in surauList) {
    final ajkId = surau['ajkId'] as String;

    // Upload surau profile image
    final surauImageUrl = await uploadToStorage(
      'assets/surau.jpg',
      'surau_images/$ajkId/profile.jpg',
    );

    // Create surau document
    final surauRef = await firestore.collection('suraus').add({
      'name': surau['name'],
      'address': surau['address'],
      'nazirName': surau['nazirName'],
      'nazirPhone': surau['nazirPhone'],
      'imageUrl': surauImageUrl,
      'ajkId': ajkId,
      'approved': true,
      'followers': [],
      'createdAt': FieldValue.serverTimestamp(),
    });

    // --- Add posts ---
    final post1Image = await uploadToStorage(
      'assets/post1.jpg',
      'surau_images/$ajkId/posts/post1.jpg',
    );

    final post2Image = await uploadToStorage(
      'assets/post2.jpg',
      'surau_images/$ajkId/posts/post2.jpg',
    );

    await surauRef.collection('posts').add({
      'title': 'Gotong Royong',
      'description': 'Mari bersama bersihkan kawasan surau hujung minggu ini!',
      'imageUrl': post1Image,
      'dateUploaded': FieldValue.serverTimestamp(),
      'createdBy': ajkId,
    });

    await surauRef.collection('posts').add({
      'title': 'Kuliah Maghrib',
      'description': 'Kuliah Maghrib bersama Ustaz Ahmad setiap Jumaat malam.',
      'imageUrl': post2Image,
      'dateUploaded': FieldValue.serverTimestamp(),
      'createdBy': ajkId,
    });

    // --- Add donations ---
    final qrUrl = await uploadToStorage(
      'assets/qr.png',
      'surau_qr/$ajkId/qr.png',
    );

    await surauRef.collection('donations').add({
      'name': 'Derma Ramadan',
      'description': 'Sumbangan untuk program iftar Ramadan.',
      'bankAccount': '1234567890',
      'qrUrl': qrUrl,
      'createdBy': ajkId,
      'dateCreated': FieldValue.serverTimestamp(),
    });

    await surauRef.collection('donations').add({
      'name': 'Tabung Surau',
      'description': 'Sumbangan penyelenggaraan surau.',
      'bankAccount': '9876543210',
      'qrUrl': qrUrl,
      'createdBy': ajkId,
      'dateCreated': FieldValue.serverTimestamp(),
    });

    // --- Create and link AJK admin ---
    await firestore.collection('ajk_admins').doc(ajkId).set({
      'email': surau['email'],
      'password': 'hashed_password_123', // replace later with real auth
      'surauId': surauRef.id, // ✅ auto-linked
      'name': 'Admin ${surau['name']}',
      'phone': surau['phone'],
      'status': 'approved',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update surau doc with reverse link (optional)
    await surauRef.update({'ajkId': ajkId});

    print('✅ Created ${surau['name']} and linked AJK $ajkId');
  }

  // --- 3️⃣ Add one pending surau registration ---
  final pendingImage = await uploadToStorage(
    'assets/surau.jpg',
    'surau_registrations/AlHidayah/profile.jpg',
  );

  await firestore.collection('surau_registrations').add({
    'surauName': 'Surau Al-Hidayah',
    'address': 'Bandar Baru, Selangor',
    'nazirName': 'Hj Halim',
    'nazirPhone': '0178889999',
    'email': 'alhidayah.ajk@gmail.com',
    'bankAccount': '123443211234',
    'imageUrl': pendingImage,
    'status': 'pending',
    'submittedAt': FieldValue.serverTimestamp(),
  });

  print('\n🎉 All NurSurau sample data successfully created and linked!');
}
