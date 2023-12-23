import 'package:flutter/material.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/screenuser/PemesananScreen.dart';
import 'package:projek/screenuser/RequestRuangan.dart';

import 'package:projek/screenuser/izin_ib.dart';
import 'package:projek/screenuser/izin_ik.dart';
import 'package:projek/screenuser/izin_surat.dart';

class HomeScreenUser extends StatefulWidget {
  const HomeScreenUser({Key? key}) : super(key: key);

  @override
  _HomeScreenUserState createState() => _HomeScreenUserState();
}

class _HomeScreenUserState extends State<HomeScreenUser> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Dasboard',),
        ),backgroundColor: const  Color(0xFF048ABF),
        
      ),
  body: ListView(
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildColoredCard(
            context,
            'Booking Ruangan                                       ',
            Icons.meeting_room,
            Colors.red,
            () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>  RequestRuanganScreen(),
                ),
              );
            },
          ),
          buildColoredCard(
            context,
            'Request Surat                                           ',
            Icons.assignment,
            Colors.blue,
            () {
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>  RequestSuratScreen(),
                ),
              );
            },
          ),
          buildColoredCard(
            context,
            'Request Izin Keluar Kampus                            ',
            Icons.exit_to_app,
            Colors.green,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => RequestIzinKeluarScreen(),
                ),
              );
            },
          ),
          buildColoredCard(
            context,
            'Request IB                                                 ',
            Icons.hotel,
            Colors.orange,
            () {
               Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => RequestIzinBermalamScreen(),
                ),
              );
            },
          ),
          buildColoredCard(
            context,
            'Pembelian Kaos                                           ',
            Icons.add_shopping_cart_rounded,
            Colors.purple,
            () {
             Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) =>KaosPage(),
                ),
              );
            },
          ),
        ],
      ),
    ),
  ],
),

      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Logout'),
              leading: Icon(Icons.login),
              onTap: () {
                // Panggil fungsi logout dan cek apakah berhasil
                logout().then((success) {
                  if (success) {
                    // Jika berhasil, pindahkan ke halaman login
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    );
                  } else {
                    // Jika gagal, tampilkan pesan kesalahan atau ambil tindakan lain
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Logout failed. Please try again.'),
                    ));
                  }
                });
              },
            ),
          ],
        ),
      ),

      
   bottomNavigationBar: BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: _onItemTapped,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.shopping_cart),
      label: 'Keranjang',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.history),
      label: 'history',
    ),
  ],
),

    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Tambahkan logika navigasi sesuai dengan index yang dipilih
    });
  }
Widget buildColoredCard(
  BuildContext context,
  String title,
  IconData iconData, // Ganti dengan tipe IconData untuk ikon
  Color color,
  VoidCallback onPressed,
) {
  return Card(
    margin: const EdgeInsets.all(10),
    color: color,
    child: InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              iconData,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: Theme.of(context).textTheme.headline6?.copyWith(
                    color: Colors.white,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}

}

void main() {
  runApp(MaterialApp(
    home: HomeScreenUser(),
  ));
}
