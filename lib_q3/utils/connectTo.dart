import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/constants.dart';
import 'dart:convert';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:io';

import 'httpErrorDisplay.dart';

/// Makes an HTTP request (GET or POST) with token-based authentication.
///
/// [context]: The BuildContext for showing dialogs and accessing providers.
/// [method]: The HTTP method ("get" or "post").
/// [url]: The endpoint URL to append to the base URL.
/// [data]: The request body for POST requests.
/// [shoot]: An optional callback function to execute on success.
Future<void> connectTo(
  BuildContext context,
  String method,
  String url,
  Map<String, dynamic> data, {
  Function? shoot,
}) async {
  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenDB');
  http.Response response;

  var baseUr = Uri.parse("$baseUrl/app/portfolio/information");
  dialogBox.waiting(context, 'Loading'); // Ensure dialogBox is defined

  try {
    switch (method.toLowerCase()) {
      case "post":
        response = await http.post(
          baseUr,
          body: jsonEncode(data),
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
            "Content-Type": "application/json",
          },
        );
        break;
      case "get":
        response = await http.get(
          baseUr,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        );
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      Navigator.pop(context); // Close the loading dialog
      Provider.of<Providers>(context, listen: false)
          .addHttpData(jsonDecode(response.body));

      if (shoot != null) {
        shoot(); // Execute the callback function
      }
    } else {
      // Handle HTTP errors
      whatError(response.statusCode, context, message: response.body.toString());
    }
  } on TimeoutException catch (_) {
    Navigator.pop(context); // Close the loading dialog
    dialogBox.information(context, 'Error', 'Connection took too long.');
  } on SocketException catch (_) {
    Navigator.pop(context); // Close the loading dialog
    dialogBox.information(
        context, 'Error', 'Please check your internet connection.');
  } catch (error) {
    Navigator.pop(context); // Close the loading dialog
    dialogBox.information(
        context, 'Error', 'Unknown error, please try again later.');
    print('Error: $error');
  }
}