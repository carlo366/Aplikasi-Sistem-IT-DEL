import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/service_admin/izin_keluar.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/izin_keluar.dart';
import 'package:projek/screenuser/FormIzinKeluars.dart';

class RequestIzinKeluarScreen extends StatefulWidget {
  @override
  _RequestIzinKeluarScreenState createState() =>
      _RequestIzinKeluarScreenState();
}

class _RequestIzinKeluarScreenState extends State<RequestIzinKeluarScreen> {
  List<dynamic> _izinkeluarlist = [];
  int userId = 0;
  bool _loading = true;

  Future<void> retrievePosts() async {
    try {
      userId = await getUserId();
      ApiResponse response = await getIzinKeluar();

      if (response.error == null) {
        setState(() {
          _izinkeluarlist = response.data as List<dynamic>;
          _loading = _loading ? !_loading : _loading;
        });
      } else if (response.error == "error") {
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
    // Call retrievePosts to fetch data when the screen is initialized
    retrievePosts();
    super.initState();
  }


void approveIzinnKeluar(int id) async {
  try {
    ApiResponse response = await approveIzinKeluar(id);

    if (response.error == null) {
      await Future.delayed(Duration(milliseconds: 300));
      // Update the state to trigger a rebuild
      setState(() {
        // Tentukan logika untuk menangani status setelah izin keluar disetujui
        // Misalnya, mengubah status izin keluar menjadi "disetujui"
        RequestIzinKeluar izinKeluar = _izinkeluarlist.firstWhere((item) => item.id == id);
        izinKeluar.status = 'disetujui';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Izin Keluar disetujui.'),
      ));
    } else if (response.error == "error") {
      // ... (unchanged)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    }
  } catch (e) {
    print("Error in approveIzinKeluar: $e");
  }
}


void rejectIzinnKeluar(int id) async {
  try {
    ApiResponse response = await rejectIzinKeluar(id);

    if (response.error == null) {
      await Future.delayed(Duration(milliseconds: 300));
      // Update the state to trigger a rebuild
      setState(() {
        // Tentukan logika untuk menangani status setelah izin keluar disetujui
        // Misalnya, mengubah status izin keluar menjadi "disetujui"
        RequestIzinKeluar izinKeluar = _izinkeluarlist.firstWhere((item) => item.id == id);
        izinKeluar.status = 'disetujui';
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Izin Keluar disetujui.'),
      ));
    } else if (response.error == "error") {
      // ... (unchanged)
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
    }
  } catch (e) {
    print("Error in approveIzinKeluar: $e");
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Izin Keluar'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _izinkeluarlist.length,
              itemBuilder: (BuildContext context, int index) {
                RequestIzinKeluar bookingruangan = _izinkeluarlist[index];

                // Format tanggal dan jam menggunakan DateFormat
                String formattedStartDate = DateFormat('yyyy-MM-dd HH:mm')
                    .format(bookingruangan.startDate);
                String formattedEndDate = DateFormat('yyyy-MM-dd HH:mm')
                    .format(bookingruangan.endDate);

                return Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      'Reason: ${bookingruangan.reason}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                           Text('Name : ${bookingruangan.user.fullname}'),
                        Text('Status: ${bookingruangan.status}'),
                        Text('Start Time: $formattedStartDate'),
                        Text('End Time: $formattedEndDate'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'approve') {
                          // Call the approveIzinKeluar function
                          approveIzinnKeluar(bookingruangan.id);
                        } else if (value == 'reject') {
                          // Call the rejectIzinKeluar function
                           rejectIzinnKeluar(bookingruangan.id);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return ['Approve', 'Reject'].map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice.toLowerCase(),
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
