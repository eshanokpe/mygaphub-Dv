import 'dart:async';
import 'dart:convert';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/authentication/login/widget/sign_in_row.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/custom_input_field.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'next_register_screen.dart';
import 'verify_number_screen.dart';
 
class Register extends StatefulWidget {
  const Register({super.key});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  String _selectedDialCode = '+44';
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String _selectedCurrency = 'GBP';
  final TextEditingController _numberController = TextEditingController();
  bool _isPhoneValid = false;
  bool _buttonEnabled = false;
  bool _loading = false;
  String _registerMessage = '';
  final FocusNode _phoneFocusNode = FocusNode();

  // Add this flag to track if phone is already verified
  bool _isPhoneAlreadyVerified = false;

  @override
  void initState() {
    super.initState();

    final defaultItem = currencyFlagsRegister.firstWhere(
      (item) => item['currency'] == _selectedCurrency,
      orElse: () => {'dialCode': '+44'},
    );
    _selectedDialCode = defaultItem['dialCode'] ?? '+44';

    _firstNameController.addListener(_updateButtonState);
    _lastNameController.addListener(_updateButtonState);
    _emailController.addListener(_updateButtonState);
    _numberController.addListener(_updateButtonState);

    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Scrollable.ensureVisible(
            context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    });

    const MethodChannel(
      "com.prismcheck.GapHub.goToLogin",
    ).setMethodCallHandler((MethodCall call) async {
      if (call.method == "goToLoginFromVerification") {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          Timer(const Duration(milliseconds: 500), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Login(fromAppLink: true)),
            );
          });
        });
      }
    });
    _setInitialPhoneNumberAndCursor();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      bool allFieldsFilled =
          _firstNameController.text.isNotEmpty &&
          _lastNameController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _numberController.text.isNotEmpty;
      bool validEmail = _emailController.text.contains('@');
      _buttonEnabled = allFieldsFilled && validEmail;
    });
  }

  void _setInitialPhoneNumberAndCursor() {
    String prefix = currencyToPhonePrefix[_selectedCurrency] ?? "";
    if (prefix.isNotEmpty) {
      _numberController.text = "${prefix}12 ";
      _numberController.selection = TextSelection.fromPosition(
        TextPosition(offset: _numberController.text.length),
      );
    } else {
      _numberController.clear();
    }
  }

  void _onNext() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      var firstName = _firstNameController.text.trim();
      var lastName = _lastNameController.text.trim();
      var email = _emailController.text.trim();
      var phoneNumber = _numberController.text.trim();

      await checkEmail(email, firstName, lastName, phoneNumber);
      // Don't proceed if there's a register message error
      if (_registerMessage.isNotEmpty) {
        return; // Stop here, don't navigate
      }

      setState(() {
        _loading = true;
        _isPhoneAlreadyVerified = false; // Reset flag
      });

      // Call the OTP sending function
      bool otpSent = await sendOtp(phoneNumber);
      print("otpSent:$otpSent, alreadyVerified:$_isPhoneAlreadyVerified");

      setState(() {
        _loading = false;
      });

      // Only navigate if OTP was sent successfully and we haven't already navigated
      if (otpSent &&
          mounted &&
          _registerMessage.isEmpty &&
          !_isPhoneAlreadyVerified) {
        navigateWithSlideTransition(
          context: context,
          destinationScreen: VerifyNumberScreen(
            firstName: firstName,
            lastName: lastName,
            email: email,
            phoneNumber: phoneNumber,
            dialCode: _selectedDialCode,
          ),
          transitionDuration: const Duration(milliseconds: 200),
        );
      }
    }
  }

  Future<bool> sendOtp(String phoneNumber) async {
    try {
      var number = _numberController.text.replaceAll(' ', '');
      print('phoneNumber:$_selectedDialCode$number');

      final response = await http.post(
        Uri.parse('$baseUrl/whatsapp/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: jsonEncode({'phone_number': '$_selectedDialCode$number'}),
      );

      print('OTP:${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("OTP sent response: $data");

        // Check if phone number is already verified
        if (data['status'] == true && data['data'] != null) {
          final state = data['data']['state'];
          if (state == 'ALREADY_VERIFIED') {
            // Phone is already verified, skip OTP verification
            final firstName = _firstNameController.text.trim();
            final lastName = _lastNameController.text.trim();
            final email = _emailController.text.trim();
            final phone = _numberController.text.trim();

            // Set flag to prevent double navigation
            _isPhoneAlreadyVerified = true;

            // Navigate directly to NextRegisterScreen
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => NextRegisterScreen(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    phoneNumber: phone,
                    dialCode: _selectedDialCode,
                  ),
                ),
              );
            }
            return true;
          }
        }

        // If not already verified, proceed to OTP verification screen
        return true;
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _registerMessage = data['message'] ?? 'Failed to send OTP';
        });
        print("Failed to send OTP: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("Error sending OTP: $e");
      setState(() {
        _registerMessage = 'Network error. Please try again.';
      });
      return false;
    }
  }

  Future<void> checkEmail(
    String email,
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    setState(() {
      _registerMessage = '';
      _loading = true;
    });

    var timer = Timer(const Duration(seconds: 40), () {
      if (mounted) {
        setState(() {
          _registerMessage = 'Service timed out';
          _loading = false;
        });
      }
    });

    try {
      var url = Uri.parse(
        "$baseUrl/mygap/check/email?email=${Uri.encodeComponent(email)}",
      );
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        if (data['message'] == 'Email is not available') {
          setState(() {
            _registerMessage = 'This email has already been taken';
            _loading = false;
          });
        } else {
          setState(() {
            _registerMessage = ''; // Ensure it's empty on success
            _loading = false;
          });
        }
      } else {
        setState(() {
          _registerMessage = 'Email verification failed';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _registerMessage = 'Email verification error';
        _loading = false;
      });
    } finally {
      timer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.blackColor),
            onPressed: () => Navigator.pop(context),
          ),
          actions: const [HelpWidget()],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.h),
                      Text(
                        'Sign Up',
                        style: GoogleFonts.nunitoSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 28.sp,
                          color: AppColors.blackColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text(
                            'Put in the right details to ',
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: AppColors.grayColor,
                            ),
                          ),
                          Text(
                            'get started',
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomInputField(
                              labelText: true,
                              label: 'First name',
                              controller: _firstNameController,
                              keyboardType: TextInputType.text,
                              obscureText: false,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your first name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            CustomInputField(
                              labelText: true,
                              label: 'Last name',
                              controller: _lastNameController,
                              keyboardType: TextInputType.text,
                              obscureText: false,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your last name';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            CustomInputField(
                              labelText: true,
                              label: 'Email address',
                              keyboardType: TextInputType.emailAddress,
                              controller: _emailController,
                              obscureText: false,
                              validator: (value) {
                                if (value?.isEmpty ?? true) {
                                  return 'Please enter your email';
                                } else if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(value!)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16.h),
                            _buildPhoneNumberField(),
                            SizedBox(height: 8.h),
                            if (_registerMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _registerMessage,
                                        style: GoogleFonts.nunitoSans(
                                          color: AppColors.primaryColor,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            SizedBox(height: 60.h),
                            CustomButton(
                              text: 'Next',
                              fontSize: 16.sp,
                              borderRadius: 30,
                              borderColor: Colors.white,
                              icon: _loading ? null : Icons.arrow_forward_ios,
                              iconColor: Colors.white,
                              isLoading: _loading,
                              onPressed: _buttonEnabled && !_loading
                                  ? _onNext
                                  : null,
                              color: _buttonEnabled && !_loading
                                  ? AppColors.primaryColor
                                  : AppColors.grayColor2,
                              textColor: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
                child: buildSignInRow(
                  context: context,
                  questionText: "Already have an account? ",
                  signInText: "Sign In",
                  questionColor: AppColors.blackColor,
                  signInColor: Theme.of(context).primaryColor,
                  onTap: () {
                    navigateWithSlideTransition(
                      context: context,
                      destinationScreen: Login(),
                      transitionDuration: const Duration(milliseconds: 200),
                    );
                  },
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WhatsApp / Mobile Number',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grayColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildCurrencyDropdown(),
              SizedBox(width: 1.w),
              Expanded(child: _buildPhoneInputField()),
            ],
          ),
        ),
        // if (_numberController.text.isNotEmpty)
        //   Padding(
        //     padding: EdgeInsets.only(top: 4.h),
        //     child: _buildValidationMessage(),
        //   ),
      ],
    );
  }

  Color _getBorderColor() {
    if (_numberController.text.isEmpty) {
      return Colors.grey;
    } else if (_isPhoneValid) {
      return Colors.green; // Green for valid input
    } else {
      return Colors.red; // Red for invalid input
    }
  }

  Widget _buildValidationMessage() {
    if (_isPhoneValid) {
      return Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            'Valid phone number',
            style: GoogleFonts.nunitoSans(
              color: Colors.green,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 16.sp),
          SizedBox(width: 4.w),
          Text(
            'Please enter a valid phone number',
            style: GoogleFonts.nunitoSans(
              color: Colors.red,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      );
    }
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: _selectedCurrency,
        dropdownColor: Colors.white,
        style: GoogleFonts.nunitoSans(
          color: AppColors.blackColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        items: _buildCurrencyItems(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _selectedCurrency = value;
              final selectedItem = currencyFlagsRegister.firstWhere(
                (item) => item['currency'] == value,
                orElse: () => {'dialCode': '+44'},
              );
              _selectedDialCode = selectedItem['dialCode'] ?? '+44';
            });
          }
        },
        underline: Container(),
        icon: const SizedBox.shrink(),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCurrencyItems() {
    return currencyFlagsRegister.map((item) {
      final dialCode = item['dialCode'] ?? '+44';
      return DropdownMenuItem<String>(
        value: item['currency'],
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  item['flag']!,
                  width: 26.w,
                  height: 20.h,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_outlined, color: Colors.grey),
            SizedBox(width: 5.w),
            Text(
              dialCode,
              style: GoogleFonts.nunito(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPhoneInputField() {
    return TextFormField(
      inputFormatters: [LengthLimitingTextInputFormatter(12)],
      decoration: InputDecoration(
        hintText: '123 123456',
        hintStyle: GoogleFonts.nunitoSans(
          color: AppColors.grayColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: GoogleFonts.nunitoSans(
          color: AppColors.grayColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
      ),
      keyboardType: TextInputType.phone,
      controller: _numberController,
      focusNode: _phoneFocusNode,
      validator: _validatePhoneNumber,
      onChanged: (value) {
        _formatAndValidatePhoneNumber(value);
        setState(() {}); // Rebuild to update validation UI
      },
    );
  }

  String? _validatePhoneNumber(String? value) {
    final phone = value?.replaceAll(RegExp(r'[^\d+]'), '') ?? '';
    if (phone.isEmpty) {
      setState(() => _isPhoneValid = false);
      return 'Phone number is required';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(phone)) {
      setState(() => _isPhoneValid = false);
      return 'Enter a valid phone number';
    }
    setState(() => _isPhoneValid = true);
    return null;
  }

  void _formatAndValidatePhoneNumber(String value) {
    final formatted = _formatPhoneNumber(value);
    if (formatted != value) {
      _numberController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    if (_numberController.text.isNotEmpty) {
      _validatePhoneNumber(_numberController.text);
    }
    _updateButtonState();
  }

  String _formatPhoneNumber(String input) {
    if (input.isEmpty) return "";

    String currentSelectedPrefix =
        currencyToPhonePrefix[_selectedCurrency] ?? "";
    String effectivePrefix = "";
    String numberInput = input;

    if (currentSelectedPrefix.isNotEmpty) {
      String prefixWithSpace = "$currentSelectedPrefix ";

      if (input.startsWith(prefixWithSpace)) {
        effectivePrefix = prefixWithSpace;
        numberInput = input.substring(effectivePrefix.length);
      } else if (input.startsWith(currentSelectedPrefix)) {
        effectivePrefix = prefixWithSpace;
        numberInput = input.substring(currentSelectedPrefix.length);
      } else if (!input.startsWith("+")) {
        effectivePrefix = prefixWithSpace;
        numberInput = input;
      } else {
        RegExp customPrefixPattern = RegExp(r'^(\+\d{1,4})\s*(.*)');
        Match? match = customPrefixPattern.firstMatch(input);
        if (match != null) {
          effectivePrefix = "${match.group(1)!} ";
          numberInput = match.group(2)!;
        } else {
          effectivePrefix = "+ ";
          numberInput = input.substring(1);
        }
      }
    } else {
      RegExp customPrefixPattern = RegExp(r'^(\+\d{1,4})\s*(.*)');
      Match? match = customPrefixPattern.firstMatch(input);
      if (match != null) {
        effectivePrefix = "${match.group(1)!} ";
        numberInput = match.group(2)!;
      } else if (input.startsWith("+")) {
        effectivePrefix = "+ ";
        numberInput = input.substring(1);
      } else {
        effectivePrefix = "";
        numberInput = input;
      }
    }

    String digits = numberInput.replaceAll(RegExp(r'[^\d]'), '');
    String formattedNumberPart = "";

    if (digits.isNotEmpty) {
      if (digits.length <= 5) {
        formattedNumberPart = digits;
      } else {
        formattedNumberPart =
            '${digits.substring(0, 5)} ${digits.substring(5)}';
      }
    }

    if (formattedNumberPart.isEmpty &&
        effectivePrefix.isNotEmpty &&
        input == effectivePrefix.trim()) {
      return effectivePrefix;
    }

    return (effectivePrefix + formattedNumberPart).trimRight();
  }
}
