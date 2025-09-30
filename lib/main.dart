import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:nursurau/pages/admin_ajk/login_page.dart' show LoginPage;
<<<<<<< HEAD
import 'package:nursurau/pages/users/home_page.dart' show HomePage;
=======
import 'package:nursurau/pages/users/home_page.dart';
>>>>>>> 9e5e2c5c63933b958b71a620ea140dc7999fe964
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

<<<<<<< HEAD
      // 👉 You switch this manually depending on role/page you want to run:
      home: const LoginPage(),
=======
      // 👉 Change this to test different UIs
      //home: const HomePage(),
      home: const HomePage(),
      //home: const LoginPage(),
      // home: const AdminPaidPage(),
      // home: const LoginPage(),
       //home: const AdminPaidPage(),
      // 👉 Selected page based on toggle
      // home: selectedHome,

      // Example of old commented options kept:
>>>>>>> 9e5e2c5c63933b958b71a620ea140dc7999fe964
      // home: const HomePage(),
      // home: const AdminPaidPage(),
      // home: const AdminAjkLoginPage(),
      // home: const AdminAjkDashboard(),
    );
  }
}
