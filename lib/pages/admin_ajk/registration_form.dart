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

        // ✅ Generate unique document ID based on surau name + timestamp
        final surauDocId =
            "${_surauName.text.trim()}_${DateTime.now().millisecondsSinceEpoch}";

        // ✅ Step 1: Create main document in "form" collection
        await firestore.collection("form").doc(surauDocId).set({
          "surauName": _surauName.text.trim(),
          "surauAddress": _surauAddress.text.trim(),
          "status": "pending", // 🔥 Tambah ni supaya dashboard boleh detect
          "createdAt": Timestamp.now(),
          });


        // ✅ Step 2: Create subcollection "ajk" → document "ajk_data"
        await firestore
            .collection("form")
            .doc(surauDocId)
            .collection("ajk")
            .doc("ajk_data")
            .set({
          "ajkName": _ajkName.text.trim(),
          "ic": _ic.text.trim(),
          "email": _email.text.trim(),
          "phone": _phone.text.trim(),
          "password": _password.text.trim(),
          "status": "pending",
          "createdAt": Timestamp.now(),
        });

        // ✅ Step 3: Create subcollection "donation" → document "donation_data"
        await firestore
            .collection("form")
            .doc(surauDocId)
            .collection("donation")
            .doc("donation_data")
            .set({
          "title": "",
          "amount": "",
          "description": "",
          "account": "",
          "contact": "",
          "qrUrl": "",
          "createdAt": Timestamp.now(),
        });

        // ✅ Step 4: Create subcollection "surauDetails" → document "surauDetails_data"
        await firestore
            .collection("form")
            .doc(surauDocId)
            .collection("surauDetails")
            .doc("surauDetails_data")
            .set({
          "imam": "",
          "activities": [],
          "facilities": [],
          "createdAt": Timestamp.now(),
        });

        // ✅ Step 5: Create subcollection "posting" → document "posting_data"
        await firestore
            .collection("form")
            .doc(surauDocId)
            .collection("posting")
            .doc("posting_data")
            .set({
          "title": "",
          "content": "",
          "imageUrl": "",
          "createdAt": Timestamp.now(),
        });

        // ✅ Success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maklumat berjaya dihantar!')),
        );

        // ✅ Clear all input fields
        _ajkName.clear();
        _ic.clear();
        _email.clear();
        _phone.clear();
        _surauName.clear();
        _surauAddress.clear();
        _password.clear();

        Navigator.pop(context); // back to previous page
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ralat: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pendaftaran AJK Surau'),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
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
                          color: Colors.grey),
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
                      backgroundColor: const Color.fromARGB(255, 135, 172, 79),
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
