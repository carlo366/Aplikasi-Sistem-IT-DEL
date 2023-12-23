import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

const String baseUrl = "http://10.0.2.2:8000/api/";

errorSnackBar(BuildContext context,String text){
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    backgroundColor: Colors.red,
   content: Text(text),
   duration: const Duration(seconds: 1),
   )
  
  );
}
