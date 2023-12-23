import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/Services/izin_bermalam.dart'; // Sesuaikan dengan nama service untuk izin bermalam
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/izin_bermalam.dart'; // Sesuaikan dengan nama model untuk izin bermalam
import 'package:projek/screenuser/formizinBermalam.dart'; // Sesuaikan dengan nama form untuk izin bermalam

class RequestIzinBermalamScreen extends StatefulWidget {
  @override
  _RequestIzinBermalamScreenState createState() =>
      _RequestIzinBermalamScreenState();
}

class _RequestIzinBermalamScreenState extends State<RequestIzinBermalamScreen> {
  List<dynamic> _izinBermalamList = [];
  int userId = 0;
  bool _loading = true;

  Future<void> retrievePosts() async {
    try {
      userId = await getUserId();
      ApiResponse response = await getIzinBermalam(); // Ganti dengan fungsi untuk mendapatkan izin bermalam

      if (response.error == null) {
        setState(() {
          _izinBermalamList = response.data as List<dynamic>;
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
        builder: (context) => FormIzinBermalam( // Ganti dengan form untuk izin bermalam
              title: 'Request Izin Bermalam',
            )));

    // Check if data is added successfully, then refresh the list
    if (result != null && result) {
      retrievePosts();
    }
    Navigator.pop(context); // Add this line to pop the current screen
  }

  void deleteIzinKeluar(int id) async {
    try {
      ApiResponse response = await DeleteIzinBermalam(id);

      if (response.error == null) {
        await Future.delayed(Duration(milliseconds: 300));
        // Update the state to trigger a rebuild
        setState(() {
          _izinBermalamList.removeWhere((item) => item.id == id);
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
      title: Text('Izin Bermalam'),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: _navigateToAddData,
      child: Icon(Icons.add),
    ),
    body: _loading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _izinBermalamList.length,
            itemBuilder: (BuildContext context, int index) {
              RequestIzinBermalam izinBermalam = _izinBermalamList[index];

              // Format tanggal dan jam menggunakan DateFormat
              
              String formattedStartDate =
                  DateFormat('yyyy-MM-dd HH:mm').format(izinBermalam.startDate);
              String formattedEndDate =
                  DateFormat('yyyy-MM-dd HH:mm').format(izinBermalam.endDate);

              // Tentukan warna latar belakang berdasarkan status
              Color backgroundColor = Colors.white;
              if (izinBermalam.status == 'approved') {
                backgroundColor = Colors.green; // Warna hijau untuk 'approved'
              } else if (izinBermalam.status == 'rejected') {
                backgroundColor = Colors.red; // Warna merah untuk 'rejected'
              }

              return Card(
                color: backgroundColor, // Terapkan warna latar belakang
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'Reason: ${izinBermalam.reason}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tujuan: ${izinBermalam.tujuan}'),
                      Text('Status: ${izinBermalam.status}'),
                      Text('Start Time: $formattedStartDate'),
                      Text('End Time: $formattedEndDate'),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        int index = _izinBermalamList.indexOf(izinBermalam);
                        RequestIzinBermalam selectedIzinBermalam =
                            _izinBermalamList[index];

                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FormIzinBermalam(
                            title: "Edit Izin Bermalam",
                            formIzinBermalam: selectedIzinBermalam,
                          ),
                        ));
                      } else if (value == 'cancel') {
                        deleteIzinKeluar(izinBermalam.id);
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      // Filter out 'Edit' and 'Cancel' based on the status
                      List<String> menuItems = ['Edit', 'Cancel'];

                      // Check if the status is 'approved' or 'rejected'
                      if (izinBermalam.status == 'approved' ||
                          izinBermalam.status == 'rejected') {
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