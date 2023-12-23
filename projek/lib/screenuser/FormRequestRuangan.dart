import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/RequestRuangan_service.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/booking_ruangan.dart';
import 'package:projek/models/ruangan.dart';
import 'package:projek/screenuser/RequestRuangan.dart';

class FormRequestRuangans extends StatefulWidget {
  // ignore: non_constant_identifier_names
  final BookingRuangan? FormRequestRuangan;
  final String? title;

  FormRequestRuangans({this.FormRequestRuangan, this.title});
  @override
  _FormRequestRuanganState createState() => _FormRequestRuanganState();
}

class _FormRequestRuanganState extends State<FormRequestRuangans> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _departureDateTimeController =
      TextEditingController();
  final TextEditingController _returnDateTimeController =
      TextEditingController();
  bool _loading = false;

  Ruangan? _selectedRoom;
  List<Ruangan> _availableRooms = [];
  int userId = 0;

  Future<void> getRuangans() async {
    try {
      userId = await getUserId();
      ApiResponse response = await getRuangan();

      if (response.error == null) {
        setState(() {
          _availableRooms = response.data as List<Ruangan>;
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
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
      }
    } catch (e) {
      print("Error in retrievePosts: $e");
    }
  }

  void _editizinbermalam(int id) async {
    DateTime departureDateTime =
        DateTime.parse(_departureDateTimeController.text);
    DateTime returnDateTime = DateTime.parse(_returnDateTimeController.text);
    int selectedRoomId = _selectedRoom?.id ?? 0;
    ApiResponse response = await updateRequestRuangan(id, selectedRoomId,
        _reasonController.text, departureDateTime, returnDateTime);
    if (response.error == null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => RequestRuanganScreen(),
        ),
      );
    } else if (response.error == "error") {
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
      setState(() {
        _loading = !_loading;
      });
    }
  }

  void _createrequestruangan() async {
    DateTime departureDateTime =
        DateTime.parse(_departureDateTimeController.text);
    DateTime returnDateTime = DateTime.parse(_returnDateTimeController.text);
    int selectedRoomId = _selectedRoom?.id ?? 0;

    // Check if the selected room is available
    bool isRoomAvailable = await checkRoomAvailability(
        selectedRoomId, departureDateTime, returnDateTime);

    if (!isRoomAvailable) {
      // Room is not available, show an error message
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Ruangan telah di-booking pada waktu tersebut.'),
      ));
      return;
    }

    ApiResponse response = await CreateRequestRuangan(selectedRoomId,
        _reasonController.text, departureDateTime, returnDateTime);

    if (response.error == null) {
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => RequestRuanganScreen(),
        ),
      );
    } else if (response.error == "error") {
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
      setState(() {
        _loading = !_loading;
      });
    }
  }

  Future<bool> checkRoomAvailability(
      int roomId, DateTime startTime, DateTime endTime) async {
    ApiResponse response =
        await checkRoomAvailabilityApi(roomId, startTime, endTime);

    if (response.error == null) {
      // Room is available if the response data is true
      return response.data as bool? ?? false;
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    // Fetch available rooms
    getRuangan().then((apiResponse) {
      setState(() {
        if (apiResponse.data != null) {
          // Update the state with the fetched ruanganList
          _availableRooms = apiResponse.data as List<Ruangan>? ?? [];
          // Set the initial selected room
          if (_availableRooms.isNotEmpty) {
            _selectedRoom = _availableRooms[0];
          }
        } else {
          // Handle the case when data is null in the ApiResponse
          // You might want to set _availableRooms to an empty list or handle it accordingly.
          _availableRooms = [];
        }
      });
    });

    if (widget.FormRequestRuangan != null) {
      final startDate = widget.FormRequestRuangan!.startDate;
      // ignore: non_constant_identifier_names
      final EndDate = widget.FormRequestRuangan!.endDate;
      final reason = widget.FormRequestRuangan!.reason;
      _reasonController.text = reason ?? '';
      // ignore: unnecessary_null_comparison
      if (startDate != null) {
        _departureDateTimeController.text =
            DateFormat("yyyy-MM-dd HH:mm").format(startDate);
      }
      // ignore: unnecessary_null_comparison
      if (EndDate != null) {
        _returnDateTimeController.text =
            DateFormat("yyyy-MM-dd HH:mm").format(EndDate);
      }
    }
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    // ignore: unrelated_type_equality_checks
    if (picked != null && picked != controller) {
      // ignore: use_build_context_synchronously
      _selectTime(context, controller, picked);
    }
  }

  Future<void> _selectTime(BuildContext context,
      TextEditingController controller, DateTime pickedDate) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final DateTime combinedDateTime = DateTime(pickedDate.year,
          pickedDate.month, pickedDate.day, picked.hour, picked.minute);
      final formattedDateTime =
          DateFormat("yyyy-MM-dd HH:mm").format(combinedDateTime);
      controller.text = formattedDateTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Ruangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Tanggal Masuk (Return Date) DatePicker
              TextFormField(
                controller: _returnDateTimeController,
                onTap: () => _selectDate(context, _returnDateTimeController),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Masuk',
                  suffixIcon: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 16.0),
              // Tanggal Keluar (Departure Date) DatePicker
              TextFormField(
                controller: _departureDateTimeController,
                onTap: () => _selectDate(context, _departureDateTimeController),
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Keluar',
                  suffixIcon: Icon(Icons.date_range),
                ),
              ),
              const SizedBox(height: 16.0),

              DropdownButtonFormField<Ruangan>(
                value: _selectedRoom,
                onChanged: (Ruangan? newValue) {
                  setState(() {
                    _selectedRoom = newValue;
                  });
                },
                items: _availableRooms.map((Ruangan ruangan) {
                  return DropdownMenuItem<Ruangan>(
                    value: ruangan,
                    child: Text(ruangan.NamaRuangan ?? ''),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Select Room',
                ),
              ),

              const SizedBox(height: 16.0),
              // Reason TextField
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                    labelText: 'Reason',
                    suffixIcon: Icon(Icons.text_snippet_outlined),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16.0),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Print the values submitted
                    print('Reason: ${_reasonController.text}');
                    print(
                        'Tanggal Keluar: ${_departureDateTimeController.text}');
                    print('Tanggal Masuk: ${_returnDateTimeController.text}');
                    print(
                        'Selected Room: ${_selectedRoom?.NamaRuangan ?? 'No Room Selected'}');

                    setState(() {
                      _loading = !_loading;
                    });

                    if (widget.FormRequestRuangan == null) {
                      _createrequestruangan();
                    } else {
                      _editizinbermalam(widget.FormRequestRuangan!.id ?? 0);
                    }
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
