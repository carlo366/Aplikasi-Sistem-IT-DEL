import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/RequestRuangan_service.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/booking_ruangan.dart';
import 'package:projek/screenuser/FormRequestRuangan.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Add other theme configurations as needed
      ),
      home: RequestRuanganScreen(),
    );
  }
}

class RequestRuanganScreen extends StatefulWidget {
  @override
  _RequestRuanganScreenState createState() => _RequestRuanganScreenState();
}

class _RequestRuanganScreenState extends State<RequestRuanganScreen> {
  List<dynamic> _izinkeluarlist = [];
  int userId = 0;
  bool _loading = true;

  Future<void> retrievePosts() async {
    try {
      userId = await getUserId();
      ApiResponse response = await getRequestRuangan();

      if (response.error == null) {
        setState(() {
          _izinkeluarlist = response.data as List<dynamic>;
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in retrievePosts: $e");
    }
  }

  void _navigateToAddData() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FormRequestRuangans(
              title: 'Request Izin Keluar',
            )));
  }

  void deleteBookingRuangan(int id) async {
    try {
      ApiResponse response = await DeleteBookingRuangan(id);

      if (response.error == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RequestRuanganScreen()),
        );
        retrievePosts();
      } else if (response.error == "eror") {
        // ... (unchanged)
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in deleteIzinKeluar: $e");
    }
  }

  void onViewIzinKeluar(BookingRuangan izinKeluar) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Izin Bermalam Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Alasan: ${izinKeluar.reason}"),
              Text("Status: ${izinKeluar.status}"),
              Text(
                  "Waktu Booking Ruangan: ${DateFormat('yyyy-MM-dd HH:mm').format(izinKeluar.startDate)}"),
              Text(
                  "Waktu Ruangan Selesai: ${DateFormat('yyyy-MM-dd HH:mm').format(izinKeluar.endDate)}"),
              // Add more details as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    retrievePosts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Ruangan'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, top: 16.0),
            child: Align(
              alignment: Alignment.topLeft,
              child: TextButton.icon(
                onPressed: _navigateToAddData,
                icon: const Icon(Icons.add, size: 24),
                label: const Text('Request Ruangan',
                    style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 47, // Adjust the row height as needed
                      columnSpacing: 20,
                      headingRowColor: MaterialStateColor.resolveWith((states) {
                        return Colors.grey[300]!;
                      }),
                      columns: const [
                        DataColumn(label: Text('No')),
                        DataColumn(label: Text('Reason')),
                        DataColumn(label: Text('Ruangan')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Start Time')),
                        DataColumn(label: Text('End Time')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: _izinkeluarlist.map((ruangan) {
                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            return _getColorForStatus(ruangan.status ?? '');
                          }),
                          cells: [
                            DataCell(
                              Text('${_izinkeluarlist.indexOf(ruangan) + 1}'),
                            ),
                            DataCell(
                              Container(
                                width: 100,
                                child: Text(
                                  ruangan.reason,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(
                              Text(ruangan.ruangan_name ?? ''),
                            ),
                            DataCell(
                              Text(ruangan.status ?? ''),
                            ),
                            DataCell(
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(ruangan.startDate),
                              ),
                            ),
                            DataCell(
                              Text(
                                DateFormat('yyyy-MM-dd HH:mm')
                                    .format(ruangan.endDate),
                              ),
                            ),
                            DataCell(
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    // Implement edit functionality if needed
                                  } else if (value == 'cancel') {
                                    deleteBookingRuangan(ruangan.id);
                                  } else if (value == 'view') {
                                    onViewIzinKeluar(ruangan);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  bool canEdit =
                                      (ruangan.status != 'rejected' &&
                                          ruangan.status != 'approved');
                                  bool canCancel =
                                      (ruangan.status != 'rejected' &&
                                          ruangan.status != 'approved');

                                  List<Map<String, dynamic>> menuOptions = [];

                                  if (canEdit) {
                                    menuOptions.add({
                                      'value': 'edit',
                                      'label': 'Edit',
                                      'icon': Icons.edit,
                                    });
                                  }
                                  if (canCancel) {
                                    menuOptions.add({
                                      'value': 'cancel',
                                      'label': 'Cancel',
                                      'icon': Icons.cancel,
                                    });
                                  }

                                  menuOptions.add({
                                    'value': 'view',
                                    'label': 'View',
                                    'icon': Icons.remove_red_eye,
                                  });

                                  return menuOptions
                                      .map((Map<String, dynamic> option) {
                                    return PopupMenuItem<String>(
                                      value: option['value'].toLowerCase(),
                                      child: Row(
                                        children: [
                                          Icon(option['icon']),
                                          const SizedBox(width: 8.0),
                                          Text(option['label']),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'rejected':
        return Colors.red; // Change to the desired color for rejected status
      case 'approved':
        return Colors.green; // Change to the desired color for approved status
      default:
        return Colors.yellow; // Change to the desired color for other statuses
    }
  }
}
