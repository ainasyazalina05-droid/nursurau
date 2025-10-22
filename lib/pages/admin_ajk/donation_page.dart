import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonationPage extends StatefulWidget {
  final String ajkId;
  const DonationPage({super.key, required this.ajkId});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> {
  String? _surauId;
  bool _isLoading = true;

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _bankController = TextEditingController();
  final _qrController = TextEditingController();

  File? _image;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _getSurauId();
  }

  Future<void> _getSurauId() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('suraus')
          .where('ajkId', isEqualTo: widget.ajkId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        setState(() => _surauId = query.docs.first.id);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tiada surau dijumpai untuk AJK ini.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat memuat data: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 📸 Pick image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // ☁️ Upload image to Cloudinary
  Future<String?> _uploadToCloudinary(File image) async {
    const cloudName = 'dvrws03cg'; // ganti dengan cloud name kamu
    const uploadPreset = 'unsigned_preset'; // ganti dengan preset

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonData = json.decode(responseData);
      return jsonData['secure_url'];
    } else {
      debugPrint('Upload failed: ${response.reasonPhrase}');
      return null;
    }
  }

  Future<void> _addDonation() async {
    if (_surauId == null) return;

    final name = _nameController.text.trim();
    final desc = _descController.text.trim();
    final bank = _bankController.text.trim();
    final qrUrl = _qrController.text.trim();

    if (name.isEmpty || desc.isEmpty || bank.isEmpty || qrUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila isi semua ruangan.")),
      );
      return;
    }

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
          .add({
        'name': name,
        'description': desc,
        'bankAccount': bank,
        'qrUrl': qrUrl,
        'imageUrl': imageUrl ?? '',
        'createdBy': widget.ajkId,
        'dateCreated': FieldValue.serverTimestamp(),
      });

      _nameController.clear();
      _descController.clear();
      _bankController.clear();
      _qrController.clear();
      setState(() => _image = null);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Derma baru ditambah!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat menambah derma: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deleteDonation(String id) async {
    if (_surauId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('suraus')
          .doc(_surauId)
          .collection('donations')
          .doc(id)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Derma dipadam.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat memadam derma: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Derma Surau", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
        centerTitle: true,
      ),
      body: _surauId == null
          ? const Center(child: Text("Tiada surau dijumpai."))
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('suraus')
                        .doc(_surauId)
                        .collection('donations')
                        .orderBy('dateCreated', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("Tiada derma lagi."));
                      }

                      final donations = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final data =
                              donations[index].data() as Map<String, dynamic>;
                          final docId = donations[index].id;

                          return Card(
                            margin: const EdgeInsets.all(10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: data['imageUrl'] != null &&
                                      (data['imageUrl'] as String).isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        data['imageUrl'],
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image, size: 50),
                              title: Text(data['name'] ?? ''),
                              subtitle: Text(data['description'] ?? ''),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDonation(docId),
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: Text(data['name']),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text("Akaun: ${data['bankAccount']}"),
                                        const SizedBox(height: 10),
                                        Image.network(
                                          data['qrUrl'] ?? '',
                                          height: 150,
                                          errorBuilder:
                                              (context, _, __) => const Icon(
                                            Icons.qr_code,
                                            size: 80,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (data['imageUrl'] != null &&
                                            (data['imageUrl'] as String)
                                                .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 10),
                                            child: Image.network(
                                              data['imageUrl'],
                                              height: 150,
                                              errorBuilder: (context, _, __) =>
                                                  const Icon(
                                                Icons.image,
                                                size: 80,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ExpansionTile(
                    title: const Text("Tambah Derma Baru"),
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Nama Derma",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _descController,
                        decoration: const InputDecoration(
                          labelText: "Penerangan",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _bankController,
                        decoration: const InputDecoration(
                          labelText: "No Akaun Bank",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _qrController,
                        decoration: const InputDecoration(
                          labelText: "Pautan QR (URL)",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Pilih Gambar"),
                          ),
                          const SizedBox(width: 10),
                          if (_image != null)
                            Text(
                              "✅ Gambar dipilih",
                              style: TextStyle(color: Colors.green[700]),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _isUploading
                          ? const CircularProgressIndicator()
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                    255, 135, 172, 79),
                                minimumSize: const Size(double.infinity, 45),
                              ),
                              onPressed: _addDonation,
                              icon: const Icon(Icons.add, color: Colors.white),
                              label: const Text("Tambah",
                                  style: TextStyle(color: Colors.white)),
                            ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
