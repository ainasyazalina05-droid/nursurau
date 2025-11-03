import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:nursurau/firebase_options.dart';
import 'package:nursurau/pages/admin_ajk/login_page.dart';
import 'package:nursurau/pages/admin_paid/login_page.dart';
import 'package:nursurau/pages/unified_login.dart';
import 'package:nursurau/pages/users/notification_service.dart';
//import 'package:nursurau/pages/admin_paid/paid_dashboard.dart';
//import 'package:nursurau/pages/admin_paid/manage_surau_page.dart';
//import 'package:nursurau/pages/admin_paid/paid.dart';
// import 'package:nursurau/pages/admin_paid/paid_dashboard.dart';
// import 'package:nursurau/pages/admin_paid/report_page.dart';
//import 'package:nursurau/pages/users/home_page.dart';

// ✅ Handle background notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background message: ${message.notification?.title}");

  // ✅ show notification even when app is in background
  if (message.notification != null) {
    NotificationService.showNotification(
      message.notification!.title ?? 'Nursurau',
      message.notification!.body ?? 'Anda mempunyai pemberitahuan baru',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Initialize notification service (foreground popups)
  await NotificationService.initialize();

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

      // ✅ Choose the home screen you want to test:
      //home: LoginPage(), // Admin AJK login
       //home: LoginPage(), // Admin AJK login
      // home: const HomePage(), // User
      // home: const AdminPaidPage(), // Pejabat Agama Islam (PAID)
      // home: const AdminReportsPage(), // Example page
    // home: const PaidDashboard(),
      //home: const PaidLoginPage(),
      home: const UnifiedLoginPage(),

      //hosting {
      //  "target": "surau",
      //  "public": "build/web_surau",
      //  "ignore": ["firebase.json", "/.", "/node_modules/*"],
      //  "rewrites": [{"source": "", "destination": "/index.html"}]
      // },

      //hosting {
      //  "target": "surau",
      //  "public": "build/web_surau",
      //  "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      //  "rewrites": [{"source": "**", "destination": "/index.html"}]
      // },

      //{
      //  "target": "paid",
      //  "public": "build/web_paid",
      //  "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
      //  "rewrites": [{"source": "**", "destination": "/index.html"}]
      //}
    );
  }
}
