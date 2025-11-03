import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nursurau/firebase_options.dart';
import 'package:nursurau/pages/unified_login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SurauWebApp());
}

class SurauWebApp extends StatelessWidget {
  const SurauWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NurSurau - Admin Surau",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const UnifiedLoginPage(),
    );
  }
}
