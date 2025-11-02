import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nursurau/pages/admin_paid/paid_dashboard.dart';

class PaidLoginPage extends StatefulWidget {
  const PaidLoginPage({super.key});

  @override
  State<PaidLoginPage> createState() => _PaidLoginPageState();
}

class _PaidLoginPageState extends State<PaidLoginPage> {
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initFirebase();
  }

  Future<void> _initFirebase() async {
    try {
      await Firebase.initializeApp();
      debugPrint("✅ Firebase initialized successfully");
    } catch (e) {
      debugPrint("❌ Firebase initialization failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebase init failed: $e")),
      );
    }
  }

  Future<void> _login() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila masukkan kata laluan.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance
          .collection('admin_pejabat_agama')
          .doc('admin01'); // fixed document ID

      final snapshot = await docRef.get();

      // 🔹 Show snapshot info in SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            snapshot.exists
                ? "Dokumen ditemui! Data: ${snapshot.data()}"
                : "Dokumen admin01 tidak dijumpai!",
          ),
          duration: const Duration(seconds: 5),
        ),
      );

      if (!snapshot.exists) return; // Stop login if doc not found

      final data = snapshot.data()!;
      if (data['status'] != 'active') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  "Akaun tidak aktif atau disekat. Status: ${data['status']}")),
        );
      } else if (data['password'] == password) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selamat datang ke Portal PAID NurSurau 🕌"),
            duration: Duration(seconds: 2),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PaidDashboard(paidId: snapshot.id),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Kata laluan salah.")),
        );
      }
    } catch (e) {
      debugPrint("❌ Firestore login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat log masuk: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 247, 245),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Selamat datang ke Portal PAID NurSurau! 🕌",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF87AC4F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Image.asset('assets/logo.png', width: 180, height: 180),
              const SizedBox(height: 20),

              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Kata Laluan",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87AC4F),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: _login,
                      child: const Text(
                        "Log Masuk",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
