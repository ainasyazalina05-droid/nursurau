import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

// Alias import untuk elak conflict
import 'package:nursurau/pages/admin_ajk/admin_dashboard.dart' as ajk;
import 'package:nursurau/pages/admin_paid/paid_dashboard.dart' as paid;
import 'package:nursurau/pages/superadmin_dasbboard.dart';
import 'package:nursurau/pages/unified_registeration.dart';

class UnifiedLoginPage extends StatefulWidget {
  const UnifiedLoginPage({super.key});

  @override
  State<UnifiedLoginPage> createState() => _UnifiedLoginPageState();
}

class _UnifiedLoginPageState extends State<UnifiedLoginPage> {
  final _usernameController = TextEditingController();
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
      debugPrint("❌ Firebase init failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebase init failed: $e")),
      );
    }
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila isi nama pengguna dan kata laluan.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Check SUPERADMIN first
      var snapshot = await FirebaseFirestore.instance.collection('superadmins').doc(username).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const SuperAdminDashboard()),
          );
          return;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kata laluan salah.")),
          );
          return;
        }
      }

      // 2️⃣ Check AJK
      snapshot = await FirebaseFirestore.instance.collection('ajk_users').doc(username).get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        if (data['status'] == 'blocked') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Akaun anda telah disekat.")),
          );
        } else if (data['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ajk.AdminDashboard(ajkId: username)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kata laluan salah.")),
          );
        }
        return;
      }

      // 3️⃣ Check PAID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admin_pejabat_agama')
          .where('username', isEqualTo: username)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        final data = doc.data();
        if (data['status'] != 'active') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Akaun PAID tidak aktif atau disekat. Status: ${data['status']}")),
          );
        } else if (data['password'] == password) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => paid.PaidDashboard(paidId: doc.id)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kata laluan salah.")),
          );
        }
        return;
      }

      // 4️⃣ Not found in any collection
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama pengguna tidak dijumpai.")),
      );
    } catch (e) {
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
                "PORTAL NURSURAU 🌿🕌",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF87AC4F),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 25),
              Image.asset('assets/logo.png', width: 180, height: 180),
              const SizedBox(height: 20),

              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: "Nama Pengguna",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 15),

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

              const SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UnifiedRegisterPage()),
                  );
                },
                child: const Text(
                  "Belum ada akaun? Daftar di sini",
                  style: TextStyle(
                    color: Color(0xFF87AC4F),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
