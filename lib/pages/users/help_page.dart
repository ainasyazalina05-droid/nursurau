import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'home_page.dart';
import 'donations_page.dart';

class HelpPage extends StatefulWidget {
  const HelpPage({super.key});

  @override
  State<HelpPage> createState() => _HelpPageState();
}

class _HelpPageState extends State<HelpPage>
    with SingleTickerProviderStateMixin {
  final List<Item> _items = [
    Item(
      header: '📱 Tutorial Penggunaan',
      body:
          '1. Mulakan Aplikasi\n- Buka NurSurauApp di telefon anda.\n- Pada skrin utama, anda akan nampak penunjuk kiblat dan jadual waktu solat harian. Selain itu, anda boleh melihat surau-surau yang telah mendaftar.\n\n'
          '2. Melihat Pengumuman & Program\n- Tekan surau yang anda pilih untuk membaca maklumat terkini dan aktiviti komuniti.\n\n'
          '3. Membuat Sumbangan\n- Pergi ke menu Sumbangan/Derma.\n- Anda boleh lihat nombor akaun bank atau imbas QR Code untuk membuat bayaran secara online.\n\n'
          '4. Profil & Maklumat Surau\n- Tekan menu Profil Surau untuk lihat nama surau, lokasi, serta nombor telefon Nazir/ahli jawatankuasa.\n\n'
          '5. Notifikasi & Peringatan\n- Aktifkan Notifikasi supaya anda tidak terlepas sebarang pengumuman atau aktiviti baru.\n\n'
          '6. Hubungi Surau\n- Jika ada soalan, pergi ke menu Hubungi Kami untuk mendapatkan nombor telefon atau WhatsApp pihak surau.',
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
          '- Penunjuk kiblat & waktu solat harian.\n- Notifikasi pengumuman surau & program komuniti.\n- Paparan profil surau lengkap.\n- Fungsi derma melalui akaun bank atau QR Code.\n- Sokongan bahasa Melayu.\n- Reka bentuk mesra pengguna & moden.',
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
          'Email: support@nursurau.my\n'
          'Telefon: +6012-3456789\n'
          'Alamat: Politeknik Sultan Idris Shah, Sabak Bernam, Selangor.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Maklumat & Bantuan"),
        backgroundColor: const Color(0xFF808000),
        foregroundColor: Colors.white,
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
              backgroundColor: const Color(0xFFF7F6E7),
              headerBuilder: (BuildContext context, bool isExpanded) {
                return ListTile(
                  leading: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: isExpanded ? 0.5 : 0.0, // rotate arrow
                    child: const Icon(Icons.keyboard_arrow_down,
                        color: Color(0xFF808000)),
                  ),
                  title: Text(
                    item.header,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5320),
                    ),
                  ),
                );
              },
              body: Container(
                width: double.infinity,
                color: const Color(0xFFFDFCF2),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Text(
                  item.body,
                  style: const TextStyle(fontSize: 15, height: 1.6),
                ),
              ),
            );
          }).toList(),
        ),
      ),

      // 📌 Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFFF5E2B8),
        currentIndex: 3,
        selectedItemColor: const Color(0xFF808000),
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
          }
        },
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Notifikasi"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Utama"),
          BottomNavigationBarItem(
              icon: Icon(Icons.attach_money), label: "Donasi"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Info"),
        ],
      ),
    );
  }
}

class Item {
  Item({
    required this.header,
    required this.body,
  });

  final String header;
  final String body;
}
