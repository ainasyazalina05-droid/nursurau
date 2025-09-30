// surau_details_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/follow_services.dart';

class SurauDetailsPage extends StatefulWidget {
  final String surauName;

  const SurauDetailsPage({super.key, required this.surauName});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  bool isFollowed = false;

  @override
  void initState() {
    super.initState();
    _loadFollowStatus();
  }

  Future<void> _loadFollowStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFollowed = prefs.getBool("follow_${widget.surauName}") ?? false;
    });
  }

  Future<void> _toggleFollow() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFollowed = !isFollowed;
    });
    await prefs.setBool("follow_${widget.surauName}", isFollowed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      appBar: AppBar(
        title: Text(widget.surauName),
        backgroundColor: const Color(0xFF2F5D50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                "assets/surau1.jpg",
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.surauName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Keterangan surau ini akan dipaparkan di sini. Anda boleh menambah maklumat lanjut seperti lokasi, aktiviti, atau kemudahan.",
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: _toggleFollow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isFollowed ? Colors.red : const Color(0xFF2F5D50),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isFollowed ? "Unfollow" : "Follow",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
