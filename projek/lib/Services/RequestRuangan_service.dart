import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projek/Services/auth_services.dart';
import 'package:projek/Services/global.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/booking_ruangan.dart';
import 'package:projek/models/ruangan.dart';

Future<ApiResponse> CreateRequestRuangan(
    int roomId, String reason, DateTime startDate, DateTime endDate) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response =
        await http.post(Uri.parse(baseUrl + 'booking-ruangan'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    }, body: {
      'room_id': roomId.toString(),
      'reason': reason,
      'start_time': startDate.toString(),
      'end_time': endDate.toString(),
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body);
        break;
      case 422:
        // ignore: unused_local_variable
        final errors = jsonDecode(response.body)['errors'];
        break;
      case 401:
        apiResponse.error = "error";
        break;
      default:
        apiResponse.error = "error";
        break;
    }
  } catch (e) {
    apiResponse.error = 'server error $e';
  }
  return apiResponse;
}

Future<ApiResponse> getRequestRuangan() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(baseUrl + 'booking-ruangan'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = (jsonDecode(response.body)['bookingData'] as List)
            .map((p) => BookingRuangan.fromJson(p))
            .toList();
        print("JSON Response: ${jsonDecode(response.body)}");

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
    print("Error in getIzinKeluar: $e");
  }
  return apiResponse;
}

Future<ApiResponse> getRuangan() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(baseUrl + 'ruangan'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = (jsonDecode(response.body)['Ruangan'] as List)
            .map((p) => Ruangan.fromJson(p))
            .toList();
        break;
      case 401:
        // Handle unauthorized case
        break;
      default:
        // Handle other error cases
        print("Server Response: ${response.body}");
        break;
    }
  } catch (e) {
    // Handle server error
    print("Error in getRuangan: $e");
  }
  return apiResponse;
}

Future<ApiResponse> updateRequestRuangan(int id, int roomId, String reason,
    DateTime startDate, DateTime endDate) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse(baseUrl + 'izinkeluar/$id'), // Use PUT method here
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'reason': reason,
        'start_date': startDate.toIso8601String(), // Convert DateTime to string
        'end_date': endDate.toIso8601String(), // Convert DateTime to string
      },
    );

    // Handle response based on status code
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

// ignore: non_constant_identifier_names
Future<ApiResponse> DeleteBookingRuangan(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http
        .delete(Uri.parse(baseUrl + 'booking-ruangan/$id'), headers: {
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
  }  catch (e) {}
  return apiResponse;
}

Future<ApiResponse> checkRoomAvailabilityApi(
    int roomId, DateTime startDate, DateTime endDate) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(
      Uri.parse(baseUrl + 'cek-ruangan'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: {
        'room_id': roomId.toString(),
        'start_time': startDate.toIso8601String(),
        'end_time': endDate.toIso8601String(),
      },
    );

    if (response.statusCode == 200) {
      // Parse the response body
      dynamic responseBody = json.decode(response.body);

      if (responseBody.containsKey('message')) {
        // Room is available
        apiResponse.data = true;
      } else if (responseBody.containsKey('error')) {
        // Room is not available
        apiResponse.data = false;
        apiResponse.error = responseBody['error'];
      } else {
        // Handle unexpected response format
        apiResponse.error = 'Invalid response format';
      }
    } else {
      // Handle other HTTP status codes
    }
  } catch (e) {
    // Handle general error
    apiResponse.error = 'Error: $e';
  }

  return apiResponse;
}

Future<ApiResponse> approveBrRequest(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse(baseUrl + 'admin/bookingruangan/approve/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 404:
        apiResponse.error = 'Leave request not found.';
        break;
      case 401:
        apiResponse.error = 'Unauthorized';
        break;
      default:
        apiResponse.error = 'Something went wrong';
        break;
    }
  } catch (e) {
    apiResponse.error = 'Error: $e';
  }
  return apiResponse;
}

Future<ApiResponse> rejectedBrRequest(int id) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.put(
      Uri.parse(baseUrl + 'admin/bookingruangan/rejected/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    switch (response.statusCode) {
      case 200:
        apiResponse.data = jsonDecode(response.body)['message'];
        break;
      case 404:
        apiResponse.error = 'Leave request not found.';
        break;
      case 401:
        apiResponse.error = 'Unauthorized';
        break;
      default:
        apiResponse.error = 'Something went wrong';
        break;
    }
  } catch (e) {
    apiResponse.error = 'Error: $e';
  }
  return apiResponse;
}

Future<ApiResponse> getAdminRequestRuangan() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.get(Uri.parse(baseUrl + 'admin/bookingruangan'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token'
        });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = (jsonDecode(response.body)['bookingData'] as List)
            .map((p) => BookingRuangan.fromJson(p))
            .toList();
        print("JSON Response: ${jsonDecode(response.body)}");
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
    print("Error in getIzinKeluar: $e");
  }
  return apiResponse;
}

Future<ApiResponse> getSemuaAdminRequestRuangan() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http
        .get(Uri.parse(baseUrl + 'admin/bookingruangans'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = (jsonDecode(response.body)['bookingData'] as List)
            .map((p) => BookingRuangan.fromJson(p))
            .toList();
        print("JSON Response: ${jsonDecode(response.body)}");
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
    print("Error in getIzinKeluar: $e");
  }
  return apiResponse;
}
