import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:nursurau/pages/admin_ajk/login_page.dart';
import 'package:nursurau/pages/users/home_page.dart';

import 'firebase_options.dart';

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
      // Switch manually for testing which side to open
     //home: LoginPage(), // Admin AJK login
      home: HomePage(), // User
      // home: const AdminPaidPage(), // Pejabat admin
    );
  }
}
