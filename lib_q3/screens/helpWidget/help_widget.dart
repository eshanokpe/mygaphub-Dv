import 'dart:convert';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_input_field.dart';
import '../../widgets/custom_input_field_multistep.dart';
import 'widget/custom_input_field.dart';

class HelpWidget extends StatelessWidget {
  const HelpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 0.h, 16.w, 0),
      child: InkWell(
        child: Text(
          "Help",
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.blackColor,
          ),
        ),
        onTap: () => _showHelpBottomSheet(context),
      ),
    );
  }

  void _showHelpBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
      ),
      builder: (context) => _HelpBottomSheetContent(),
    );
  }
}

class _HelpBottomSheetContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final height = isPortrait ? size.height : size.width;
    final width = isPortrait ? size.width : size.height;

    return Padding(
      padding: EdgeInsets.all(width * 0.03),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBottomSheetHandle(width, context),
          SizedBox(height: height * 0.02),
          Image.asset("assets/icons/sad_heart.png", height: height * 0.12),
          SizedBox(height: height * 0.02),
          _buildHelpDescription(width),
          SizedBox(height: height * 0.02),
          _buildSendMessageButton(context),
          SizedBox(height: height * 0.03),
        ],
      ),
    );
  }

  Widget _buildBottomSheetHandle(double width, context) {
    return Center(
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Divider(
          color: const Color(0xffcdcdcd),
          height: 20,
          thickness: 5,
          indent: width * 0.38,
          endIndent: width * 0.38,
        ),
      ),
    );
  }

  Widget _buildHelpDescription(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      child: Text(
        'We truly regret any inconvenience you may have faced. Kindly provide us with the details of your inquiry, and our support team will get in touch with you promptly.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: AppColors.grayColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSendMessageButton(BuildContext context) {
    return CustomButton(
      text: 'Send us a message',
      icon: Icons.send_sharp,
      iconColor: Colors.white,
      fontSize: 16.sp,
      borderRadius: 30,
      borderColor: Colors.white,
      onPressed: () => navigateWithSlideTransition(
        context: context,
        destinationScreen: const HelpForm(),
        transitionDuration: const Duration(milliseconds: 200),
      ),
      color: AppColors.blackColor,
      textColor: Colors.white,
    );
  }
}

class HelpForm extends StatefulWidget {
  const HelpForm({super.key});

  @override
  State<HelpForm> createState() => _HelpFormState();
}

class _HelpFormState extends State<HelpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();

  String _selectedCurrency = '£ GBP';
  bool _isLoading = false;
  bool _isFormValid = false;
  bool _isPhoneValid = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateFormState);
    _numberController.addListener(_updateFormState);
    _messageController.addListener(_updateFormState);
    _emailController.addListener(_updateFormState);
    _setInitialPhoneNumberAndCursor();
  }

  @override
  void dispose() {
    _nameController.removeListener(_updateFormState);
    _numberController.removeListener(_updateFormState);
    _messageController.removeListener(_updateFormState);
    _emailController.removeListener(_updateFormState);
    _nameController.dispose();
    _numberController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _setInitialPhoneNumberAndCursor() {
    String prefix = currencyToPhonePrefix[_selectedCurrency] ?? "";
    if (prefix.isNotEmpty) {
      _numberController.text = "$prefix ";
      _numberController.selection = TextSelection.fromPosition(
        TextPosition(offset: _numberController.text.length),
      );
    } else {
      _numberController.clear();
    }
  }

  void _updateFormState() {
    setState(() {
      final allFieldsFilled =
          _nameController.text.isNotEmpty &&
          _numberController.text.isNotEmpty &&
          _messageController.text.isNotEmpty &&
          _emailController.text.isNotEmpty;

      final validEmail = _emailController.text.contains('@');
      _isFormValid = allFieldsFilled && validEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final width = isPortrait ? size.width : size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: ListView(
            children: [
              _buildHeaderSection(width),
              const SizedBox(height: 20),
              _buildFormSection(width),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(double width) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enquiry Message',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 28.sp),
        ),
        const SizedBox(height: 10),
        Text(
          'Type your message, and our support team will respond shortly.',
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16.sp,
            color: AppColors.grayColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(double width) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameField(),
          SizedBox(height: 16.h),
          _buildEmailField(),
          SizedBox(height: 16.h),
          _buildPhoneNumberField(),
          SizedBox(height: 16.h),
          _buildMessageField(),
          SizedBox(height: 24.h),
          _buildSubmitButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    return CustomInputField(
      labelText: true,
      label: 'Name',
      controller: _nameController,
      hintText: 'Enter Full Name',
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter your name' : null,
    );
  }

  Widget _buildEmailField() {
    return CustomInputFieldHelpUI(
      labelText: true,
      label: 'Email address',
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      showValidationIcon: true,
      hintText: 'Enter Email Address',
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter your email';
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mobile Number',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
            color: AppColors.blackColor,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              _buildCurrencyDropdown(),
              const SizedBox(width: 8),
              Expanded(child: _buildPhoneInputField()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: DropdownButton<String>(
        value: _selectedCurrency,
        style: TextStyle(
          color: AppColors.blackColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
        items: _buildCurrencyItems(),
        onChanged: (value) {
          if (value != null) {
            setState(() => _selectedCurrency = value);
            _setInitialPhoneNumberAndCursor();
          }
        },
        underline: Container(),
        icon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  List<DropdownMenuItem<String>> _buildCurrencyItems() {
    return currencyList.map((value) {
      return DropdownMenuItem<String>(
        value: value,
        child: Row(
          children: [
            if (currencyFlags.containsKey(value))
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Container(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      currencyFlags[value]!,
                      width: 26,
                      height: 20,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            // Text(value),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildPhoneInputField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: '1234 56789012',
        hintStyle: TextStyle(
          color: AppColors.grayColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          color: AppColors.grayColor,
          fontSize: 16.sp,
          fontWeight: FontWeight.w400,
        ),
        border: InputBorder.none,
        suffixIcon: _isPhoneValid
            ? const Icon(Icons.check_circle_outline, color: Colors.green)
            : null,
      ),
      keyboardType: TextInputType.phone,
      controller: _numberController,
      validator: _validatePhoneNumber,
      onChanged: (value) => _formatAndValidatePhoneNumber(value),
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
  }

  String _formatPhoneNumber(String input) {
    if (input.isEmpty) {
      return ""; // Allow clearing the field
    }

    String currentSelectedPrefix =
        currencyToPhonePrefix[_selectedCurrency] ?? "";
    String effectivePrefix = "";
    String numberInput = input;

    // Determine the effective prefix and the part of the input that is the number
    if (currentSelectedPrefix.isNotEmpty) {
      // A currency with a prefix is selected
      String prefixWithSpace = "$currentSelectedPrefix ";

      if (input.startsWith(prefixWithSpace)) {
        effectivePrefix = prefixWithSpace;
        numberInput = input.substring(effectivePrefix.length);
      } else if (input.startsWith(currentSelectedPrefix)) {
        // User typed the prefix, but maybe not the space, or deleted the space
        effectivePrefix = prefixWithSpace; // Enforce the space
        numberInput = input.substring(currentSelectedPrefix.length);
      } else if (!input.startsWith("+")) {
        // Input doesn't start with any "+", and a prefix is selected.
        // Assume the input is the number part, so prepend the selected prefix.
        effectivePrefix = prefixWithSpace;
        numberInput = input; // The whole input is treated as the number part
      } else {
        // Input starts with "+" but it's different from currentSelectedPrefix.
        // Try to parse it as a custom prefix.
        RegExp customPrefixPattern = RegExp(r'^(\+\d{1,4})\s*(.*)');
        Match? match = customPrefixPattern.firstMatch(input);
        if (match != null) {
          effectivePrefix =
              "${match.group(1)!} "; // Recognized custom prefix + space
          numberInput = match.group(2)!;
        } else {
          // Input is just "+" or "+non-digits"
          effectivePrefix = "+ ";
          numberInput = input.substring(1);
        }
      }
    } else {
      // No currency prefix is selected (e.g., "-Select-" or currency without a defined prefix)
      RegExp customPrefixPattern = RegExp(r'^(\+\d{1,4})\s*(.*)');
      Match? match = customPrefixPattern.firstMatch(input);
      if (match != null) {
        effectivePrefix = "${match.group(1)!} ";
        numberInput = match.group(2)!;
      } else if (input.startsWith("+")) {
        // Just "+" or "+non-digits"
        effectivePrefix = "+ ";
        numberInput = input.substring(1);
      } else {
        // No prefix in input, and no selected prefix to apply
        effectivePrefix = "";
        numberInput = input;
      }
    }

    // Format the numberInput part
    String digits = numberInput.replaceAll(
      RegExp(r'[^\d]'),
      '',
    ); // Keep only digits
    String formattedNumberPart = "";

    if (digits.isNotEmpty) {
      if (digits.length <= 4) {
        formattedNumberPart = digits;
      } else {
        // Apply "XXXX XXXXXXXX..." format
        formattedNumberPart =
            '${digits.substring(0, 4)} ${digits.substring(4)}';
      }
    }

    // ensure the output is the prefix *with* the trailing space if the number part is empty.
    if (formattedNumberPart.isEmpty &&
        effectivePrefix.isNotEmpty &&
        input == effectivePrefix.trim()) {
      return effectivePrefix;
    }

    return (effectivePrefix + formattedNumberPart).trimRight();
  }

  Widget _buildMessageField() {
    return CustomInputFieldMultiStep(
      label: 'Message',
      hintText: 'Write your message',
      maxLines: 6,
      controller: _messageController,
      validator: (value) {
        if (value?.trim().isEmpty ?? true) return 'Please enter your message';
        if (value!.trim().length < 10) {
          return 'Message must be at least 10 characters long';
        }
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: 'Submit Message',
      fontSize: 16.sp,
      isLoading: _isLoading,
      borderRadius: 30,
      borderColor: Colors.white,
      onPressed: _isFormValid ? _submitForm : null,
      color: _isFormValid ? AppColors.primaryColor : AppColors.grayColor,
      textColor: Colors.white,
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    FocusScope.of(context).unfocus();

    try {
      final response = await http.post(
        Uri.parse("$baseUrl/enquiry"),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'X-API-KEY': 'pT79hjfC91lG7gViU3tSHixtxlZZfvUBfDFeOFKP',
        },
        body: {
          "name": _nameController.text.trim(),
          "email": _emailController.text.trim(),
          "phone": _numberController.text.trim().replaceAll(
            RegExp(r'[^\d+]'),
            '',
          ),
          "message": _messageController.text.trim(),
        },
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessDialog();
      } else {
        debugPrint("Error: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint("Exception occurred: $e");
    }
  }

  void _showSuccessDialog() {
    showDialog(context: context, builder: (context) => const SuccessDialog());
  }
}

class SuccessDialog extends StatelessWidget {
  const SuccessDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final width = isPortrait ? size.width : size.height;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      contentPadding: EdgeInsets.all(width * 0.05),
      backgroundColor: Colors.white,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDialogHandle(width, context),
          Image.asset("assets/analytic/success_enquiry.png"),
          SizedBox(height: 22.h),
          _buildDialogTextContent(width),
          SizedBox(height: 14.h),
          _buildCloseButton(context),
          SizedBox(height: 5.h),
        ],
      ),
    );
  }

  Widget _buildDialogHandle(double width, context) {
    return Center(
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Divider(
          color: const Color(0xffcdcdcd),
          height: 5,
          thickness: 5,
          indent: width * 0.38,
          endIndent: width * 0.38,
        ),
      ),
    );
  }

  Widget _buildDialogTextContent(double width) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Form Submitted!',
            style: TextStyle(
              color: AppColors.blackColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Our support team will get in touch with you promptly',
            style: TextStyle(
              color: AppColors.grayColor,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return CustomButton(
      text: 'Close',
      fontSize: 16.sp,
      borderRadius: 30,
      borderColor: const Color(0xffC8CECC),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
      },
      color: Colors.white,
      textColor: Colors.black,
    );
  }
}
