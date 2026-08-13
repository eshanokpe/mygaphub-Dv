// lib/services/activity_service.dart
import 'dart:convert';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ActivityService {
  final String url = '$baseUrl/app/activity/app-open';
  
  Future<void> trackAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'timestamp': DateTime.now().toIso8601String(),
          'platform': defaultTargetPlatform.toString(),
          'version': '1.0.0', // Your app version
        }),
      );

      if (response.statusCode == 200) {
        print('App open activity tracked successfully');
        debugPrint('App open activity tracked successfully');
      } else {
        print('Failed to track app open: ${response.statusCode}');
        debugPrint('Failed to track app open: ${response.statusCode}');
      }
    } catch (e) {
      print('Error tracking app open: $e');
      debugPrint('Error tracking app open: $e');
      // Don't throw error - app open tracking shouldn't crash the app
    }
  }
}