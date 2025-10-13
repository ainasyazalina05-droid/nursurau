import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SurauDetailsPage extends StatelessWidget {
  final String ajkId; // unique AJK ID

  const SurauDetailsPage({super.key, required this.ajkId});

  @override
  Widget build(BuildContext context) {
    final surauQuery = FirebaseFirestore.instance
        .collection('suraus')
        .where('ajkId', isEqualTo: ajkId)
        .limit(1)
        .snapshots();

<<<<<<< HEAD
    return Scaffold(
      backgroundColor: const Color(0xFFEFE5D8),
      appBar: AppBar(
        title: const Text('Butiran Surau'),
        backgroundColor: Colors.green,
=======
class _SurauDetailsPageState extends State<SurauDetailsPage> {
  final _firestore = FirebaseFirestore.instance;
  final _picker = ImagePicker();

  // 🔧 Edit field in main surau info (nama, lokasi, kapasiti)
  Future<void> _editField(String title, String currentValue, String fieldKey) async {
    final controller = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Kemaskini $title"),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection("surauDetails").doc("main").update({
                fieldKey: controller.text,
                "tarikhKemaskini": DateTime.now().toIso8601String(),
              });
              if (mounted) Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 135, 172, 79),
            ),
            child: const Text("Simpan", style: TextStyle(color: Colors.white)),
          ),
        ],
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.edit),
        onPressed: () async {
          // Navigate to the form page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SurauFormPage(ajkId: ajkId),
            ),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: surauQuery,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

<<<<<<< HEAD
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Maklumat surau belum dimasukkan.'));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;
          final tarikhKemaskini = data['tarikhKemaskini'] != null
              ? "${DateTime.parse(data['tarikhKemaskini']).day}-${DateTime.parse(data['tarikhKemaskini']).month}-${DateTime.parse(data['tarikhKemaskini']).year}"
              : '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
=======
  // 🔧 Add or Edit Sub-Entry
  Future<void> _editSubEntry({DocumentSnapshot? doc}) async {
    final data = doc?.data() as Map<String, dynamic>?;

    final titleController = TextEditingController(text: data?['title'] ?? '');
    final descController = TextEditingController(text: data?['description'] ?? '');
    File? imageFile;
    String? existingImageUrl = data?['imageUrl'];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          title: Text(doc == null ? "Tambah Maklumat Baru" : "Kemaskini Maklumat"),
          content: SingleChildScrollView(
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['imageUrl'] != null && data['imageUrl'] != '')
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(data['imageUrl'], height: 200, fit: BoxFit.cover),
                  ),
                const SizedBox(height: 12),
                Text(
                  data['namaSurau'] ?? '-',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text("Lokasi: ${data['lokasi'] ?? '-'}"),
                Text("Kapasiti: ${data['kapasiti'] ?? '-'}"),
                const SizedBox(height: 10),
<<<<<<< HEAD
                Text("Tarikh Kemaskini: $tarikhKemaskini",
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        },
=======
                ElevatedButton.icon(
                  icon: const Icon(Icons.image, color: Colors.white),
                  label: const Text("Pilih Gambar", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 135, 172, 79),
                  ),
                  onPressed: () async {
                    final picked = await _picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setStateDialog(() => imageFile = File(picked.path));
                    }
                  },
                ),
                if (imageFile != null)
                  Image.file(imageFile!, height: 120)
                else if (existingImageUrl != null)
                  Image.network(existingImageUrl, height: 120),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Batal"),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 135, 172, 79),
              ),
              child: const Text("Simpan", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                String? imageUrl = existingImageUrl;
                if (imageFile != null) {
                  final ref = FirebaseStorage.instance
                      .ref("surau_sub_entries/${DateTime.now().millisecondsSinceEpoch}.jpg");
                  await ref.putFile(imageFile!);
                  imageUrl = await ref.getDownloadURL();
                }

                if (doc == null) {
                  // Tambah baru
                  await _firestore
                      .collection("surauDetails")
                      .doc("main")
                      .collection("subEntries")
                      .add({
                    "title": titleController.text,
                    "description": descController.text,
                    "imageUrl": imageUrl,
                    "createdAt": DateTime.now().toIso8601String(),
                  });
                } else {
                  // Kemaskini sedia ada
                  await _firestore
                      .collection("surauDetails")
                      .doc("main")
                      .collection("subEntries")
                      .doc(doc.id)
                      .update({
                    "title": titleController.text,
                    "description": descController.text,
                    "imageUrl": imageUrl,
                    "updatedAt": DateTime.now().toIso8601String(),
                  });
                }

                await _firestore.collection("surauDetails").doc("main").update({
                  "tarikhKemaskini": DateTime.now().toIso8601String(),
                });

                if (mounted) Navigator.pop(ctx);
              },
            ),
          ],
        ),
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
      ),
    );
  }
}

<<<<<<< HEAD
// ---------------- Surau Form Page ----------------

class SurauFormPage extends StatefulWidget {
  final String ajkId;

  const SurauFormPage({super.key, required this.ajkId});

  @override
  State<SurauFormPage> createState() => _SurauFormPageState();
}

class _SurauFormPageState extends State<SurauFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _lokasiController = TextEditingController();
  final TextEditingController _kapasitiController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  final CollectionReference surauCollection =
      FirebaseFirestore.instance.collection('suraus');

  @override
  void initState() {
    super.initState();
    // Load existing data if exists
    surauCollection.where('ajkId', isEqualTo: widget.ajkId).limit(1).get().then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data() as Map<String, dynamic>;
        _namaController.text = data['namaSurau'] ?? '';
        _lokasiController.text = data['lokasi'] ?? '';
        _kapasitiController.text = (data['kapasiti'] ?? '').toString();
        _imageController.text = data['imageUrl'] ?? '';
      }
    });
  }

  void _saveSurau() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'ajkId': widget.ajkId,
        'namaSurau': _namaController.text.trim(),
        'lokasi': _lokasiController.text.trim(),
        'kapasiti': int.tryParse(_kapasitiController.text.trim()) ?? 0,
        'imageUrl': _imageController.text.trim(),
        'tarikhKemaskini': DateTime.now().toIso8601String(),
      };

      final query = await surauCollection.where('ajkId', isEqualTo: widget.ajkId).limit(1).get();

      if (query.docs.isEmpty) {
        // Create new document
        await surauCollection.add(data);
      } else {
        // Update existing document
        await surauCollection.doc(query.docs.first.id).set(data);
      }

      if (mounted) {
        Navigator.pop(context); // Go back to details page
      }
    }
=======
  // 🧱 Main Info Card
  Widget buildMainCard(String title, String value, String fieldKey) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 135, 172, 79), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))
        ],
      ),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 135, 172, 79)),
          onPressed: () => _editField(title, value, fieldKey),
        ),
      ),
    );
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
  }

  // 🧱 Sub Info Card
  Widget buildSubCard(DocumentSnapshot doc) {
    final subData = doc.data()! as Map<String, dynamic>;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color.fromARGB(255, 135, 172, 79), width: 1.5),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(1, 2))
        ],
      ),
      child: ListTile(
        title: Text(subData["title"] ?? "",
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subData["description"] != null)
              Text(subData["description"]),
            if (subData["imageUrl"] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(subData["imageUrl"], height: 120),
              ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Color.fromARGB(255, 135, 172, 79)),
          onPressed: () => _editSubEntry(doc: doc),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      appBar: AppBar(
        title: const Text('Tambah / Kemaskini Surau'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Surau'),
                validator: (value) => value!.isEmpty ? 'Sila isi nama surau' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lokasiController,
                decoration: const InputDecoration(labelText: 'Lokasi'),
                validator: (value) => value!.isEmpty ? 'Sila isi lokasi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _kapasitiController,
                decoration: const InputDecoration(labelText: 'Kapasiti'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Sila isi kapasiti' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _imageController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _saveSurau,
                child: const Text('Simpan'),
              ),
            ],
          ),
=======
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Butiran Surau: ${widget.surauName}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.normal),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection("surauDetails").doc("main").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Belum ada maklumat, sila tambah."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final tarikhKemaskini = data["tarikhKemaskini"] != null
              ? "${DateTime.parse(data["tarikhKemaskini"]).day}-${DateTime.parse(data["tarikhKemaskini"]).month}-${DateTime.parse(data["tarikhKemaskini"]).year}"
              : "-";

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (data["imageUrl"] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      Image.network(data["imageUrl"], height: 200, fit: BoxFit.cover),
                ),
              const SizedBox(height: 12),

              buildMainCard("Nama Surau", data["namaSurau"] ?? "-", "namaSurau"),
              buildMainCard("Lokasi", data["lokasi"] ?? "-", "lokasi"),
              buildMainCard("Kapasiti", data["kapasiti"] ?? "-", "kapasiti"),

              StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("surauDetails")
                    .doc("main")
                    .collection("subEntries")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, subSnapshot) {
                  if (!subSnapshot.hasData || subSnapshot.data!.docs.isEmpty) {
                    return const Text("Tiada maklumat tambahan.");
                  }
                  final docs = subSnapshot.data!.docs;
                  return Column(
                    children: docs.map((doc) => buildSubCard(doc)).toList(),
                  );
                },
              ),

              const SizedBox(height: 10),
              Text("Tarikh Kemaskini: $tarikhKemaskini"),
            ],
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 135, 172, 79),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () => _editSubEntry(),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text("Tambah Butiran Baru",
              style: TextStyle(color: Colors.white)),
>>>>>>> 5b04964168c3fb3f63f3bb95b07b16499fe9d350
        ),
      ),
    );
  }
}
