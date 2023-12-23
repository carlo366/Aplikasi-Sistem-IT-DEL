import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/Services/izin_surat.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/request_surat.dart';
import 'package:projek/screenuser/formizinsurat.dart';

class RequestSuratScreen extends StatefulWidget {
  const RequestSuratScreen({super.key});

  @override
  _RequestSuratScreenState createState() => _RequestSuratScreenState();
}

class BottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavigation({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: selectedIndex,
      selectedItemColor: Colors.blue,
      onTap: onItemTapped,
    );
  }
}

class _RequestSuratScreenState extends State<RequestSuratScreen> {
  List<dynamic> _suratlist = [];
  int userId = 0;
  bool _loading = true;
  int _selectedIndex = 0;

  Future<void> retrievePosts() async {
    try {
      userId = await getUserId();
      ApiResponse response = await getRequestSurat();

      if (response.error == null) {
        setState(() {
          _suratlist = response.data as List<dynamic>;
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

  void _navigateToAddData() {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => FormRequestSurats(
              title: 'Request Surat',
            )));
  }

  void deleteRequestSurat(int id) async {
    try {
      ApiResponse response = await DeleteRequestSurat(id);

      if (response.error == null) {
        await Future.delayed(Duration(milliseconds: 300));
        Navigator.pop(context);
        retrievePosts();
      } else if (response.error == "error") {
        // ... (unchanged)
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in deleteRequestSurat: $e");
    }
  }

  @override
  void initState() {
    // Call retrievePosts to fetch data when the screen is initialized
    retrievePosts();
    super.initState();
  }

  void onViewIzinKeluar(RequestSurat izinKeluar) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Request Surat Details"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Alasan: ${izinKeluar.reason}"),
              Text("Status: ${izinKeluar.status}"),
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Surat'),
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
                label:
                    const Text('Request Surat', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
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
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: _suratlist.map((requestSurat) {
                        return DataRow(
                          color: MaterialStateColor.resolveWith((states) {
                            return _getColorForStatus(
                                requestSurat.status ?? '');
                          }),
                          cells: [
                            DataCell(Text(
                                '${_suratlist.indexOf(requestSurat) + 1}')),
                            DataCell(
                              Container(
                                width: 150,
                                child: Text(
                                  requestSurat.reason,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            DataCell(Text(requestSurat.status)),
                            DataCell(PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'edit') {
                                  int index = _suratlist.indexOf(requestSurat);
                                  RequestSurat selectedRequestSurat =
                                      _suratlist[index];

                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => FormRequestSurats(
                                      title: "Edit Request Surat",
                                      formRequestSurat: selectedRequestSurat,
                                    ),
                                  ));
                                } else if (value == 'cancel') {
                                  deleteRequestSurat(requestSurat.id ?? 0);
                                } else if (value == 'view') {
                                  onViewIzinKeluar(requestSurat);
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                bool canEdit =
                                    (requestSurat.status != 'rejected' &&
                                        requestSurat.status != 'approved');
                                bool canCancel =
                                    (requestSurat.status != 'rejected' &&
                                        requestSurat.status != 'approved');

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
                            )),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onBottomNavBarItemTapped,
      ),
    );
  }

  void _onBottomNavBarItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getColorForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'rejected':
        return Colors.red;
      case 'approved':
        return Colors.green;
      default:
        return Colors.yellow;
    }
  }
}
