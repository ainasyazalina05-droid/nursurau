import 'package:flutter/material.dart';
import 'view_form.dart'; // import file lain

void main() {
  runApp(const AdminPaidPage());
}

class AdminPaidPage extends StatelessWidget {
  const AdminPaidPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Surau',
      theme: ThemeData(
        primaryColor: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFFAF8F0), // background cream
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          iconTheme: IconThemeData(color: Color(0xFF2E7D32)),
        ),
      ),
      home: OfficerDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class OfficerDashboard extends StatelessWidget {
  final List<Map<String, String>> pendingList = [
    {"surau": "Surau Falakhiah", "ajk": "Ahmad"},
    {"surau": "Surau Nurul Iman Bumi Hijau", "ajk": "Siti"},
    {"surau": "Surau Ar Rahman", "ajk": "Rahman"},
  ];

  OfficerDashboard({super.key}); // not const

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("OFFICER DASHBOARD"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pending Surau AJK Applications",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: pendingList.length,
                itemBuilder: (context, index) {
                  final item = pendingList[index];
                  return Card(
                    color: const Color(0xFFF5F2E7), // warna beige card
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.pending_actions,
                        color: Color(0xFF2E7D32), // hijau icon
                      ),
                      title: Text(
                        item["surau"]!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Text("AJK: ${item["ajk"]}"),
                      trailing: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32), // hijau butang
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "View Form",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ViewForm(
                                surauName: item["surau"]!,
                                ajkName: item["ajk"]!,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}