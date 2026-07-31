import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/spaces.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/utils/extensions.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Feedbacks extends StatefulWidget {
  const Feedbacks({super.key});

  @override
  _FeedbacksState createState() => _FeedbacksState();
}

class _FeedbacksState extends State<Feedbacks> {
  String? subject;

  static const subUnits1 = <String>[
    'Dashboard',
    'SEED',
    'Action Plan',
    'Acquisition',
    'Portfolio',
    'Analytics',
    'Reminder',
    'Suggestions',
  ];
  List? feedbackData;
  DialogBox dialogBox = DialogBox();
  TextEditingController description = TextEditingController();

  @override
  void didChangeDependencies() {
    setState(() => feedbackData = context.watch<Providers>().feedbackData);
    //print('finalGanpListListtt:${supportData}');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    //List supportData = context.watch<Providers>().setSupport;
    // print('supportData:$feedbackData');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Feedback',
          style: TextStyle(fontSize: width * .035, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.height(.01),
          horizontal: context.width(.02),
        ),
        child: ListView(
          children: [
            Text(
              'Please select from the feedback categories below in order to pick a feedback subject. Our team will like to hear what you think about GAPhub. ',
              style: TextStyle(fontSize: context.width(.038)),
              textAlign: TextAlign.center,
            ),
            Hspace(context.height(.05)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Subject",
                style: TextStyle(
                  fontSize: width * .04,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Hspace(context.height(.005)),
            Container(
              padding: EdgeInsets.only(
                left: context.width() * .015,
                right: context.width() * .015,
              ),
              width: context.width(),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(context.width() * .01),
                color: Colors.white,
                border: Border.all(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton(
                  focusColor: Theme.of(context).primaryColor,
                  value: subject,
                  hint: const Text('Select'),
                  items: subUnits1
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: context.width(.035),
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (subval) {
                    setState(() {
                      subject = subval;
                    });
                    // FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ),
            ),
            Hspace(context.height(.03)),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Message",
                style: TextStyle(
                  fontSize: context.width(.04),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Hspace(context.height(.005)),
            TextField(
              maxLines: 5,
              controller: description,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Type your message',
              ),
            ),
            Hspace(context.height(.05)),
            ElevatedButton(
              onPressed: send,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text(
                'Submit',
                style: TextStyle(
                  fontSize: context.width(.04),
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Hspace(context.height(.05)),
            SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: feedbackData!.length, // Check if supportData is null
                itemBuilder: (context, index) {
                  if (feedbackData == null) {
                    // Handle the case when supportData is null
                    return Container(); // or any other appropriate widget
                  }
                  Map<String, dynamic> item = feedbackData![index];

                  // You can customize the item UI based on your requirements.
                  return Container(
                    width: 250,
                    margin: const EdgeInsets.all(10),
                    padding: const EdgeInsets.all(5),
                    child: Card(
                      elevation: 3,
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hspace(context.height(.01)),
                          Text(
                            '${item['user']['surname'] ?? ''} ${item['user']['firstname'] ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: context.width(.040),
                              fontWeight: FontWeight.bold,
                              color: const Color(0xffED3237),
                            ),
                          ),
                          Hspace(context.height(.02)),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${item['user']['email'] ?? ''}',
                              style: TextStyle(
                                fontSize: context.width(.040),
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          Hspace(context.height(.01)),
                          Text(
                            'Subject',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: context.width(.040),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            ' ${item['subject']}',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: context.width(.035)),
                          ),
                          Hspace(context.height(.01)),
                          Text(
                            'Message',
                            style: TextStyle(
                              fontSize: context.width(.040),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              '${item['message']}',
                              style: TextStyle(fontSize: context.width(.035)),
                            ),
                          ),
                          // Add more fields as needed...
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> send() async {
    // Validate input fields
    if (!_validateInputs()) {
      return;
    }

    // Show loading indicator
    await _showLoading();

    Timer? timer;
    try {
      // Set timeout timer
      timer = Timer(const Duration(seconds: 40), () => _handleTimeout());

      // Get authentication token
      final token = await _getToken();
      if (token == null) {
        _handleError('Authentication token not found');
        return;
      }

      // Prepare request body
      final body = _prepareRequestBody();

      // Send feedback
      final response = await _sendFeedback(body, token);

      // Handle response
      await _handleFeedbackResponse(response, timer);
    } on SocketException catch (_) {
      _handleNetworkError(
        'Network connection failed. Please check your internet.',
        timer,
      );
    } on TimeoutException catch (_) {
      _handleTimeout();
    } catch (e) {
      _handleError('An unexpected error occurred: $e', timer);
    }
  }

  /// Validates user inputs
  bool _validateInputs() {
    if (subject == null || description.text.isEmpty) {
      dialogBox.information(
        context,
        'Status',
        'Please select an option for all mandatory fields',
      );
      return false;
    }
    return true;
  }

  /// Shows loading indicator
  Future<void> _showLoading() async {
    await EasyLoading.show(
      status: 'Sending feedback...',
      dismissOnTap: false,
      maskType: EasyLoadingMaskType.black,
    );
  }

  /// Handles timeout scenario
  void _handleTimeout() {
    EasyLoading.dismiss();
    dialogBox.information(
      context,
      'Status',
      'Request timed out. Please try again.',
    );
  }

  /// Retrieves authentication token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  /// Prepares the request body
  Map<String, String> _prepareRequestBody() {
    return {'subject': subject ?? '', 'message': description.text};
  }

  /// Sends feedback to the server
  Future<http.Response> _sendFeedback(
    Map<String, String> body,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/app/feedback');

    return await http
        .post(
          url,
          body: body,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        )
        .timeout(const Duration(seconds: 30));
  }

  /// Handles the feedback response
  Future<void> _handleFeedbackResponse(
    http.Response response,
    Timer? timer,
  ) async {
    print('Feedback response status: ${response.statusCode}');

    if (response.statusCode == 201) {
      await _handleSuccessResponse(response, timer);
    } else if (response.statusCode == 500) {
      await _handleServerError(timer);
    } else {
      _handleValidationError(timer);
    }
  }

  /// Handles successful feedback submission
  Future<void> _handleSuccessResponse(
    http.Response response,
    Timer? timer,
  ) async {
    timer?.cancel();
    await EasyLoading.dismiss();

    final responseBody = jsonDecode(response.body);
    final successMessage =
        responseBody['1'] ?? 'Feedback submitted successfully';

    Fluttertoast.showToast(
      msg: successMessage,
      toastLength: Toast.LENGTH_LONG,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );

    Navigator.pop(context);
  }

  /// Handles server error (500) - fetches updated feedback list
  Future<void> _handleServerError(Timer? timer) async {
    try {
      final supportData = await _fetchSupportData();

      if (supportData != null) {
        context.read<Providers>().setSupport(supportData);

        timer?.cancel();
        await EasyLoading.dismiss();

        // Navigate to feedbacks screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Feedbacks()),
        );

        // Show success toast
        Fluttertoast.showToast(
          msg: 'Submitted successfully',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        _handleError('Failed to load support data', timer);
      }
    } catch (e) {
      _handleError('Error loading support data: $e', timer);
    }
  }

  /// Fetches support data after successful submission
  Future<List?> _fetchSupportData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    if (token == null) return null;

    final url = Uri.parse('$baseUrl/app/support');
    final response = await http
        .get(url, headers: {'Authorization': 'Bearer $token'})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['data']?['feedbacks']?['data'] ?? [];
    }

    return null;
  }

  /// Handles validation errors
  void _handleValidationError(Timer? timer) {
    timer?.cancel();
    EasyLoading.dismiss();

    Fluttertoast.showToast(
      msg: 'Message must be at least 10 characters',
      toastLength: Toast.LENGTH_SHORT,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      gravity: ToastGravity.BOTTOM,
    );
  }

  /// Handles network errors
  void _handleNetworkError(String message, Timer? timer) {
    timer?.cancel();
    EasyLoading.dismiss();

    dialogBox.information(context, 'Network Error', message);
  }

  /// Handles general errors
  void _handleError(String message, [Timer? timer]) {
    timer?.cancel();
    EasyLoading.dismiss();

    dialogBox.information(context, 'Error', message);
  }
}
