import 'package:flutter/material.dart';
import 'package:nursurau/pages/admin_ajk/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nursurau/pages/admin_paid/paid.dart';
import 'package:nursurau/pages/users/home_page.dart';
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

      // 👉 Change this to test different UIs
      //home: const HomePage(),
      //home: const HomePage(),
<<<<<<< HEAD
      //home: const LoginPage(),
       home: const AdminPaidPage(),
=======
      home: const LoginPage(),
       //home: const AdminPaidPage(),
>>>>>>> c743db340b0e256ab6a70f72d1cdec4c81e24306
      // home: const AdminAjkLoginPage(),
      // home: const AdminAjkDashboard(),
    );
  }
}
