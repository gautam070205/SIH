import 'dart:convert';

import 'package:attendance/constants.dart';
import 'package:http/http.dart' as http;

class UserHelper {
  static Future<http.Response> signUp(
      {required String emailId,
      required String name,
      required String companyName,
      required String password,
      required String confirmPassword}) async {
    try {
      String url = '$appBaseUrl/auth/register';
      var headers = {'Content-Type': 'application/json'};
      return await http.post(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "name": name,
            "email": emailId,
            "companyName": companyName,
            "password": password,
            "confirmPassword": confirmPassword,
          }));
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> login({
    required String email,
    required String password,
  }) async {
    try {
      String url = '$appBaseUrl/auth/login';
      var headers = {'Content-Type': 'application/json'};
      return await http.post(Uri.parse(url),
          headers: headers,
          body: json.encode({
            'email': email,
            'password': password,
          }));
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> userInfo({
    required String accessToken,
  }) async {
    try {
      String url = '$appBaseUrl/user/me';
      var headers = {
        'Content-Type': 'application/json',
        "Authorization": "Bearer $accessToken",
      };
      return await http.get(
        Uri.parse(url),
        headers: headers,
      );
    } catch (e) {
      rethrow;
    }
  }

  static Future<http.Response> verifyOtp({
    required String email,
    required String pin,
  }) async {
    try {
      String url = '$appBaseUrl/auth/verify-pin';

      var headers = {
        'Content-Type': 'application/json',
      };
      return await http.post(Uri.parse(url),
          headers: headers,
          body: jsonEncode({
            "email": email,
            "pin": pin,
          }));
    } catch (e) {
      rethrow;
    }
  }
}
