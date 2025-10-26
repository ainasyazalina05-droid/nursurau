import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nursurau/pages/admin_ajk/login_page.dart';
import 'package:nursurau/pages/users/home_page.dart';
import 'firebase_options.dart';

// ✅ Handle background notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background message: ${message.notification?.title}");

  // Optional: Save notification to Firestore here if needed
  // await FirebaseFirestore.instance.collection('notifications').add({
  //   'title': message.notification?.title ?? 'No Title',
  //   'body': message.notification?.body ?? 'No Body',
  //   'timestamp': FieldValue.serverTimestamp(),
  // });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NurSurau",
      theme: ThemeData(primarySwatch: Colors.green),

      // ✅ Keep your existing page setup
      // home: LoginPage(), // Admin AJK login
      home: const HomePage(), // User
      // home: const AdminPaidPage(), // Pejabat admin
    );
  }
}
