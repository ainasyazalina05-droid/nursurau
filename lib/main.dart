import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // fail yang baru generate

// User pages
import 'pages/users/home_page.dart';

// Admin pejabat
//import 'pages/admin_pejabat/admin_pejabat_page.dart';

// Admin ajk
//import 'pages/admin_ajk/admin_ajk_login.dart';
//import 'pages/admin_ajk/admin_ajk_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // penting untuk async
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // init Firebase
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NurSurau",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

      // 👉 Change this to test different UIs
      home: const HomePage(),
      // home: const AdminPejabatPage(),
      // home: const AdminAjkLoginPage(),
      // home: const AdminAjkDashboard(),
    );
  }
}
