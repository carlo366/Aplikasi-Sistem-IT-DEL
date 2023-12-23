import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek/Services/auth_services.dart';
import 'package:projek/Services/global.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/izin_keluar.dart';

Future<ApiResponse> approveIzinKeluar(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse(baseUrl + '$id/approve'),
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
      Uri.parse(baseUrl + '$id/reject'),
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


Future<ApiResponse> getIzinKeluar() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(baseUrl + 'izinkeluarall'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data =
            (jsonDecode(response.body)['RequestIzinKeluar'] as List)
                .map((p) => RequestIzinKeluar.fromJson(p))
                .toList();
        break;
      case 401:
        apiResponse.error = "erro";
        break;
      default:
        apiResponse.error = "erorre";
        // Log the actual server response for debugging
        print("Server Response: ${response.body}");
        break;
    }
  } catch (e) {
    apiResponse.error = 'server error';
    print("Error in getIzinKeluar: $e");
  }
  return apiResponse;
}