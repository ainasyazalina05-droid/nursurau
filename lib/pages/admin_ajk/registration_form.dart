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

  @override
  void dispose() {
    _ajkName.dispose();
    _ic.dispose();
    _email.dispose();
    _phone.dispose();
    _surauName.dispose();
    _surauAddress.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection("form").add({
          "ajkName": _ajkName.text,
          "ic": _ic.text,
          "email": _email.text,
          "phone": _phone.text,
          "surauName": _surauName.text,
          "address": _surauAddress.text,
          "status": "pending",
          "createdAt": Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Maklumat berjaya dihantar!')),
        );

        _ajkName.clear();
        _ic.clear();
        _email.clear();
        _phone.clear();
        _surauName.clear();
        _surauAddress.clear();

        Navigator.pop(context); // balik ke page sebelum ni
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
        backgroundColor: Colors.green,
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
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
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
