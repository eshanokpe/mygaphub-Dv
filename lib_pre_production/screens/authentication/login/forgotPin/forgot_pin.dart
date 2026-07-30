import 'package:GapHub/provider/AuthProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/authentication/login/forgot_password/forgotpword.dart';
import 'package:GapHub/screens/helpWidget/help_widget.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:GapHub/utils/colors.dart';

class ForgotPINScreen extends StatefulWidget {
  const ForgotPINScreen({super.key});

  @override
  State<ForgotPINScreen> createState() => _ForgotPINScreenState();
}

class _ForgotPINScreenState extends State<ForgotPINScreen>
    with WidgetsBindingObserver {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _passwordFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isPasswordValid = false;
  bool _hasPasswordError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _passwordController.addListener(_handleTextChange);
    _passwordFocusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetStates();
    });
  }

  void _handleFocusChange() {
    // Re-evaluate validity when focus changes (e.g. keyboard dismissed)
    setState(() {
      _isPasswordValid = _passwordController.text.isNotEmpty;
    });
  }

  // Listen to route changes
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ModalRoute? route = ModalRoute.of(context);
    if (route != null && route.isCurrent) {
      // This is the current route, reset states
      _resetStates();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _passwordController.removeListener(_handleTextChange);
    _passwordFocusNode.removeListener(_handleFocusChange); // ← THIS IS MISSING
    _passwordFocusNode.dispose();
    _passwordController.dispose(); // ← good practice to add this too
    super.dispose();
  }

  void _handleTextChange() {
    setState(() {
      _isPasswordValid = _passwordController.text.isNotEmpty;
      _hasPasswordError =
          _passwordController.text.isNotEmpty &&
          _passwordController.text.length < 6;
    });
  }

  void _resetStates() {
    setState(() {
      // Only reset validity if the field is actually empty
      _isPasswordValid = _passwordController.text.isNotEmpty;
      _hasPasswordError =
          _passwordController.text.isNotEmpty &&
          _passwordController.text.length < 6;
    });

    final authProvider = context.read<AuthProvider>();
    if (authProvider.errorMessage.isNotEmpty) {
      authProvider.clearError();
    }
  }

  void _validateAndSubmit(BuildContext context) {
    if (_formKey.currentState!.validate() && _isPasswordValid) {
      final authProvider = context.read<AuthProvider>();
      final providers = context.read<Providers>();
      final email = providers.details[2];

      authProvider
          .signInPassCode(
            email,
            _passwordController.text.trim(),
            context,
            'dashboard',
          )
          .then((success) {
            if (success) {
              print('success:$success');
            }
          });
    } else {
      setState(() {
        _hasPasswordError =
            _passwordController.text.isNotEmpty &&
            _passwordController.text.length < 6;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final screenHeight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 15.sp,
              color: AppColors.blackColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: const [HelpWidget()],
        ),
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Password",
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 28.sp,
                          ),
                        ),
                        SizedBox(height: screenHeight * .01),
                        Text(
                          "Please provide your account password so we can proceed with resetting your passcode",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                            color: AppColors.grayColor,
                          ),
                        ),
                        SizedBox(height: screenHeight * .03),

                        // Password Field with improved UX
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.blackColor,
                              ),
                            ),
                            SizedBox(height: 6.h),
                            // Remove the Container decoration and use TextFormField's border directly
                            TextFormField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              keyboardType: TextInputType.text,
                              obscureText: _isObscured,

                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 14.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color: AppColors.grayColor.withOpacity(0.5),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color:
                                        (_hasPasswordError ||
                                            authProvider
                                                .errorMessage
                                                .isNotEmpty)
                                        ? Colors.red
                                        : AppColors.grayColor.withOpacity(0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide(
                                    color:
                                        (_hasPasswordError ||
                                            authProvider
                                                .errorMessage
                                                .isNotEmpty)
                                        ? Colors.red
                                        : Colors.black,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1.5,
                                  ),
                                ),
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.grayColor,
                                ),
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: 12.w),
                                  child: IconButton(
                                    icon: Icon(
                                      _isObscured
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: AppColors.grayColor,
                                      size: 20.sp,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscured = !_isObscured;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ],
                        ),

                        if (_hasPasswordError)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              'Password must be at least 6 characters',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),

                        if (authProvider.errorMessage.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 4.h),
                            child: Text(
                              authProvider.errorMessage,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Forgotpword(),
                              ),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Forgotten your password?',
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * .07),

                        // Only show the button when at least one character is entered
                        Visibility(
                          visible: _isPasswordValid,
                          maintainState: true,
                          maintainAnimation: true,
                          maintainSize: true,
                          child: CustomButton(
                            text: 'Continue',
                            fontSize: 16.sp,
                            isLoading: authProvider.isLoading,
                            borderRadius: 30,
                            borderColor: Colors.white,
                            onPressed: (!authProvider.isLoading)
                                ? () => _validateAndSubmit(context)
                                : null,
                            color: !authProvider.isLoading
                                ? AppColors.primaryColor
                                : AppColors.primaryColor.withOpacity(0.5),
                            textColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Custom widget to isolate the visibility toggle from parent GestureDetector
class _VisibilityToggle extends StatelessWidget {
  final bool isObscured;
  final VoidCallback onTap;

  const _VisibilityToggle({required this.isObscured, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque, // This prevents propagation to parent
        child: Icon(
          isObscured ? Icons.visibility_off : Icons.visibility,
          color: AppColors.grayColor,
          size: 20.sp,
        ),
      ),
    );
  }
}
