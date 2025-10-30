import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';
import 'registration_form.dart'; // ✅ Make sure this file name matches yours

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila isi nama pengguna dan kata laluan.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef =
          FirebaseFirestore.instance.collection('ajk_users').doc(username);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
         print("DATA LOGIN: $data"); 
        if (data['status'] == 'blocked') {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Akaun anda telah disekat.")),
  );
  return; // stop login
}

        if (data['password'] == password) {
          // ✅ Login success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Selamat datang ${data['surauName']}")),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => AdminDashboard(ajkId: username),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kata laluan salah.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama pengguna tidak dijumpai.")),
        );
      }
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
              const Icon(Icons.mosque,
                  size: 80, color: Color.fromARGB(255, 135, 172, 79)),
              const SizedBox(height: 20),
              const Text(
                "Portal AJK Surau",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 60, 60, 60),
                ),
              ),
              const SizedBox(height: 30),
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

              // ✅ Login button
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 135, 172, 79),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: _login,
                      child: const Text(
                        "Log Masuk",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),

              const SizedBox(height: 20),

              // ✅ Register navigation text button
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterForm(),
                    ),
                  );
                },
                child: const Text(
                  "Belum ada akaun? Daftar di sini",
                  style: TextStyle(
                    color: Color.fromARGB(255, 135, 172, 79),
                    fontSize: 15,
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
