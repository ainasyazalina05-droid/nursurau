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

  final Color themeColor = const Color(0xFF87AC4F); // ✅ unified color
  final Color bgColor = const Color(0xFFF4F5F2);

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
          content: Text(
            followed
                ? "Anda kini mengikuti surau ini"
                : "Anda berhenti mengikuti surau ini",
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: followed ? themeColor : Colors.grey.shade700,
        ),
      );
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          color: Colors.black.withOpacity(0.9),
          child: Center(
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 1,
              maxScale: 4,
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final surauRef = FirebaseFirestore.instance
        .collection('suraus')
        .where('ajkId', isEqualTo: widget.ajkId)
        .limit(1)
        .snapshots();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Maklumat Surau'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: themeColor,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: surauRef,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Surau tidak ditemui"));
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Column(
              children: [
                // 🌿 Banner
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (data['imageUrl'] != null &&
                            (data['imageUrl'] as String).isNotEmpty) {
                          _showFullImage(data['imageUrl']);
                        }
                      },
                      child: Container(
                        height: 240,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          image: data['imageUrl'] != null &&
                                  (data['imageUrl'] as String).isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(data['imageUrl']),
                                  fit: BoxFit.cover,
                                )
                              : null,
                          color: themeColor.withOpacity(0.4),
                        ),
                        child: data['imageUrl'] == null ||
                                (data['imageUrl'] as String).isEmpty
                            ? const Center(
                                child: Icon(Icons.mosque,
                                    size: 100, color: Colors.white70),
                              )
                            : null,
                      ),
                    ),
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.5),
                            Colors.transparent
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(1, 1),
                                  blurRadius: 4,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.place,
                                  color: Colors.white70, size: 16),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  data['address'] ?? '',
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // ✅ Follow Button with unified color
                    Positioned(
                      top: 16,
                      right: 16,
                      child: ElevatedButton.icon(
                        onPressed: _toggleFollow,
                        icon: Icon(
                          _isFollowed ? Icons.check : Icons.add,
                          size: 18,
                        ),
                        label: Text(_isFollowed ? "Mengikuti" : "Ikut"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _isFollowed ? themeColor : Colors.white,
                          foregroundColor:
                              _isFollowed ? Colors.white : themeColor,
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                            side: BorderSide(color: themeColor, width: 1.2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 💬 Nazir Info Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: themeColor.withOpacity(0.15),
                        child: Icon(Icons.person, color: themeColor, size: 30),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['nazirName'] ?? 'Tidak diketahui',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.phone,
                                    color: Colors.grey, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  data['nazirPhone'] ?? '-',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 🕌 Posting Section
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Posting Surau",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .where('ajkId', isEqualTo: widget.ajkId)
                      .snapshots(),
                  builder: (context, postSnap) {
                    if (postSnap.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Ralat memuatkan posting.'),
                      );
                    }
                    if (!postSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final posts = postSnap.data!.docs;
                    if (posts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text("Tiada posting setakat ini."),
                      );
                    }

                    return Column(
                      children: posts.map((doc) {
                        final p = doc.data() as Map<String, dynamic>;
                        final ts = p['timestamp'] != null
                            ? (p['timestamp'] as Timestamp).toDate()
                            : null;

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (p['imageUrl'] != null &&
                                  (p['imageUrl'] as String).isNotEmpty)
                                GestureDetector(
                                  onTap: () => _showFullImage(p['imageUrl']),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(18)),
                                    child: Image.network(
                                      p['imageUrl'],
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (p['category'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: themeColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
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
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      p['description'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                          height: 1.4),
                                    ),
                                    const SizedBox(height: 10),
                                    if (ts != null)
                                      Row(
                                        children: [
                                          const Icon(Icons.access_time,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${ts.day}/${ts.month}/${ts.year} ${ts.hour}:${ts.minute.toString().padLeft(2, '0')}",
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey),
                                          ),
                                        ],
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
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
