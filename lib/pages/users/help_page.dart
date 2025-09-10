import 'package:flutter/material.dart';

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
    );
  }
}
