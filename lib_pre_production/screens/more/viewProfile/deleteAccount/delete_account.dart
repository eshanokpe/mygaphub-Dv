import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'delete_request.dart';

class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  _AccountDeletionScreenState createState() => _AccountDeletionScreenState();
}

class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final bool _isLoading = false;
  bool _isTextEntered = false;

  @override
  void initState() {
    super.initState();
    _reasonController.addListener(_onTextChanged);
  }

  // Listener method to detect when user types in the TextField
  void _onTextChanged() {
    setState(() {
      _isTextEntered = _reasonController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _reasonController.removeListener(_onTextChanged); // Clean up listener
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          ),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                Text(
                  "What is the reason for\nwanting to delete your account?",
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Please briefly explain your reason.",
                  style: TextStyle(color: Colors.grey[700], fontSize: 14.sp),
                ),
                SizedBox(height: 20.h),
                Container(
                  constraints: BoxConstraints(minHeight: 150.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xfff7f7f7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "I have a problem with...",
                      hintStyle: TextStyle(
                        color: AppColors.grayColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "30 Characters minimum",
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ),
                SizedBox(height: 200.h),
                if (_isTextEntered) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showHelpBottomSheet(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        backgroundColor: AppColors.primaryColor,
                      ),
                      child: Text(
                        "Send an Enquiry",
                        style: GoogleFonts.nunitoSans(
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        if (_reasonController.text.length < 30) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Please enter at least 30 characters',
                              ),
                            ),
                          );
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DeletionRequest(reason: _reasonController.text),
                          ),
                        );
                      },
                      // onPressed: _isLoading
                      //     ? null
                      //     : () => _submitDeletionRequest(isEnquiry: false),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                        side: const BorderSide(color: AppColors.borderColor),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              "Delete my account",
                              style: GoogleFonts.nunitoSans(
                                fontSize: 16.sp,
                                color: Colors.black,
                              ),
                            ),
                    ),
                  ),
                ],

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
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
