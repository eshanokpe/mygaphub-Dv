import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Update with your color utility file if needed

class PreferencesService {
  // Method to fetch settings (GET)
  Future<Map<String, dynamic>> fetchSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/app/settings"),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return json.decode(
          response.body,
        )['data']; // Parse the data from the response
      } else {
        throw Exception('Failed to load settings');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Method to post settings (POST)
  Future<void> postSettings(Map<String, dynamic> settingsData) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    print("settingsData: $settingsData");
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/app/settings/notifications"),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
          "Content-Type": "application/json",
        },

        body: json.encode(settingsData),
      );
      Map body = jsonDecode(response.body);
      print('Response status: ${response.statusCode}');
      print('Response body: ${body['data']}');
      Fluttertoast.showToast(
        backgroundColor: Colors.black,
        textColor: Colors.white,
        msg: '${body['message']}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to post settings');
      }
    } catch (e) {
      rethrow;
    }
  }
}
