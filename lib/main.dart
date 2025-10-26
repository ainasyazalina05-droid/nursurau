import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'package:nursurau/pages/admin_ajk/login_page.dart';
import 'package:nursurau/pages/users/home_page.dart';
import 'firebase_options.dart';

/// ✅ Handle background notifications
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔔 Background message: ${message.notification?.title}");
}

/// ✅ Save FCM token for each device (since users don’t log in)
Future<void> _saveUserToken() async {
  final prefs = await SharedPreferences.getInstance();
  String? deviceId = prefs.getString('device_id');

  if (deviceId == null) {
    deviceId = const Uuid().v4();
    await prefs.setString('device_id', deviceId);
  }

  final fcmToken = await FirebaseMessaging.instance.getToken();
  if (fcmToken != null) {
    await FirebaseFirestore.instance.collection('user_tokens').doc(deviceId).set({
      'token': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print("✅ FCM token saved for device: $deviceId");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // ✅ Register background handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Ask for notification permission (iOS & Android 13+)
  NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
    alert: true,
    badge: true,
    sound: true,
  );

  print('🔔 User granted permission: ${settings.authorizationStatus}');

  // ✅ Save FCM token to Firestore
  await _saveUserToken();

  // ✅ Handle foreground messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      print('📩 Foreground message: ${message.notification?.title}');
      // You can show a Snackbar or dialog here if you want
    }
  });

  // ✅ Handle notification tap (when app is in background)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    print('📲 User tapped on notification: ${message.notification?.title}');
    // Optionally navigate to related page here
  });

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
