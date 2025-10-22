import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostingPage extends StatefulWidget {
  const PostingPage({super.key});

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  String? _selectedCategory;
  File? _image;
  bool _isUploading = false;

  final List<String> _categories = [
    'Umum',
    'Aktiviti Surau',
    'Hebahan',
    'Sumbangan'
  ];

  // Pilih gambar dari galeri
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  // Muat naik ke Cloudinary
  Future<String?> _uploadToCloudinary(File image) async {
    const cloudName = 'dvrws03cg'; // Ganti dengan Cloudinary cloud name kamu
    const uploadPreset = 'unsigned_preset'; // Ganti dengan preset kamu

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final jsonData = json.decode(responseData);
      return jsonData['secure_url']; // Cloudinary image URL
    } else {
      debugPrint('Upload failed: ${response.reasonPhrase}');
      return null;
    }
  }

  // Muat naik posting ke Firestore
  Future<void> _uploadPost() async {
    if (_titleController.text.isEmpty ||
        _descController.text.isEmpty ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sila lengkapkan semua maklumat')),
      );
      return;
    }

    setState(() => _isUploading = true);
    String? imageUrl;

    if (_image != null) {
      imageUrl = await _uploadToCloudinary(_image!);
    }

    await _firestore.collection('posts').add({
      'title': _titleController.text,
      'description': _descController.text,
      'category': _selectedCategory,
      'imageUrl': imageUrl ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      _isUploading = false;
      _image = null;
      _titleController.clear();
      _descController.clear();
      _selectedCategory = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Berjaya muat naik posting!')),
    );
  }

  // Padam posting
  Future<void> _deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengurusan Posting Surau'),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 Paparan Senarai Posting di atas
            const Text(
              'Senarai Posting',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Ralat memuatkan data.');
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final posts = snapshot.data!.docs;
                if (posts.isEmpty) {
                  return const Text('Tiada posting buat masa ini.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final data = posts[index].data() as Map<String, dynamic>;
                    final postId = posts[index].id;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        title: Text(data['title'] ?? ''),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['description'] ?? ''),
                            const SizedBox(height: 5),
                            if (data['category'] != null)
                              Text(
                                "Kategori: ${data['category']}",
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            const SizedBox(height: 8),
                            if (data['imageUrl'] != null &&
                                (data['imageUrl'] as String).isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  data['imageUrl'],
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                        child: CircularProgressIndicator());
                                  },
                                  errorBuilder:
                                      (context, error, stackTrace) => const Text(
                                    '❌ Gagal memuat gambar',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deletePost(postId),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),
            const Divider(thickness: 1.5),
            const SizedBox(height: 10),

            // 🔹 Borang Tambah Posting di bawah sekali
            ExpansionTile(
              title: const Text('Tambah Posting Baru'),
              iconColor: Colors.teal,
              collapsedIconColor: Colors.teal,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tajuk',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedCategory,
                  onChanged: (value) => setState(() => _selectedCategory = value),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pilih Gambar'),
                    ),
                    const SizedBox(width: 10),
                    if (_image != null)
                      Text(
                        '✅ Gambar dipilih',
                        style: TextStyle(color: Colors.green[700]),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                _isUploading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: _uploadPost,
                        icon: const Icon(Icons.upload),
                        label: const Text('Muat Naik Posting'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 135, 172, 79),
                          foregroundColor: Colors.white,
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
