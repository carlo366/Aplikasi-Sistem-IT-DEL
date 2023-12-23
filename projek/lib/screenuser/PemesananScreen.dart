import 'package:flutter/material.dart';
import 'package:projek/Services/Pemesanan_service.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/kaos.dart';
import 'package:projek/screenuser/home_screen.dart';

class KaosPage extends StatefulWidget {
  @override
  _KaosPageState createState() => _KaosPageState();
}

class _KaosPageState extends State<KaosPage> {
  List<Kaos> _availableRooms = [];
  Kaos? _selectedRoom;
  int userId = 0;
  bool _loading = false;

  String jumlahPesanan = '1';
  String jenisPembayaran = 'Cash';
  TextEditingController totalHargaController = TextEditingController();

  @override
  Future<void> getKaosList() async {
    try {
      userId = await getUserId();
      ApiResponse response = await getKaos();

      if (response.error == null) {
        setState(() {
          _availableRooms = response.data as List<Kaos>;
          _loading = false;
        });
      } else if (response.error == "eror") {
        logout().then((value) => {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              )
            });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in retrievePosts: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getKaosList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mesan Kaos'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: DropdownButtonFormField<Kaos>(
                    value: _selectedRoom,
                    onChanged: (Kaos? newValue) {
                      setState(() {
                        _selectedRoom = newValue;
                      });
                    },
                    items: _availableRooms.map((Kaos kaos) {
                      return DropdownMenuItem<Kaos>(
                        value: kaos,
                        child: Text(kaos.ukuran ?? ''),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      labelText: 'Select Kaos',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Harga: Rp ${_selectedRoom?.harga ?? 0}'),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Jumlah Pesanan: '),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              jumlahPesanan = value;
                            });
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Jumlah Pesanan',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Jenis Pembayaran: '),
                      SizedBox(
                        width: 10,
                      ),
                      DropdownButton<String>(
                        value: jenisPembayaran,
                        onChanged: (String? newValue) {
                          setState(() {
                            jenisPembayaran = newValue!;
                          });
                        },
                        items: ['Cash', 'Credit Card', 'Transfer Bank']
                            .map((String value) => DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Total Harga: '),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: TextField(
                          controller: totalHargaController,
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            // You can handle the onChanged event if needed
                          },
                          decoration: InputDecoration(
                            labelText: 'Total Harga',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_selectedRoom != null) {
                        int harga = _selectedRoom!.harga ?? 0;
                        int jumlahPesananInt = int.tryParse(jumlahPesanan) ?? 0;
                        int calculatedTotalPrice = harga * jumlahPesananInt;

                        int enteredTotalPrice =
                            int.tryParse(totalHargaController.text) ?? 0;

                        if (calculatedTotalPrice == enteredTotalPrice) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Konfirmasi Pembayaran'),
                                content: Text(
                                    'Anda yakin ingin melakukan pembayaran?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text('Batal'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      // Close the dialog and navigate to the next screen
                                      Navigator.of(context).pop();
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        content: Text('Pembayaran berhasil!'),
                                      ));

                                      // Pindah ke halaman lain (ganti dengan halaman yang diinginkan)
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                            HomeScreenUser(),
                                        ),
                                      );
                                    },
                                    child: Text('Ya'),
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                'Total Harga tidak sesuai dengan perhitungan harga dan jumlah pesanan.'),
                          ));
                        }
                      }
                    },
                    child: Text('Bayar'),
                  ),
                ),
              ],
            ),
    );
  }
}
