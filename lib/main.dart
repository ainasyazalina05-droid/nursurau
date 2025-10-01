import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:nursurau/pages/admin_ajk/login_page.dart' show LoginPage;
import 'package:nursurau/pages/users/home_page.dart' show HomePage;
import 'firebase_options.dart';

// User pages

// Admin pejabat
//import 'pages/admin_paid/paid.dart';

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

      // 👉 You switch this manually depending on role/page you want to run:
      //home: const LoginPage(),
      // 👉 Change this to test different UIs
      home: const HomePage(),
      //home: const LoginPage(),
       //home: const AdminPaidPage(),
      // 👉 Selected page based on toggle
      // home: selectedHome,

      // Example of old commented options kept:
      // home: const HomePage(),
      // home: const AdminPaidPage(),
      // home: const AdminAjkLoginPage(),
      // home: const AdminAjkDashboard(),
    );
  }
}
