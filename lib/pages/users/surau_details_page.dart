import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nursurau/services/follow_service.dart';

class SurauDetailsPage extends StatefulWidget {
  final String ajkId;
  const SurauDetailsPage({super.key, required this.ajkId});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  bool _isFollowed = false;

  @override
  void initState() {
    super.initState();
    _checkFollowed();
  }

  Future<void> _checkFollowed() async {
    final followed = await FollowService.isFollowedById(widget.ajkId);
    setState(() => _isFollowed = followed);
  }

  Future<void> _toggleFollow() async {
    await FollowService.toggleFollowById(widget.ajkId);
    final followed = await FollowService.isFollowedById(widget.ajkId);

    setState(() => _isFollowed = followed);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(followed ? "Anda kini mengikuti" : "Anda berhenti mengikuti"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: followed ? Colors.green.shade600 : Colors.grey.shade600,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final surauRef = FirebaseFirestore.instance
        .collection('suraus')
        .where('ajkId', isEqualTo: widget.ajkId)
        .limit(1)
        .snapshots();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Maklumat Surau'),
        backgroundColor: const Color.fromARGB(255, 135, 172, 79),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: surauRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          if (snapshot.data!.docs.isEmpty) return const Center(child: Text("Surau tidak ditemui"));

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Surau Banner Image
                Stack(
                  children: [
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        image: data['imageUrl'] != null && (data['imageUrl'] as String).isNotEmpty
                            ? DecorationImage(
                                image: NetworkImage(data['imageUrl']),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: Colors.green.shade200,
                      ),
                      child: data['imageUrl'] == null || (data['imageUrl'] as String).isEmpty
                          ? const Icon(Icons.mosque, size: 100, color: Colors.green)
                          : null,
                    ),
                    // Gradient overlay for text readability
                    Container(
                      height: 220,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                        gradient: LinearGradient(
                          colors: [Colors.black.withOpacity(0.3), Colors.transparent],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    // Surau info
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            data['address'] ?? '',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(data['nazirName'] ?? '', style: const TextStyle(color: Colors.white70)),
                              const SizedBox(width: 12),
                              const Icon(Icons.phone, size: 16, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(data['nazirPhone'] ?? '', style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Follow button
                    Positioned(
                      top: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: _toggleFollow,
                        icon: Icon(_isFollowed ? Icons.check : Icons.add, size: 20),
                        label: Text(_isFollowed ? "Mengikuti" : "Ikut"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowed ? Colors.green.shade600 : Colors.white,
                          foregroundColor: _isFollowed ? Colors.white : Colors.green.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: Colors.green.shade600, width: 1.2),
                          ),
                          elevation: 4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Posting Surau Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Posting Surau",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('ajkId', isEqualTo: widget.ajkId)
                      .snapshots(),
                  builder: (context, postSnap) {
                    if (postSnap.hasError) return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Ralat memuatkan posting.'),
                    );
                    if (!postSnap.hasData) return const Center(child: CircularProgressIndicator());

                    final posts = postSnap.data!.docs;
                    if (posts.isEmpty) return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text("Tiada posting setakat ini"),
                    );

                    return Column(
                      children: posts.map((doc) {
                        final p = doc.data() as Map<String, dynamic>;
                        final ts = p['timestamp'] != null
                            ? (p['timestamp'] as Timestamp).toDate()
                            : null;

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (p['imageUrl'] != null && (p['imageUrl'] as String).isNotEmpty)
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                                  child: Image.network(
                                    p['imageUrl'],
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (p['category'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade200,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          p['category'],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      p['title'] ?? '',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p['description'] ?? '',
                                      style: const TextStyle(fontSize: 14, color: Colors.black87),
                                    ),
                                    const SizedBox(height: 10),
                                    if (ts != null)
                                      Text(
                                        "${ts.day}/${ts.month}/${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}",
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}
