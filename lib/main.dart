import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:nursurau/pages/admin_ajk/login_page.dart' show LoginPage;
import 'package:nursurau/pages/users/home_page.dart' show HomePage;
import 'firebase_options.dart';

// Admin pejabat
import 'package:nursurau/pages/admin_paid/paid.dart';

// Admin ajk
import 'package:nursurau/pages/admin_ajk/login_page.dart';
import 'package:nursurau/pages/admin_ajk/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
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
      home: const LoginPage(),
      // home: const HomePage(),
      // home: const AdminPaidPage(),
      // home: const AdminAjkLoginPage(),
      // home: const AdminAjkDashboard(),
    );
  }
}
