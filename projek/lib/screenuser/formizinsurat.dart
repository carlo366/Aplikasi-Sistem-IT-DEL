import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projek/Services/izin_surat.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/request_surat.dart';



class FormRequestSurats extends StatefulWidget {
  final RequestSurat? formRequestSurat;
  final String? title;

  FormRequestSurats({this.formRequestSurat, this.title});
  @override
  _FormRequestSuratState createState() => _FormRequestSuratState();
}

class _FormRequestSuratState extends State<FormRequestSurats> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _reasonController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    if (widget.formRequestSurat != null) {
      final reason = widget.formRequestSurat!.reason;
      _reasonController.text = reason ?? '';
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

  Future<void> retrievePosts() async {
    // Implement the logic to retrieve posts here
  }

  void _createizinbermalam() async {
    ApiResponse response = await CreateRequestSurat(_reasonController.text);

    if (response.error == null) {
      // Panggil retrievePosts setelah data berhasil ditambahkan
      await retrievePosts();
      Navigator.pop(context);
    } else if (response.error == "error") {
      // Handle unauthorized
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${response.error}'),
      ));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  void _editizinbermalam(int id) async {
    try {
      ApiResponse response =
          await updateRequestSurat(id, _reasonController.text);
      if (response.error == null) {
        Navigator.pop(
            context); // Remove the FormRequestSurats screen from the stack
        await retrievePosts(); // Refresh the data after the update
      } else if (response.error == "error") {
        // Handle unauthorized
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));
        setState(() {
          _loading = !_loading;
        });
      }
    } catch (e) {
      print("Error in _editizinbermalam: $e");
    }
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
              // Reason TextField
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  suffixIcon: Icon(Icons.text_snippet_outlined),
                ),
              ),
              const SizedBox(height: 16.0),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _loading = !_loading;
                    });
                    if (widget.formRequestSurat == null) {
                      _createizinbermalam();
                    } else {
                      _editizinbermalam(widget.formRequestSurat!.id ?? 0);
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
