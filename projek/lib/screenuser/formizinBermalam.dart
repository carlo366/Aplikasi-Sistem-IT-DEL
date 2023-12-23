import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/auth_services.dart';
import 'package:projek/Services/izin_bermalam.dart';
import 'package:projek/login_screen.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/izin_bermalam.dart';
import 'package:projek/screenuser/izin_ib.dart';

class FormIzinBermalam extends StatefulWidget {
  final RequestIzinBermalam? formIzinBermalam;
  final String? title;

  FormIzinBermalam({this.formIzinBermalam, this.title});
  @override
  _FormIzinBermalamState createState() => _FormIzinBermalamState();
}

class _FormIzinBermalamState extends State<FormIzinBermalam> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _tujuanController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    if (widget.formIzinBermalam != null) {
      final startDate = widget.formIzinBermalam!.startDate;
      final endDate = widget.formIzinBermalam!.endDate;
      final reason = widget.formIzinBermalam!.reason;
      final tujuan = widget.formIzinBermalam!.tujuan;
      _tujuanController.text = tujuan ?? '';
      _reasonController.text = reason ?? '';
      if (startDate != null) {
        _startDateController.text =
            DateFormat("yyyy-MM-dd HH:mm").format(startDate);
      }
      if (endDate != null) {
        _endDateController.text =
            DateFormat("yyyy-MM-dd HH:mm").format(endDate);
      }
    }

    super.initState();
  }

  Future<void> _selectDate(
      BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != controller) {
      if (picked.weekday == DateTime.friday || picked.weekday == DateTime.saturday) {
        _selectTime(context, controller, picked);
      } else {
        // Show alert for invalid date
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Invalid Date'),
              content: Text('Izin bermalam hanya dapat diajukan pada hari Jumat atau Sabtu'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }
Future<void> _selectTime(
    BuildContext context, TextEditingController controller, DateTime pickedDate) async {
  final TimeOfDay? picked = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (picked != null) {
    final DateTime combinedDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, picked.hour, picked.minute);

    if (!_isValidTime(combinedDateTime)) {
      // Show alert for invalid time
      _showInvalidTimeAlert();
      return;
    }

    final formattedDateTime = DateFormat("yyyy-MM-dd HH:mm").format(combinedDateTime);
    controller.text = formattedDateTime;
  }
}



bool _isValidTime(DateTime dateTime) {
  // Validasi waktu untuk permintaan izin bermalam
  if ((dateTime.weekday == DateTime.friday && dateTime.hour >= 17.00) ||
      (dateTime.weekday == DateTime.saturday && (dateTime.hour >= 08.00 || dateTime.hour <= 17.00))) {
    return true; // Return true if the request is within the allowed time
  }
  return false;
}

  void _editIzinBermalam(int id) async {
    DateTime startDate = DateTime.parse(_startDateController.text);
    DateTime endDate = DateTime.parse(_endDateController.text);

    if (isInvalidTimeForLeaveRequest(startDate)) {
      _showInvalidTimeAlert();
      return;
    }

    ApiResponse response = await updateIzinBermalam(
        id, _tujuanController.text, _reasonController.text, startDate, endDate);
    _handleResponse(response);
  }

  void _createIzinBermalam() async {
    DateTime startDate = DateTime.parse(_startDateController.text);
    DateTime endDate = DateTime.parse(_endDateController.text);

    if (isInvalidTimeForLeaveRequest(startDate)) {
      _showInvalidTimeAlert();
      return;
    }

    ApiResponse response = await createIzinBermalam(
        _tujuanController.text, _reasonController.text, startDate, endDate);
    _handleResponse(response);
  }

  void _handleResponse(ApiResponse response) {
    if (response.error == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => RequestIzinBermalamScreen(),
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  void _showInvalidTimeAlert() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Invalid Time'),
          content: Text('Izin bermalam hanya dapat diajukan pada hari Jumat setelah jam 17.00 atau pada hari Sabtu antara jam 08.00 - 17.00'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
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
        title: Text('${widget.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _tujuanController,
                decoration: InputDecoration(
                  labelText: 'Tujuan',
                ),
              ),
              SizedBox(height: 16.0),

              TextFormField(
                controller: _reasonController,
                decoration: InputDecoration(
                  labelText: 'Reason',
                ),
              ),
              SizedBox(height: 16.0),

              TextFormField(
                controller: _startDateController,
                onTap: () => _selectDate(context, _startDateController),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Start Date',
                ),
              ),
              SizedBox(height: 16.0),

              TextFormField(
                controller: _endDateController,
                onTap: () => _selectDate(context, _endDateController),
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'End Date',
                ),
              ),
              SizedBox(height: 16.0),

              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _loading = !_loading;
                    });
                    if (widget.formIzinBermalam == null) {
                      _createIzinBermalam();
                    } else {
                      _editIzinBermalam(widget.formIzinBermalam!.id ?? 0);
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
