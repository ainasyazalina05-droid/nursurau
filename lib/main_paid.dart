import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nursurau/firebase_options.dart';
import 'package:nursurau/pages/admin_paid/paid.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const PaidWebApp());
}

class PaidWebApp extends StatelessWidget {
  const PaidWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NurSurau - Admin Paid",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const AdminPaidPage(),
    );
  }
}
