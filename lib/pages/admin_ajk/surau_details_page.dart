import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SurauDetailsPage extends StatefulWidget {
  final String ajkId;
  const SurauDetailsPage({super.key, required this.ajkId});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _nazirNameController = TextEditingController();
  final _nazirPhoneController = TextEditingController();

  String? _docId;
  bool _isLoading = true;
  bool _isUploading = false;

  String? _imageUrl;
  Uint8List? _webImage; // for web
  File? _pickedImage; // for mobile

  // 🔹 Fetch surau details
  Future<void> _fetchSurauDetails() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('suraus')
          .where('ajkId', isEqualTo: widget.ajkId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final doc = snapshot.docs.first;
        _docId = doc.id;
        final data = doc.data();

        _nameController.text = data['name'] ?? '';
        _addressController.text = data['address'] ?? '';
        _nazirNameController.text = data['nazirName'] ?? '';
        _nazirPhoneController.text = data['nazirPhone'] ?? '';
        _imageUrl = data['imageUrl'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Maklumat surau tidak dijumpai.")),
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

  // 🔹 Pick image (web + mobile)
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _webImage = bytes;
          _pickedImage = null;
        });
      } else {
        setState(() {
          _pickedImage = File(picked.path);
          _webImage = null;
        });
      }
    }
  }

  // 🔹 Upload to Cloudinary
  Future<String?> _uploadToCloudinary() async {
    const cloudName = 'dvrws03cg';
    const uploadPreset = 'unsigned_preset';

    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset;

    if (kIsWeb && _webImage != null) {
      request.files.add(http.MultipartFile.fromBytes('file', _webImage!,
          filename: 'surau_image.jpg'));
    } else if (_pickedImage != null) {
      request.files
          .add(await http.MultipartFile.fromPath('file', _pickedImage!.path));
    } else {
      return null;
    }

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

  // 🔹 Update surau info
  Future<void> _updateSurau() async {
    if (_docId == null) return;

    setState(() => _isUploading = true);
    String? newImageUrl = _imageUrl;

    if (_pickedImage != null || _webImage != null) {
      newImageUrl = await _uploadToCloudinary();
    }

    try {
      await FirebaseFirestore.instance.collection('suraus').doc(_docId).update({
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'nazirName': _nazirNameController.text.trim(),
        'nazirPhone': _nazirPhoneController.text.trim(),
        'imageUrl': newImageUrl ?? '',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maklumat surau berjaya dikemas kini.")),
      );

      setState(() {
        _imageUrl = newImageUrl;
        _pickedImage = null;
        _webImage = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat mengemas kini: $e")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  // 🔹 Remove surau image
  Future<void> _removeImage() async {
    if (_docId == null) return;

    await FirebaseFirestore.instance.collection('suraus').doc(_docId).update({
      'imageUrl': '',
    });

    setState(() {
      _imageUrl = null;
      _pickedImage = null;
      _webImage = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Gambar surau telah dipadam.")),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchSurauDetails();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color.fromARGB(255, 135, 172, 79);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Maklumat Surau", style: TextStyle(color: Colors.white)),
        backgroundColor: themeColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.mosque,
                          size: 70, color: Color.fromARGB(255, 135, 172, 79)),
                      const SizedBox(height: 20),

                      // 🔹 Image preview
                      if (_webImage != null || _pickedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: kIsWeb
                              ? Image.memory(_webImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover)
                              : Image.file(_pickedImage!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover),
                        )
                      else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(_imageUrl!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover),
                        )
                      else
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[200],
                          ),
                          child: const Center(
                            child: Text('Tiada gambar surau'),
                          ),
                        ),

                      const SizedBox(height: 10),

                      // 🔹 Buttons row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.image),
                            label: const Text("Pilih Gambar"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: themeColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          if (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ElevatedButton.icon(
                              onPressed: _removeImage,
                              icon: const Icon(Icons.delete),
                              label: const Text("Padam Gambar"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                foregroundColor: Colors.white,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // 🔹 Text fields
                      _buildTextField("Nama Surau", _nameController),
                      const SizedBox(height: 12),
                      _buildTextField("Alamat", _addressController, maxLines: 2),
                      const SizedBox(height: 12),
                      _buildTextField("Nama Nazir", _nazirNameController),
                      const SizedBox(height: 12),
                      _buildTextField("No. Telefon Nazir", _nazirPhoneController),

                      const SizedBox(height: 20),

                      _isUploading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeColor,
                                minimumSize: const Size(double.infinity, 45),
                              ),
                              onPressed: _updateSurau,
                              icon: const Icon(Icons.save, color: Colors.white),
                              label: const Text(
                                "Kemas Kini Maklumat",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
