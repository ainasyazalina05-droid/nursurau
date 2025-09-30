import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'home_page.dart';
import 'donations_page.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tutorial / Bantuan"),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text(
              "Tutorial Penggunaan NurSurauApp\n",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              "1. Mulakan Aplikasi\n"
              "- Buka NurSurauApp di telefon anda.\n"
              "- Pada skrin utama, anda akan nampak penunjuk kiblat dan jadual waktu solat harian. "
              "Selain itu, anda boleh melihat surau-surau yang telah mendaftar.\n\n"
              "2. Melihat Pengumuman & Program\n"
              "- Tekan surau yang anda pilih untuk membaca maklumat terkini dan aktiviti komuniti.\n\n"
              "3. Membuat Sumbangan\n"
              "- Pergi ke menu Sumbangan/Derma.\n"
              "- Anda boleh lihat nombor akaun bank atau imbas QR Code untuk membuat bayaran secara online.\n\n"
              "4. Profil & Maklumat Surau\n"
              "- Tekan menu Profil Surau untuk lihat nama surau, lokasi, serta nombor telefon Nazir/ahli jawatankuasa.\n\n"
              "5. Notifikasi & Peringatan\n"
              "- Aktifkan Notifikasi supaya anda tidak terlepas sebarang pengumuman atau aktiviti baru.\n\n"
              "6. Hubungi Surau\n"
              "- Jika ada soalan, pergi ke menu Hubungi Kami untuk mendapatkan nombor telefon atau WhatsApp pihak surau.\n",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),

      // 📌 Bottom Navigation (same as others)
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E2B8),
        currentIndex: 3, // ✅ highlight "Bantuan" here
        selectedItemColor: const Color(0xFF2F5D50),
        unselectedItemColor: Colors.black87,
        onTap: (index) {
          if (index == 0) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const NotificationsPage()));
          } else if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => const HomePage()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const DonationsPage()));
          } else if (index == 3) {
            // Already in HelpPage
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Utama"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Donasi"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Bantuan"),
        ],
      ),
    );
  }
}
