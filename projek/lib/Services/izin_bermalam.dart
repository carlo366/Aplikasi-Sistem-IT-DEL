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

Future<ApiResponse> createIzinBermalam(
    String tujuan, String reason, DateTime start_date, DateTime end_date) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    // Validasi waktu untuk permintaan izin bermalam
    if (isInvalidTimeForLeaveRequest(start_date)) {
      apiResponse.error =
          'Izin bermalam hanya dapat diajukan pada hari Jumat setelah jam 17.00 atau pada hari Sabtu antara jam 08.00 - 17.00';
      return apiResponse;
    }
    String token = await getToken();
    final response = await http.post(Uri.parse(baseUrl + 'izinbermalam'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        },
     body: {
          'tujuan': tujuan, // Tambahkan tujuan di sini
          'reason': reason,
          'start_date': start_date.toString(),
          'end_date': end_date.toString(),
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 401:
        apiResponse.error = "error";
        break;
      default:
        apiResponse.error =
            'An unexpected error occurred. Please try again later.';
        break;
    }
  } catch (e) {
    apiResponse.error = 'Server error';
    if (e is SocketException) {
      apiResponse.error = 'No internet connection';
    }
  }
  return apiResponse;
}

Future<ApiResponse> updateIzinBermalam(
    int id, String tujuan, String reason, DateTime start_date, DateTime end_date) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    // Validasi waktu untuk permintaan izin bermalam
    if (isInvalidTimeForLeaveRequest(start_date)) {
      apiResponse.error =
          'Izin bermalam hanya dapat diajukan pada hari Jumat setelah jam 17.00 atau pada hari Sabtu antara jam 08.00 - 17.00';
      return apiResponse;
    }

    String token = await getToken();
    final response = await http.put(
      Uri.parse(baseUrl + 'izinbermalam/$id'), // Use PUT method here
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'tujuan': tujuan, // Tambahkan tujuan di sini
        'reason': reason,
        'start_date': start_date.toIso8601String(),
        'end_date': end_date.toIso8601String(),
      },
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = 'Unauthorized';
        break;
      default:
        apiResponse.error = 'Something went wrong';
        break;
    }
  } catch (e) {
    apiResponse.error = 'Server error: $e';
  }
  return apiResponse;
}


  Future<ApiResponse> getIzinBermalam() async {
    ApiResponse apiResponse = ApiResponse();
    try {
      String token = await getToken();
      final response = await http.get(
        Uri.parse(baseUrl + 'izinbermalam'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Server Response: ${response.body}");

      switch (response.statusCode) {
        case 200:
          List<dynamic> jsonData =
              jsonDecode(response.body)['RequestIzinBermalam'];
          print("JSON Data: $jsonData");

          List<RequestIzinBermalam> izinBermalamList = jsonData
              .map((p) => RequestIzinBermalam.fromJson(p))
              .toList();
          print("Izin Bermalam List: $izinBermalamList");

          apiResponse.data = izinBermalamList;
          break;
        case 401:
          apiResponse.error = "Unauthorized";
          break;
        default:
          apiResponse.error = "Failed to fetch data";
          print("Server Response: ${response.body}");
          break;
      }
    } catch (e) {
      apiResponse.error = 'Server error';
      print("Error in getIzinBermalam: $e");
    }
    return apiResponse;
  }


Future<ApiResponse> DeleteIzinBermalam(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.delete(Uri.parse(baseUrl + 'izinbermalam/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 403:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 401:
        apiResponse.error = "error";
        break;
    }
  } catch (e) {}
  return apiResponse;
}
