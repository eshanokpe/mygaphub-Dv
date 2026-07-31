import 'dart:async';
import 'dart:convert';

import 'package:GapHub/models/propertyDetailModel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/dialog.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CustomPhoneNumberField extends StatefulWidget {
  final PropertyDetailModel propertyDetail;

  const CustomPhoneNumberField({super.key, required this.propertyDetail});
  @override
  _CustomPhoneNumberFieldState createState() => _CustomPhoneNumberFieldState();
}

class _CustomPhoneNumberFieldState extends State<CustomPhoneNumberField> {
  Country selectedCountry =
      countries.firstWhere((country) => country.code == 'US');
  TextEditingController phoneController = TextEditingController();
  TextEditingController messageController = TextEditingController();

  String? sharePricePerUnit;
  int totalShareUnit = 0;
  @override
  void initState() {
    super.initState();
    sharePricePerUnit = widget.propertyDetail.sharePricePerUnit;
    totalShareUnit = widget.propertyDetail.totalShareUnit;
  }

  void _showCountryPicker() async {
    final selected = await showMenu<Country>(
      context: context,
      position: RelativeRect.fromLTRB(
          0,
          MediaQuery.of(context).size.height - 400,
          0,
          0), // Adjust position if needed
      items: countries.map((Country country) {
        return PopupMenuItem<Country>(
          value: country,
          child: Row(
            children: [
              CachedNetworkImage(
                imageUrl:
                    'https://flagcdn.com/w40/${country.code.toLowerCase()}.png',
                height: 20,
                fit: BoxFit.contain,
                memCacheHeight: 40, // Optimizes memory usage
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.flag, size: 15),
                ),
                errorWidget: (context, url, error) =>
                    const Icon(Icons.public, size: 20),
                fadeInDuration: const Duration(milliseconds: 200),
              ),
              const SizedBox(width: 8.0),
              Text(
                '+${country.dialCode}',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        );
      }).toList(),
    );

    if (selected != null) {
      setState(() {
        selectedCountry = selected;
      });
    }
  }

  int selectedNumber = 1;
  DialogBox dialogBox = DialogBox();
  String? email;
  String? firstName, surName;
  @override
  Widget build(BuildContext context) {
    String phone = context.watch<Providers>().details[3];
    email = context.watch<Providers>().details[2];
    firstName = context.watch<Providers>().details[0];
    surName = context.watch<Providers>().details[1];
    String currency = context.watch<Providers>().snapshotmodel.currency;

    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Row(
            children: [
              // Flag image
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: CachedNetworkImage(
                  imageUrl:
                      'https://flagcdn.com/w40/${selectedCountry.code.toLowerCase()}.png',
                  height: 20.h,
                  width: 30.w,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 30,
                    color: Colors.grey[200],
                    child: const Icon(Icons.flag, size: 20),
                  ),
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.public, size: 20),
                ),
              ),
              // Custom Dropdown Button
              InkWell(
                onTap: _showCountryPicker,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  height: 50.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.arrow_drop_down),
                      Text(
                        '+${selectedCountry.dialCode}',
                        style: TextStyle(fontSize: 12.sp),
                      ),
                    ],
                  ),
                ),
              ),
              // Phone Number Field
              Expanded(
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Phone Number',
                      labelStyle: TextStyle(fontSize: 12.sp),
                      hintStyle: TextStyle(fontSize: 12.sp)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height * .02),
        Text('Select Share Unit',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            )),
        SizedBox(height: height * .01),
        Container(
          width: width * .20,
          padding: EdgeInsets.symmetric(horizontal: width * .03),
          decoration: BoxDecoration(
            color: const Color(0xfff5f5f5),
            border: Border.all(color: const Color(0xffEDEDED), width: 1),
            borderRadius: BorderRadius.circular(8.0), // Border radius
          ),
          child: DropdownButton<int>(
            value: selectedNumber,
            onChanged: (int? newValue) {
              setState(() {
                selectedNumber = newValue!;
              });
            },
            items: List.generate(
                    10, (index) => index + 1) // Generates numbers 1 to 10
                .map<DropdownMenuItem<int>>((int value) {
              return DropdownMenuItem<int>(
                value: value,
                child: Text(
                  value.toString(),
                  style: TextStyle(fontSize: 12.sp),
                ),
              );
            }).toList(),
            underline: const SizedBox(), // Remove the underline
            isExpanded: true, // Make dropdown take full width
          ),
        ),
        SizedBox(height: height * .02),
        Text('Your Total Share Price',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            )),
        SizedBox(height: height * .01),
        TextField(
          enabled: false,
          decoration: InputDecoration(
            fillColor: const Color(0xffFAFAFA),
            hintText: '$currency$totalShareUnit'.replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => '${m[1]},',
            ),
            // prefix: Text('${currency}'),
            label: Text('$currency$totalShareUnit'),
            // '$currency$sharePricePerUnit,
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 14.sp,
            ),
            labelStyle: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              color: Colors.black,
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0), // Border radius
            ),
            suffixIcon: const Icon(
              Icons.lock,
              color: Color(0xff808080),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12.0), // Border radius when focused
              borderSide:
                  const BorderSide(color: Color(0xffEEEEEE), width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12.0), // Border radius when enabled
              borderSide:
                  const BorderSide(color: Color(0xffEEEEEE), width: 1.0),
            ),
          ),
        ),
        SizedBox(height: height * .02),
        Text('Message',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            )),
        SizedBox(height: height * .01),
        TextField(
          maxLines: 5,
          controller: messageController,
          decoration: InputDecoration(
            fillColor: const Color(0xffFAFAFA),
            // hintText: 'Enter text here',
            hintText: 'Write your message...',
            hintStyle: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              color: AppColors.grayColor,
              fontSize: 14.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0), // Border radius
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12.0), // Border radius when focused
              borderSide:
                  const BorderSide(color: AppColors.grayColor, width: 2.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(12.0), // Border radius when enabled
              borderSide:
                  const BorderSide(color: AppColors.grayColor, width: 1.3),
            ),
          ),
        ),
        SizedBox(height: height * .03),
        Padding(
          padding: EdgeInsets.only(left: 190.w),
          child: Container(
            alignment: Alignment.center,
            child: CustomButton(
              text: 'Submit Interest',
              fontSize: 14.sp,
              borderRadius: 8,
              iconColor: Colors.white,
              borderColor: Colors.white,
              onPressed: submitPage,
              color: AppColors.primaryColor,
              textColor: Colors.white,
            ),
          ),
        ),
        SizedBox(height: height * .08),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .04),
          child: RichText(
            text: TextSpan(
              text:
                  '“Personal finance is only 20% head knowledge. It’s 80% behavior!” ',
              style: TextStyle(
                fontSize: 14.sp,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: const Color(0xff808080),
                fontFamily: 'Nunito',
              ),
              children: <TextSpan>[
                TextSpan(
                  text: '- Dave Ramsey',
                  style: TextStyle(
                    fontStyle: FontStyle.normal,
                    fontFamily: 'Nunito',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center, // Optional: Align text to center
          ),
        ),
        SizedBox(height: height * .05),
      ],
    );
  }

  Future<void> submitPage() async {
    // Validate required fields
    if (phoneController.text.isEmpty || messageController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please fill all required fields",
        backgroundColor: Colors.red,
        toastLength: Toast.LENGTH_LONG,
      );
      return;
    }

    // Show loading dialog
    dialogBox.waiting(context, "Processing...");

    // Setup timeout timer
    var timer = Timer(const Duration(seconds: 20), () {
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog
      dialogBox.information(
          context, 'Timeout', 'The request took too long. Please try again.');
    });

    try {
      // Prepare request data
      final requestData = {
        'name': '$firstName $surName',
        'email': email!,
        'mobile_number': '${selectedCountry.dialCode}${phoneController.text}',
        'message': messageController.text.trim(),
        'share_unit': selectedNumber.toString(),
        'total_share_price': totalShareUnit.toString(),
      };

      // Get auth token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB') ?? '';

      // Make API call
      const url =
          'https://gappropertyhub.com/wp-json/custom-api/investment-interest-form-share-sale';
      final response = await http
          .post(
            Uri.parse(url),
            headers: {
              "Authorization": 'Bearer $token',
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
            },
            body: requestData,
          )
          .timeout(const Duration(seconds: 15));

      // Cancel timer on successful response
      timer.cancel();
      Navigator.of(context, rootNavigator: true).pop(); // Close dialog

      // Handle response
      if (response.statusCode == 200) {
        _handleSuccessResponse(response.body);
      } else {
        _handleErrorResponse(response.statusCode, response.body);
      }
    } on TimeoutException {
      timer.cancel();
      Navigator.of(context, rootNavigator: true).pop();
      _showToast('Request timed out. Please check your connection.',
          isError: true);
    } on http.ClientException catch (e) {
      timer.cancel();
      Navigator.of(context, rootNavigator: true).pop();
      _showToast('Network error: ${e.message}', isError: true);
    } catch (e) {
      timer.cancel();
      Navigator.of(context, rootNavigator: true).pop();
      _showToast('An unexpected error occurred', isError: true);

      debugPrint('Submit error: $e');
    } finally {
      messageController.clear();
      phoneController.clear();
    }
  }

  void _handleSuccessResponse(String responseBody) {
    debugPrint('API Success: $responseBody');
    _showToast("Submitted successfully!"); // Success
  }

  void _handleErrorResponse(int statusCode, String responseBody) {
    debugPrint('API Error ($statusCode): $responseBody');
    final errorMessage = _parseErrorMessage(responseBody) ??
        'Failed to submit (Error $statusCode)';
    _showToast(errorMessage, isError: true);
  }

  String? _parseErrorMessage(String response) {
    try {
      // Try to parse JSON error message if API returns JSON
      final json = jsonDecode(response);
      return json['message'] ?? json['error']?.toString();
    } catch (e) {
      return response.isNotEmpty ? response : null;
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : const Color(0xff00B050),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

// Usage:
}
