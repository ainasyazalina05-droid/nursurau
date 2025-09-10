import 'package:flutter/material.dart';

class SurauDetailsPage extends StatefulWidget {
  final String surauName;
  const SurauDetailsPage({super.key, required this.surauName});

  @override
  State<SurauDetailsPage> createState() => _SurauDetailsPageState();
}

class _SurauDetailsPageState extends State<SurauDetailsPage> {
  // Dummy dynamic list (later can be replaced with Firebase data)
  final List<Map<String, String>> posts = [
    {
      "title": "Gotong-Royong Bersih Surau",
      "image": "assets/post1.jpg",
      "description":
          "Semua jemaah dijemput hadir pada 15 Sept untuk aktiviti gotong-royong membersihkan kawasan surau.",
    },
    {
      "title": "Kelas Mengaji Malam Jumaat",
      "image": "assets/post2.jpg",
      "description":
          "Program bacaan Yasin dan tahlil setiap malam Jumaat, selepas solat Isyak berjemaah.",
    },
  ];

  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    const Color deepGreen = Color(0xFF2F5D50);
    const Color cardGreen = Color(0xFF2F7D66);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.surauName),
        backgroundColor: deepGreen,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  isFollowing = !isFollowing;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFollowing
                          ? "You followed this surau!"
                          : "You unfollowed this surau!",
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isFollowing ? Colors.grey[600] : Colors.orangeAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              child: Text(isFollowing ? "Following" : "Follow"),
            ),
          ),
        ],

      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // About Surau
              Container(
                decoration: BoxDecoration(
                  color: cardGreen,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 6),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: deepGreen,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            widget.surauName.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.7,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: Image.asset(
                            'assets/surau.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const _InfoRow(
                        label: 'ALAMAT',
                        value:
                            '1, 1, Jalan Air Manis 7,\nTaman Air Manis, 45200 Sabak Bernam,\nSelangor',
                      ),
                      const SizedBox(height: 10),
                      const _InfoRow(
                        label: 'NO TELEFON',
                        value: '019-208 8891',
                      ),
                      const SizedBox(height: 10),
                      const _InfoRow(
                        label: 'NADZIR',
                        value: 'Haji Abdullah Nasir',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Posts Section
              const Text(
                "Posting",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: deepGreen,
                ),
              ),
              const SizedBox(height: 12),

              ListView.builder(
                shrinkWrap: true, // allow inside scrollview
                physics: const NeverScrollableScrollPhysics(),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return _buildPost(
                    title: post["title"] ?? "",
                    image: post["image"] ?? "",
                    description: post["description"] ?? "",
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPost({
    required String title,
    required String image,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(2, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          // Image
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          // Description
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              description,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            '$label :',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ),
        Expanded(
          flex: 7,
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
