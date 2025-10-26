import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class PostingPage extends StatefulWidget {
  final String ajkId;
  const PostingPage({super.key, required this.ajkId});

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = File(picked.path));
    }
  }

  Future<String?> _uploadToCloudinary(File image) async {
    const cloudName = 'dvrws03cg';
    const uploadPreset = 'unsigned_preset';

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
      'ajkId': widget.ajkId,
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

  Future<void> _updatePost(String postId) async {
    setState(() => _isUploading = true);
    String? imageUrl;
    if (_image != null) {
      imageUrl = await _uploadToCloudinary(_image!);
    }

    await _firestore.collection('posts').doc(postId).update({
      'title': _titleController.text.trim(),
      'description': _descController.text.trim(),
      'category': _selectedCategory,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });

    setState(() {
      _isUploading = false;
      _image = null;
      _titleController.clear();
      _descController.clear();
      _selectedCategory = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Posting berjaya dikemaskini!')),
    );
  }

  void _editPost(String postId, Map<String, dynamic> data) {
    _titleController.text = data['title'] ?? '';
    _descController.text = data['description'] ?? '';
    _selectedCategory = data['category'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Kemaskini Posting"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                      labelText: "Tajuk", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                      labelText: "Keterangan", border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                      labelText: "Kategori", border: OutlineInputBorder()),
                  value: _selectedCategory,
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  items: _categories
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Tukar Gambar (jika perlu)"),
                  ),
                ),
                if (_image != null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      '✅ Gambar dipilih',
                      style: TextStyle(color: Colors.green),
                    ),
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
                await _updatePost(postId);
              },
              child: const Text("Simpan"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sahkan Padam"),
        content: const Text("Adakah anda pasti ingin memadam posting ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Padam"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestore.collection('posts').doc(postId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Posting berjaya dipadam.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat memadam posting: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 🔹 Borang Tambah Posting
          ExpansionTile(
            title: const Text('Tambah Posting Baru'),
            iconColor: Colors.teal,
            collapsedIconColor: Colors.teal,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                          labelText: 'Tajuk', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          labelText: 'Keterangan',
                          border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                          labelText: 'Kategori', border: OutlineInputBorder()),
                      value: _selectedCategory,
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                      items: _categories
                          .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Pilih Gambar'),
                      ),
                    ),
                    if (_image != null)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          '✅ Gambar dipilih',
                          style: TextStyle(color: Colors.green),
                        ),
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
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('posts')
                .where('ajkId', isEqualTo: widget.ajkId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Text(
                  'Ralat: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('Tiada posting buat masa ini.');
              }

              final posts = snapshot.data!.docs;
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
                              ),
                            ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editPost(postId, data),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deletePost(postId),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
