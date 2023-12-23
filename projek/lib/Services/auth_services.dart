import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:projek/Services/global.dart';
import 'package:projek/models/api_response.dart';
import 'package:projek/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
Future<ApiResponse> login(String email, String password) async {
  // Membuat objek ApiResponse untuk menampung respons dari server
  ApiResponse apiResponse = ApiResponse();

  try {
    // Mengirim permintaan POST ke server dengan menggunakan package http
    final response = await http.post(
      Uri.parse(baseUrl + 'loginUser'),
      headers: {'Accept': 'application/json'},
      body: {'email': email, 'password': password},
    );

    // Memeriksa kode status respons dari server
    switch (response.statusCode) {
      case 200:
        // Jika respons berhasil (status code 200), parsing data pengguna dan menyimpannya ke apiResponse
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        // Jika respons status code 422, menangani error validasi dari server
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 403:
        // Jika respons status code 403, menangani error otorisasi dari server
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        // Menangani respons status code lainnya, jika ada
        apiResponse.error = "error";
        break;
    }
  } catch (e) {
    // Menangani kesalahan yang mungkin terjadi selama proses request
    apiResponse.error = 'server error';
  }

  // Mengembalikan objek ApiResponse setelah diproses
  return apiResponse;
}


Future<ApiResponse> register(String fullname, String ktp, String phone, String nim, String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(Uri.parse(baseUrl + 'registerUser'), headers: {
      'Accept': 'application/json'
    }, body: {
      'fullname': fullname,
      'ktp': ktp,
      'phone': phone,
      'nim': nim,
      'email': email,
      'password': password
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['errors'];
        apiResponse.error = errors[errors.keys.elementAt(0)][0];
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = "error";
        break;
    }
  } catch (e) {
    apiResponse.error = "error";
  }
  return apiResponse;
}


Future<ApiResponse> getUserDetail() async {
  ApiResponse apiResponse = ApiResponse();
  try {
    String token = await getToken();
    final response = await http.post(Uri.parse(baseUrl + 'user'), headers: {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    });

    switch (response.statusCode) {
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 401:
        apiResponse.error = 'unauthorized';
        break;
      default:
        apiResponse.error = "error";
        break;
    }
  } catch (e) {
    apiResponse.error = 'server error';
  }
  return apiResponse;
}

Future<String> getToken() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('token') ?? '';
}

Future<int> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId') ?? 0;
}

Future<bool> logout() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return await pref.remove('token');
}