import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostingPage extends StatefulWidget {
  final String ajkId;

  const PostingPage({super.key, required this.ajkId});

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _addPost() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    if (title.isEmpty || desc.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sila isi semua ruangan.")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('posts').add({
        'ajkId': widget.ajkId,
        'title': title,
        'description': desc,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _titleController.clear();
      _descController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Berjaya menambah posting.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ralat semasa menambah posting: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Posting AJK", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: "Tajuk",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: "Penerangan",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 135, 172, 79),
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: _addPost,
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    "Hantar Posting",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          const Text(
            "Senarai Posting",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .where('ajkId', isEqualTo: widget.ajkId)
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("Tiada posting buat masa ini."));
                }

                final posts = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    final data = post.data() as Map<String, dynamic>;

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(data['title'] ?? 'Tiada tajuk'),
                        subtitle: Text(data['description'] ?? 'Tiada penerangan'),
                        trailing: Text(
                          data['timestamp'] != null
                              ? (data['timestamp'] as Timestamp)
                                  .toDate()
                                  .toLocal()
                                  .toString()
                                  .split('.')[0]
                              : '',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
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
