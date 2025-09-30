import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase;
import 'package:nursurau/pages/admin_ajk/login_page.dart' show LoginPage;
import 'firebase_options.dart';

// User pages
// import 'pages/user/home_page.dart'; // Example user page
// import 'pages/user/donation_page.dart'; // User donation page

// Admin pejabat
// import 'pages/admin_paid/paid.dart';

// Admin ajk
// import 'pages/admin_ajk/admin_ajk_login.dart';
// import 'pages/admin_ajk/admin_ajk_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // penting untuk async
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // init Firebase
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ✅ Toggle to select which page to run
  // Options: 'user', 'adminAjk', 'adminPejabat'
  final String runPage = 'user';

  @override
  Widget build(BuildContext context) {
    Widget selectedHome;

    if (runPage == 'user') {
      selectedHome = const LoginPage(); // or DonationPage/HomePage for user
    } else if (runPage == 'adminAjk') {
      selectedHome = const AdminAjkDashboard() as Widget;
    } else if (runPage == 'adminPejabat') {
      selectedHome = const AdminPaidPage() as Widget;
    } else {
      selectedHome = const LoginPage(); // fallback
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NurSurau",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),

<<<<<<< HEAD
      // 👉 Change this to test different UIs
      //home: const HomePage(),
      home: const HomePage(),
      //home: const LoginPage(),
      // home: const AdminPaidPage(),
      // home: const LoginPage(),
       //home: const AdminPaidPage(),
=======
      // 👉 Selected page based on toggle
      home: selectedHome,

      // Example of old commented options kept:
      // home: const HomePage(),
      // home: const LoginPage(),
      // home: const AdminPaidPage(),
>>>>>>> 2261b72136d0326c96e4a6aca6287c35867fab14
      // home: const AdminAjkLoginPage(),
      // home: const AdminAjkDashboard(),
    );
  }
}

class AdminPaidPage {
  const AdminPaidPage();
}

class AdminAjkDashboard {
  const AdminAjkDashboard();
}
