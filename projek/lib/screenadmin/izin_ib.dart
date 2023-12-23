import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/izin_bermalam.dart';
import 'package:projek/screenuser/formizinBermalam.dart';
import 'package:projek/service_admin/izin_bermalam.dart';

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
      ApiResponse response = await getIzinBermalam();

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

  @override
  void initState() {
    retrievePosts();
    super.initState();
  }

void approveIzinnKeluar(int id) async {
  try {
    ApiResponse response = await approveIzinBermalam(id);

    if (response.error == null) {
      await Future.delayed(Duration(milliseconds: 300));
      // Update the state to trigger a rebuild
      setState(() {
        // Tentukan logika untuk menangani status setelah izin keluar disetujui
        // Misalnya, mengubah status izin keluar menjadi "disetujui"
        RequestIzinBermalam izinKeluar = _izinBermalamList.firstWhere((item) => item.id == id);
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


void rejectIzinBermalam(int id) async {
  try {
    ApiResponse response = await rejectIzinKeluar(id);

    if (response.error == null) {
      await Future.delayed(Duration(milliseconds: 300));
      // Update the state to trigger a rebuild
      setState(() {
        // Tentukan logika untuk menangani status setelah izin keluar disetujui
        // Misalnya, mengubah status izin keluar menjadi "disetujui"
        RequestIzinBermalam izinKeluar = _izinBermalamList.firstWhere((item) => item.id == id);
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
        title: Text('Izin Bermalam'),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _izinBermalamList.length,
              itemBuilder: (BuildContext context, int index) {
                RequestIzinBermalam izinBermalam = _izinBermalamList[index];

                String formattedStartDate = DateFormat('yyyy-MM-dd HH:mm')
                    .format(izinBermalam.startDate);
                String formattedEndDate = DateFormat('yyyy-MM-dd HH:mm')
                    .format(izinBermalam.endDate);

                return Card(
                  color: Colors.white,
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
                          Text('Name : ${izinBermalam.user.fullname}'),
                          Text('Tujuan: ${izinBermalam.tujuan}'),
                        Text('Status: ${izinBermalam.status}'),
                        Text('Start Time: $formattedStartDate'),
                        Text('End Time: $formattedEndDate'),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'approve') {
                           // Call the approveIzinKeluar function
                          approveIzinBermalam(izinBermalam.id);
                        } else if (value == 'reject') {
                           rejectIzinBermalam(izinBermalam.id);
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
