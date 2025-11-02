import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'home_page.dart';
import 'donations_page.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage> {
  final Color _primaryColor = const Color(0xFF87AC4F);
  int _currentIndex = 3;

  final List<Item> _items = [
    Item(
      header: '📱 Tutorial Penggunaan',
      body:
          '1. Halaman Utama\n'
          '- Tidak perlu log masuk untuk menggunakan aplikasi.\n'
          '- Di halaman utama, terdapat bar carian untuk mencari surau yang berdaftar.\n'
          '- Bahagian atas memaparkan surau yang telah diikuti, manakala bahagian bawah menunjukkan surau lain yang tersedia.\n'
          '- Di bahagian bawah skrin, terdapat bar navigasi untuk akses pantas ke Notifikasi, Utama, Donasi dan Bantuan.\n\n'
          '2. Melihat Maklumat Surau\n'
          '- Tekan mana-mana surau untuk melihat maklumat lanjut.\n'
          '- Paparan ini menunjukkan status “Ikuti”, gambar, nama, alamat dan nombor telefon Nazir.\n'
          '- Di bawahnya terdapat senarai hantaran (posting) yang dimuat naik oleh pentadbir surau, termasuk nama program, penerangan, gambar/poster dan tarikh.\n\n'
          '3. Notifikasi\n'
          '- Halaman Notifikasi memaparkan pengumuman dan mesej daripada surau yang anda ikuti.\n\n'
          '4. Sumbangan / Derma\n'
          '- Paparan Donasi menunjukkan kempen derma yang sedang dijalankan oleh surau.\n'
          '- Tekan mana-mana kempen untuk melihat butiran penuh seperti nama, penerangan, nombor akaun dan kod QR untuk sumbangan segera.\n\n'
          '5. Bantuan\n'
          '- Untuk panduan lanjut atau maklumat tambahan, tekan menu Bantuan untuk membaca penerangan tentang cara penggunaan NurSurauApp.',
    ),
    Item(
      header: '🎯 Visi & Misi',
      body:
          'Visi: Menjadikan NurSurauApp sebagai platform komuniti Islam yang menyatukan maklumat surau dan aktiviti secara digital.\n\n'
          'Misi:\n- Memudahkan umat Islam mendapatkan maklumat surau berhampiran.\n- Menggalakkan sumbangan dan sokongan kepada komuniti.\n- Memupuk semangat gotong-royong dan ukhuwah Islamiah.',
    ),
    Item(
      header: '✨ Ciri-ciri Aplikasi',
      body:
          '- Carian surau berhampiran dengan maklumat lengkap (nama, alamat, gambar, dan nombor telefon).\n'
          '- Fungsi “Ikuti Surau” untuk menerima notifikasi pengumuman dan program terkini.\n'
          '- Paparan kempen derma aktif lengkap dengan kod QR atau nombor akaun bank.\n'
          '- Antara muka mesra pengguna untuk pentadbir surau mengurus maklumat, aktiviti dan sumbangan.\n'
          '- Reka bentuk moden, mudah digunakan dan menyokong komuniti Islam tempatan.',
    ),
    Item(
      header: '👨‍💻 Dibangunkan Oleh',
      body:
          'Aplikasi ini dibangunkan oleh:\n\n'
          '• Nur Syahirah Binti Mohd Bukhari (17DDT23F1076)\n'
          '• Nur Aina Syazalina Binti Razak (17DDT23F1036)\n'
          '• Rozana Binti Fadlun (17DDT23F1074)\n\n'
          'Dibimbing oleh: En. Azrol Hisham Bin Mohd Adham.',
    ),
    Item(
      header: '📞 Hubungi Kami',
      body:
          'Sekiranya anda menghadapi sebarang masalah atau mempunyai cadangan, sila hubungi kami di:\n\n'
          'Email: nursurau@gmail.com\n'
    ),
  ];

  void _handleNavTap(int index) {
    setState(() => _currentIndex = index);
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NotificationsPage()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DonationsPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF2),
      appBar: AppBar(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        titleTextStyle: const TextStyle(), // Reset inherited bold style
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Maklumat & Bantuan',
            style: TextStyle(
              fontWeight: FontWeight.w500, // Softer than bold
              fontSize: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ExpansionPanelList.radio(
          animationDuration: const Duration(milliseconds: 400),
          expandedHeaderPadding: const EdgeInsets.symmetric(vertical: 8),
          elevation: 1,
          children: _items.map<ExpansionPanelRadio>((Item item) {
            return ExpansionPanelRadio(
              value: item.header,
              backgroundColor: Colors.white,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    item.header,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _primaryColor,
                      fontSize: 16,
                    ),
                  ),
                );
              },
              body: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.body,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
            );
          }).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Colors.grey.shade700,
        type: BottomNavigationBarType.fixed,
        onTap: _handleNavTap,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Utama"),
          BottomNavigationBarItem(
              icon: Icon(Icons.volunteer_activism), label: "Donasi"),
          BottomNavigationBarItem(
              icon: Icon(Icons.help_outline), label: "Bantuan"),
        ],
      ),
    );
  }
}

class Item {
  Item({required this.header, required this.body});
  final String header;
  final String body;
}
