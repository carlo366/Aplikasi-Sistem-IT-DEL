import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:projek/Services/auth_services.dart';
import 'package:projek/Services/global.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/izin_bermalam.dart'; // Pastikan model izin bermalam sudah diimport
bool isInvalidTimeForLeaveRequest(DateTime requestDate) {
  // Validasi waktu untuk permintaan izin bermalam
  if ((requestDate.weekday == DateTime.friday && requestDate.hour < 17) ||
      (requestDate.weekday == DateTime.saturday &&
          (requestDate.hour < 8 || requestDate.hour >= 17))) {
    return true; // Return true if the request is outside the allowed time
  }
  return false;
}


Future<ApiResponse> getIzinBermalam() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(baseUrl + 'izinbermalamall'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data =
            (jsonDecode(response.body)['RequestIzinBermalam'] as List)
                .map((p) => RequestIzinBermalam.fromJson(p))
                .toList();
        break;
      case 401:
        apiResponse.error = "error";
        break;
      default:
        apiResponse.error = "error";
        print("Server Response: ${response.body}");
        break;
    }
  } catch (e) {
    apiResponse.error = 'server error';
    print("Error in getIzinBermalam: $e");
  }
  return apiResponse;
}



Future<ApiResponse> approveIzinBermalam(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse(baseUrl + '$id/approvee'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    switch (response.statusCode) {
      case 200:
        // Handle the success response if needed
        break;
      case 401:
        apiResponse.error = "error";
        break;
      default:
        apiResponse.error = "error";
        // Log the actual server response for debugging
        print("Server Response: ${response.body}");
        break;
    }
  } catch (e) {
    apiResponse.error = 'server error';
    print("Error in approveIzinKeluar: $e");
  }
  return apiResponse;
}

Future<ApiResponse> rejectIzinKeluar(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse(baseUrl + '$id/rejectt'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    switch (response.statusCode) {
      case 200:
        // Handle the success response if needed
        break;
      case 401:
        apiResponse.error = "error";
        break;
      default:
        apiResponse.error = "error";
        // Log the actual server response for debugging
        print("Server Response: ${response.body}");
        break;
    }
  } catch (e) {
    apiResponse.error = 'server error';
    print("Error in rejectIzinKeluar: $e");
  }
  return apiResponse;
}

