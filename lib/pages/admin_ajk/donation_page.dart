import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class DonationPage extends StatefulWidget {
  final String ajkId;
  const DonationPage({super.key, required this.ajkId});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _bankController = TextEditingController();
  final TextEditingController _qrUrlController = TextEditingController();

  File? _image;
  String? _surauId;
  bool _isLoading = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _getSurauId();
  }

  Future<void> _getSurauId() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('suraus')
          .where('ajkId', isEqualTo: widget.ajkId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        _surauId = snapshot.docs.first.id;
      } else {
        _surauId = null;
      }
    } catch (e) {
      debugPrint("Error fetching surauId: $e");
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<String?> _uploadToCloudinary(File imageFile) async {
    const cloudName = 'dvrws03cg';
    const uploadPreset = 'unsigned_preset';

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final data = jsonDecode(await response.stream.bytesToString());
        return data['secure_url'];
      } else {
        debugPrint("Cloudinary upload failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Cloudinary error: $e");
    }
    return null;
  }

  Future<void> _addDonation() async {
    if (_surauId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ralat: Surau tidak dijumpai.")),
      );
      return;
    }

    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final bank = _bankController.text.trim();
    final qrUrl = _qrUrlController.text.trim();

    if (title.isEmpty || desc.isEmpty || bank.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila isi semua maklumat.")),
      );
      return;
    }

    if (!RegExp(r'^\d+$').hasMatch(bank)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No akaun mesti nombor sah.")),
      );
      return;
    }

    setState(() => _isUploading = true);

    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadToCloudinary(_image!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal muat naik gambar.")),
        );
        if (!mounted) return;
        setState(() => _isUploading = false);
        return;
      }
    }

    try {
      await FirebaseFirestore.instance
          .collection('suraus')
          .doc(_surauId)
          .collection('donations')
          .add({
        'title': title,
        'description': desc,
        'bankAccount': bank,
        'qrUrl': qrUrl,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sumbangan berjaya ditambah!")),
      );

      _titleController.clear();
      _descController.clear();
      _bankController.clear();
      _qrUrlController.clear();
      setState(() => _image = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat menambah sumbangan: $e")),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isUploading = false);
    }
  }

  Future<void> _updateDonation(String donationId) async {
    if (_surauId == null) return;

    setState(() => _isUploading = true);

    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadToCloudinary(_image!);
    }

    try {
      await FirebaseFirestore.instance
          .collection('suraus')
          .doc(_surauId)
          .collection('donations')
          .doc(donationId)
          .update({
        'title': _titleController.text.trim(),
        'description': _descController.text.trim(),
        'bankAccount': _bankController.text.trim(),
        'qrUrl': _qrUrlController.text.trim(),
        if (imageUrl != null) 'imageUrl': imageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Sumbangan berjaya dikemaskini!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat: $e")),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _editDonation(String donationId, Map<String, dynamic> data) {
    _titleController.text = data['title'] ?? '';
    _descController.text = data['description'] ?? '';
    _bankController.text = data['bankAccount'] ?? '';
    _qrUrlController.text = data['qrUrl'] ?? '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kemaskini Sumbangan"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Tajuk"),
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Penerangan"),
                ),
                TextField(
                  controller: _bankController,
                  decoration: const InputDecoration(labelText: "No Akaun Bank"),
                ),
                TextField(
                  controller: _qrUrlController,
                  decoration: const InputDecoration(labelText: "Pautan QR"),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Tukar Gambar (jika perlu)"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _updateDonation(donationId);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteDonation(String donationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('suraus')
          .doc(_surauId)
          .collection('donations')
          .doc(donationId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sumbangan berjaya dipadam.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat memadam sumbangan: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_surauId == null) {
      return const Center(child: Text("Tiada surau dijumpai untuk AJK ini."));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sumbangan Surau"),
        backgroundColor: Colors.green.shade700,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: "Tajuk"),
                ),
                TextField(
                  controller: _descController,
                  decoration: const InputDecoration(labelText: "Penerangan"),
                ),
                TextField(
                  controller: _bankController,
                  decoration: const InputDecoration(labelText: "No Akaun Bank"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _qrUrlController,
                  decoration: const InputDecoration(labelText: "Pautan QR (jika ada)"),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text("Pilih Gambar"),
                    ),
                    const SizedBox(width: 10),
                    if (_image != null)
                      const Text("✅ Gambar dipilih", style: TextStyle(color: Colors.green)),
                  ],
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _isUploading ? null : _addDonation,
                  child: _isUploading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Tambah Sumbangan"),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('suraus')
                  .doc(_surauId)
                  .collection('donations')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Ralat memuatkan data."));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Tiada sumbangan lagi."));
                }

                final donations = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    final doc = donations[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      elevation: 3,
                      child: ListTile(
                        leading: data['imageUrl'] != null
                            ? GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      child: InteractiveViewer(
                                        child: Image.network(data['imageUrl']),
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(data['imageUrl'], width: 60, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.volunteer_activism, size: 40),
                        title: Text(data['title'] ?? "Tiada tajuk"),
                        subtitle: Text("Akaun Bank: ${data['bankAccount'] ?? '-'}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editDonation(doc.id, data),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDonation(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
