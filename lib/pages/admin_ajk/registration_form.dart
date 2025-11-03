import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _AjkRegisterFormState();
}

class _AjkRegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _ajkName = TextEditingController();
  final TextEditingController _ic = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _surauName = TextEditingController();
  final TextEditingController _surauAddress = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _ajkName.dispose();
    _ic.dispose();
    _email.dispose();
    _phone.dispose();
    _surauName.dispose();
    _surauAddress.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        final firestore = FirebaseFirestore.instance;

        // 🔹 1. Simpan maklumat surau baru
        final surauRef = await firestore.collection("suraus").add({
          "name": _surauName.text.trim(),
          "address": _surauAddress.text.trim(),
          "status": "pending",
          "createdAt": Timestamp.now(),
        });

        // 🔹 2. Cipta username automatik (contoh: ajk_alamin01)
        String cleanSurauName = _surauName.text.trim().toLowerCase().replaceAll(" ", "");
        String username = "${cleanSurauName}";

        // 🔹 3. Simpan akaun AJK ke dalam ajk_users (guna doc ID = username)
        await firestore.collection("ajk_users").doc(username).set({
          "username": username,
          "password": _password.text.trim(),
          "role": "ajk",
          "status": "approved",
          "surauId": surauRef.id,
          "surauName": _surauName.text.trim(),
          "ajkName": _ajkName.text.trim(),
          "phone": _phone.text.trim(),
          "email": _email.text.trim(),
          "createdAt": Timestamp.now(),
        });

        // 🔹 4. (Optional) Simpan juga dalam collection form kalau nak simpan semua data permohonan
        await firestore.collection("form").doc(surauRef.id).set({
          "ajkName": _ajkName.text.trim(),
          "ic": _ic.text.trim(),
          "email": _email.text.trim(),
          "phone": _phone.text.trim(),
          "surauName": _surauName.text.trim(),
          "surauAddress": _surauAddress.text.trim(),
          "status": "pending",
          "createdAt": Timestamp.now(),
        });

        // 🔹 5. Papar mesej berjaya
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Surau & Akaun AJK "${_surauName.text}" berjaya mendaftar! Tunggu surau disahkan.')),
        );

        // Kosongkan form
        _ajkName.clear();
        _ic.clear();
        _email.clear();
        _phone.clear();
        _surauName.clear();
        _surauAddress.clear();
        _password.clear();

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ralat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran AJK Surau'),
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: const Color(0xFF87AC4F),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Maklumat AJK",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ajkName,
                  decoration: const InputDecoration(
                    labelText: 'Nama AJK',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Sila isi nama AJK' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _ic,
                  decoration: const InputDecoration(
                    labelText: 'No. IC',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? 'Sila isi No. IC' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Emel',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.contains('@') ? null : 'Emel tidak sah',
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                    labelText: 'No. Telefon',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? 'Sila isi No. Telefon' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Kata Laluan',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Sila isi kata laluan';
                    } else if (value.length < 6) {
                      return 'Kata laluan mesti sekurang-kurangnya 6 aksara';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                const Text("Maklumat Surau",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _surauName,
                  decoration: const InputDecoration(
                    labelText: 'Nama Surau',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Sila isi nama surau' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _surauAddress,
                  decoration: const InputDecoration(
                    labelText: 'Alamat Surau',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value!.isEmpty ? 'Sila isi alamat surau' : null,
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Hantar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF87AC4F),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    onPressed: _submitForm,
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
