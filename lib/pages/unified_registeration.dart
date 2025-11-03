import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/pages/unified_login.dart';

class UnifiedRegisterPage extends StatefulWidget {
  const UnifiedRegisterPage({super.key});

  @override
  State<UnifiedRegisterPage> createState() => _UnifiedRegisterPageState();
}

class _UnifiedRegisterPageState extends State<UnifiedRegisterPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _surauNameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedUserType = 'AJK'; // default
  bool _isLoading = false;

  Future<void> _register() async {
    final username = _usernameController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final surauName = _surauNameController.text.trim();
    final email = _emailController.text.trim();
    final userType = _selectedUserType;

    if (username.isEmpty || password.isEmpty || confirmPassword.isEmpty || email.isEmpty || (userType == 'AJK' && surauName.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila isi semua medan yang diperlukan.")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kata laluan dan pengesahan tidak sama.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(username);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama pengguna sudah wujud.")),
        );
        return;
      }

      // Tentukan role & status
      String role = '';
      String status = '';

      if (userType == 'AJK') {
        role = 'ajk';
        status = 'active';
      } else if (userType == 'PAID') {
        role = 'admin';
        status = 'pending'; // tunggu superadmin approve
      }

      await docRef.set({
        'username': username,
        'password': password,
        'surauName': userType == 'AJK' ? surauName : '',
        'email': email,
        'userType': userType,
        'role': role,
        'status': status,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            userType == 'PAID'
                ? "Pendaftaran berjaya! Tunggu kelulusan superadmin."
                : "Pendaftaran berjaya! Anda boleh log masuk sekarang.",
          ),
        ),
      );

      // Clear form
      _usernameController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _surauNameController.clear();
      _emailController.clear();
      setState(() => _selectedUserType = 'AJK');

      // 🔹 Kembali ke login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UnifiedLoginPage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat pendaftaran: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Akaun NurSurau"),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: const Color(0xFF87AC4F),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Dropdown User Type di atas
            DropdownButtonFormField<String>(
              value: _selectedUserType,
              items: const [
                DropdownMenuItem(value: 'AJK', child: Text('AJK')),
                DropdownMenuItem(value: 'PAID', child: Text('PAID')),
              ],
              onChanged: (val) {
                setState(() => _selectedUserType = val!);
              },
              decoration: const InputDecoration(
                labelText: "Jenis Akaun",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Nama Surau hanya untuk AJK
            if (_selectedUserType == 'AJK') ...[
              TextField(
                controller: _surauNameController,
                decoration: const InputDecoration(
                  labelText: "Nama Surau",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
            ],

            // Username
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: "Nama Pengguna",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Email
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Emel",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Password
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Kata Laluan",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Confirm Password
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Sahkan Kata Laluan",
                border: OutlineInputBorder(),
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
                    onPressed: _register,
                    child: const Text("Daftar"),
                  ),
          ],
        ),
      ),
    );
  }
}
