import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/Services/izin_keluar.dart';
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

  void _navigateToAddData() async {
    final result = await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FormIzinKeluars(
              title: 'Request Izin Keluar',
            )));

    // Check if data is added successfully, then refresh the list
    if (result != null && result) {
      retrievePosts();
    }
    Navigator.pop(context); // Add this line to pop the current screen
  }

  void deleteIzinKeluar(int id) async {
    try {
      ApiResponse response = await DeleteIzinKeluar(id);

      if (response.error == null) {
        await Future.delayed(Duration(milliseconds: 300));
        // Update the state to trigger a rebuild
        setState(() {
          _izinkeluarlist.removeWhere((item) => item.id == id);
        });
      } else if (response.error == "error") {
        // ... (unchanged)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in deleteIzinKeluar: $e");
    }
  }

  @override
  void initState() {
    // Call retrievePosts to fetch data when the screen is initialized
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Izin Keluar'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddData,
        child: Icon(Icons.add),
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

                // Tentukan warna latar belakang berdasarkan status
                Color backgroundColor = Colors.white;
                if (bookingruangan.status == 'approved') {
                  backgroundColor = Colors.green; // Warna hijau untuk 'approved'
                } else if (bookingruangan.status == 'rejected') {
                  backgroundColor = Colors.red; // Warna merah untuk 'reject'
                }

                return Card(
                  color: backgroundColor, // Terapkan warna latar belakang
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
                        Text('Status: ${bookingruangan.status}'),
                        Text('Start Time: $formattedStartDate'),
                        Text('End Time: $formattedEndDate'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          int index = _izinkeluarlist.indexOf(bookingruangan);
                          RequestIzinKeluar selectedIzinKeluar =
                              _izinkeluarlist[index];

                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => FormIzinKeluars(
                              title: "Edit Izin Keluar",
                              formIzinKeluar: selectedIzinKeluar,
                            ),
                          ));
                        } else if (value == 'cancel') {
                          deleteIzinKeluar(bookingruangan.id);
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        // Filter out 'Edit' and 'Cancel' based on the status
                        List<String> menuItems = ['Edit', 'Cancel'];

                        // Check if the status is 'approved' or 'reject'
                        if (bookingruangan.status == 'approved' ||
                            bookingruangan.status == 'reject') {
                          // If yes, remove 'Edit' and 'Cancel' from the menu
                          menuItems = [];
                        }

                        return menuItems.map((String choice) {
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
