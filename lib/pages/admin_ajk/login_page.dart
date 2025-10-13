import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_dashboard.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final query = await usersCollection
          .where('email', isEqualTo: email)
          .where('password', isEqualTo: password)
          .get();

<<<<<<< HEAD
      if (query.docs.isNotEmpty) {
        // Get the AJK ID from the first matching document
        final ajkId = query.docs.first.id;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AdminDashboard(ajkId: ajkId),
          ),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Invalid login")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
=======
    if (query.docs.isNotEmpty) {
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Log masuk tidak sah")),
      );
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: const Color(0xFFF5EFD1),
      appBar: AppBar(
        title: const Text("Admin AJK Login"),
        backgroundColor: Colors.green,
=======
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Portal Pentadbir AJK",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),  // warna tulisan putih
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 135, 172, 79), // hijau tema utama
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle,
<<<<<<< HEAD
                    size: 80, color: Colors.green),
=======
                    size: 80, color:   Color.fromARGB(255, 135, 172, 79),), // 🌟 icon besar atas

>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
                const SizedBox(height: 20),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    prefixIcon: const Icon(Icons.email, color:  Color.fromARGB(255, 135, 172, 79),),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Kata Laluan",
                    prefixIcon: const Icon(Icons.lock, color:   Color.fromARGB(255, 135, 172, 79),),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  const Color.fromARGB(255, 135, 172, 79),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _login,
                    child: const Text(
                      "Daftar Masuk",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
