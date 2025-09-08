import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔹 Import Firestore package

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NurSurau Admin AJK',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(), // 🔹 Home page adalah LoginPage
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 🔹 Controllers untuk ambil input email & password
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // 🔹 Firestore reference ke collection 'users'
  final CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    // 🔹 Query Firestore untuk check login credentials
    final query = await usersCollection
        .where('email', isEqualTo: email) // cari email
        .where('password', isEqualTo: password) // check password
        .get();

    if (query.docs.isNotEmpty) {
      // 🔹 Login berjaya, navigate ke Admin Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
    } else {
      // 🔹 Login gagal, tunjuk message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid login")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin AJK Login")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 🔹 TextField untuk email input
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            // 🔹 TextField untuk password input
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            // 🔹 Button untuk trigger login function
            ElevatedButton(onPressed: _login, child: const Text("Login")),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin AJK Dashboard")),
      body: const Center(
        child: Text(
          "Welcome Admin AJK",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
