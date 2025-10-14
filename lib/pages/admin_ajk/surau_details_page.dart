import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SurauDetailsPage extends StatefulWidget {
  final String surauName; // e.g. "Al-Amin"
  final String ajkId; // AJK ID for the admin user

  const SurauDetailsPage({
    super.key,
    required this.surauName,
    required this.ajkId, required String surauId,
  });

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  File? _imageFile;
  bool _isLoading = false;
  Map<String, dynamic>? _surauData;
  String? _documentId;

  @override
  void initState() {
    super.initState();
    _loadSurauData();
  }

  Future<void> _loadSurauData() async {
    setState(() => _isLoading = true);

    try {
      // Search surau in "form" collection using surauName
      final querySnapshot = await _firestore
          .collection('form')
          .where('surauName', isEqualTo: widget.surauName)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() {
          _surauData = querySnapshot.docs.first.data();
          _documentId = querySnapshot.docs.first.id;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Surau ${widget.surauName} not found')),
        );
      }
    } catch (e) {
      print('Error loading surau data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: $e')),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _documentId == null) return;

    setState(() => _isLoading = true);

    try {
      final fileName = '${widget.surauName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance
          .ref()
          .child('surau_images')
          .child(fileName);

      await ref.putFile(_imageFile!);
      final imageUrl = await ref.getDownloadURL();

      // ✅ Update inside the same "form" collection
      await _firestore.collection('form').doc(_documentId).update({
        'photoUrl': imageUrl,
        'updatedBy': widget.ajkId,
        'updatedAt': DateTime.now().toIso8601String(),
      });

      setState(() {
        _surauData?['photoUrl'] = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } catch (e) {
      print('Error uploading image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image')),
      );
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_surauData == null) {
      return const Scaffold(
        body: Center(child: Text('No surau data found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surauName),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 70,
                backgroundImage: _surauData!['photoUrl'] != null
                    ? NetworkImage(_surauData!['photoUrl'])
                    : const AssetImage('assets/default_surau.png')
                        as ImageProvider,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 20,
                    child: const Icon(Icons.camera_alt,
                        color: Color.fromARGB(255, 135, 172, 79)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _surauData!['surauName'] ?? 'Unnamed Surau',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _surauData!['address'] ?? 'No address provided',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_surauData!['description'] != null)
              Text(
                _surauData!['description'],
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
