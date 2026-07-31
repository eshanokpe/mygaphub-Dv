import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GapHub/provider/AuthProvider.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/signin_preferences_provider.dart';
import 'package:GapHub/screens/more/viewProfile/view_profile.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../authentication/login/login.dart';
import 'appAppearanceSheet.dart';
import 'avatarPickerButton.dart';
import 'changeBaseCurrency.dart';
import 'changePassword/changepword.dart';
import '../exchangerates.dart';
import 'legalDocumentsApp.dart';
import 'preferences/preferences.dart';
import 'signInPreferences/signInPreferences.dart';
import 'socialMediaBottomSheet.dart';

class Settings extends StatefulWidget {
  final String baseCurrency;

  const Settings({super.key, required this.baseCurrency});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // MARK: - Dependencies
  late final Dio _dio;
  late final AuthProvider _authProvider;

  // MARK: - State Variables
  String? _baseCurrency;
  bool _isLoading = true;
  bool _isSignInPrefsLoading = false;

  // MARK: - Constants
  static const String _defaultAvatarPath = 'assets/settings/avatar.png';
  static const String _defaultAvatarUrl =
      '$imgPrefix//assets/storage/avatar/default.png';
  static const String _maleAvatarUrl =
      '$imgPrefix/assets/storage/avatar/Avatar_Male 1.png';

  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _fetchBaseCurrency();
  }

  // MARK: - Initialization
  void _initializeDependencies() {
    _dio = Dio();
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
  }

  String _buildFullName(Providers provider) {
    return "${provider.details[0]} ${provider.details[1]}";
  }

  // MARK: - Authentication
  Future<void> _logout() async {
    await _authProvider.logout(context);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => Login()),
        (route) => false,
      );
    }
  }

  // MARK: - Image Handling
  String _processImageUrl(String? rawUrl) {
    if (rawUrl == _defaultAvatarUrl || rawUrl == null) {
      return _defaultAvatarPath;
    }

    if (rawUrl.contains('/user/')) {
      return rawUrl.replaceFirst('//app/', '/');
    } else if (rawUrl.contains('/avatar/')) {
      return rawUrl.replaceFirst(
        'app.mygaphub.com/app/assets/storage/app',
        'app/assets/storage/',
      );
    }

    return _defaultAvatarPath;
  }

  Widget _buildProfileImage(String imageUrl) {
    debugPrint('Image URL in settings: $imageUrl');

    if (imageUrl.startsWith('assets/')) {
      return Image.asset(imageUrl, fit: BoxFit.contain);
    } else if (imageUrl == _maleAvatarUrl) {
      return Image.asset(_defaultAvatarPath, fit: BoxFit.contain);
    } else {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
        errorWidget: (_, __, ___) => _buildErrorImage(),
      );
    }
  }

  Widget _buildErrorImage() {
    return Container(
      color: Colors.grey[200],
      child: Icon(Icons.person, size: 50.sp, color: Colors.grey[500]),
    );
  }

  // MARK: - Currency Formatting
  String _formatCurrency(String? currencyString, String? symbol) {
    if (currencyString == null || currencyString.trim().isEmpty) {
      return 'N/A';
    }

    if (currencyString.contains(' ')) {
      return currencyString;
    } else if (symbol != null && symbol.isNotEmpty) {
      return '$currencyString ($symbol)';
    } else {
      return currencyString;
    }
  }

  // MARK: - Data Fetching
  Future<void> _fetchBaseCurrency() async {
    try {
      final url = Uri.parse("$baseUrl/app/settings");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http.get(url, headers: _buildAuthHeaders(token));

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _handleBaseCurrencyResponse(response);
      }
    } catch (e) {
      debugPrint('Error fetching base currency: $e');
    } finally {
      _safeSetState(() => _isLoading = false);
    }
  }

  Map<String, String> _buildAuthHeaders(String? token) {
    return {
      "Authorization": 'Bearer $token',
      "Content-Type": 'application/json',
    };
  }

  Future<void> _handleBaseCurrencyResponse(http.Response response) async {
    final body = jsonDecode(response.body);
    final fetchedCurrency =
        body['data']['preferences']['preferred_currency'] ?? '';

    _safeSetState(() {
      _baseCurrency = fetchedCurrency;
    });

    context.read<Providers>().setBaseCurrency(fetchedCurrency);
  }

  // MARK: - Exchange Rate Navigation
  Future<void> _navigateToExchangeRates() async {
    try {
      _safeSetState(() => _isLoading = true);

      final token = await _getAuthToken();
      if (token == null) {
        _showLoginError();
        return;
      }

      final currencyRates = await _fetchExchangeRates(token);

      if (currencyRates != null && mounted) {
        _pushExchangeRatesPage(currencyRates);
      }
    } on DioException catch (e) {
      debugPrint('Dio Error: ${e.message}');
      _handleDioError(e);
    } on TimeoutException catch (e) {
      debugPrint('Timeout Error: $e');
      _showTimeoutError();
    } catch (e) {
      debugPrint('Unexpected Error: $e');
      _showUnexpectedError();
    } finally {
      _safeSetState(() => _isLoading = false);
    }
  }

  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  Future<Map<String, dynamic>?> _fetchExchangeRates(String token) async {
    const url = "$baseUrl/app/exchange";

    final response = await _dio
        .get(
          url,
          options: Options(
            headers: {
              "Authorization": 'Bearer $token',
              "Content-Type": 'application/json',
              "Accept": "application/json",
            },
          ),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final result = response.data as Map;

      if (result['data'] != null &&
          result['data']['system_currencies'] != null) {
        return Map<String, dynamic>.from(result['data']['system_currencies']);
      } else {
        _showNoDataError();
      }
    }

    return null;
  }

  void _pushExchangeRatesPage(Map<String, dynamic> currencyRates) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExchangeRates(newCurrencyRates: currencyRates),
      ),
    );
  }

  // MARK: - Navigation Methods
  Future<void> _navigateToSignInPreferences() async {
    _safeSetState(() => _isSignInPrefsLoading = true);

    final signInPrefsProvider = Provider.of<SignInPreferencesProvider>(
      context,
      listen: false,
    );

    await signInPrefsProvider.refreshAllData();

    _safeSetState(() => _isSignInPrefsLoading = false);

    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangeNotifierProvider.value(
            value: signInPrefsProvider,
            child: SignInPreferences(provider: signInPrefsProvider),
          ),
        ),
      );
    }
  }

  void _navigateToViewProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ViewProfile()),
    );
  }

  void _navigateToChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );
  }

  void _navigateToPreferences() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const Preferences()),
    );
  }

  void _navigateToChangeBaseCurrency() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChangeBaseCurrency()),
    );
  }

  void _navigateToLegalDocuments() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LegalDocumentsScreen()),
    );
  }

  // MARK: - Dialog & Sheet Methods
  void _showAppAppearanceSheet() {
    AppAppearanceSheet(context).show();
  }

  void _showSocialMediaSheet() {
    SocialMediaBottomSheet(context).show();
  }

  // MARK: - Logout Confirmation
  Future<void> _showLogoutConfirmation() async {
    if (Platform.isIOS) {
      await _showCupertinoLogoutDialog();
    } else {
      await _showMaterialLogoutDialog();
    }
  }

  Future<void> _showCupertinoLogoutDialog() async {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(
          'Are you sure?',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Please confirm that you’d like to log out of your account',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
        ),
        actions: [
          CupertinoDialogAction(
            child: _buildDialogButtonText('Cancel', isDestructive: false),
            onPressed: () => Navigator.of(context).pop(),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: _buildDialogButtonText('Log out', isDestructive: true),
          ),
        ],
      ),
    );
  }

  Future<void> _showMaterialLogoutDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Are you sure?',
          style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Please confirm that you’d like to log out of your account',
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w400),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: _buildDialogButtonText('Cancel', isDestructive: false),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _logout();
            },
            child: _buildDialogButtonText('Log out', isDestructive: true),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogButtonText(String text, {required bool isDestructive}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 17.sp,
        fontWeight: isDestructive ? FontWeight.w400 : FontWeight.w600,
        color: const Color(0xff0F77F0),
      ),
    );
  }

  // MARK: - Error Handling
  void _handleDioError(DioException e) {
    final errorMessage = _getDioErrorMessage(e);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return 'Bad request - please try again';
          case 401:
            return 'Session expired - please login again';
          case 404:
            return 'Service not found';
          case 429:
            return 'Too many requests - please wait';
          case 500:
            return 'Server error - please try again later';
          case 502:
            return 'Bad gateway - server is down';
          case 503:
            return 'Service unavailable';
          default:
            return 'Server error (${e.response?.statusCode})';
        }
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout';
      case DioExceptionType.sendTimeout:
        return 'Send timeout';
      case DioExceptionType.receiveTimeout:
        return 'Receive timeout';
      case DioExceptionType.cancel:
        return 'Request cancelled';
      case DioExceptionType.unknown:
        return 'Network error - check your connection';
      default:
        return 'Unknown error occurred';
    }
  }

  void _showLoginError() {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login again')));
    }
  }

  void _showNoDataError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exchange rate data available')),
      );
    }
  }

  void _showTimeoutError() {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request timed out')));
    }
  }

  void _showUnexpectedError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred')),
      );
    }
  }

  // MARK: - App Rating
  Future<void> _launchAppRating() async {
    final url = Platform.isAndroid
        ? 'https://play.google.com/store/apps/details?id=com.prismcheck.gaphub&pcampaignid=web_share'
        : 'https://apps.apple.com/us/app/gaphub/id1577758374';

    final canLaunchUrl = await canLaunch(url);

    if (canLaunchUrl) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: 'Error launching store');
    }
  }

  // MARK: - UI Builders
  Widget _buildProfileSection(String fullName, String email, String imageUrl) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              padding: EdgeInsets.all(0.sp),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color.fromRGBO(0, 0, 0, 0.08),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 100.w,
                  height: 100.h,
                  child: _buildProfileImage(imageUrl),
                ),
              ),
            ),
            // Pass callback to AvatarPickerButton to refresh image
            AvatarPickerButton(
              onImageUploaded: (newImageUrl) {
                final provider = Provider.of<Providers>(context, listen: false);
                provider.details[7] = newImageUrl;
                setState(() {});
              },
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          fullName,
          style: GoogleFonts.nunitoSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          email,
          style: GoogleFonts.nunitoSans(
            color: AppColors.grayColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(height: 8.h),
        _buildViewProfileButton(),
      ],
    );
  }

  Widget _buildViewProfileButton() {
    return TextButton(
      onPressed: _navigateToViewProfile,
      style: TextButton.styleFrom(
        backgroundColor: const Color(0xfff9f9f9),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.sp),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Text(
        "View Profile",
        style: GoogleFonts.nunitoSans(
          color: AppColors.primaryColor,
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Card(
      color: AppColors.cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.sp),
        side: const BorderSide(color: Color(0xFFEEEEEE), width: 0.7),
      ),
      child: Column(
        children: List.generate(children.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Divider(
              height: 30.h,
              color: const Color(0xFFe4e4e4),
              indent: 0,
              endIndent: 0,
            );
          }
          return children[index ~/ 2];
        }),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return TextButton(
      onPressed: _showLogoutConfirmation,
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
        backgroundColor: AppColors.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.sp),
          side: const BorderSide(color: AppColors.borderColor),
        ),
      ),
      child: Container(
        alignment: Alignment.topLeft,
        child: Text(
          "Log Out",
          style: GoogleFonts.nunitoSans(color: Colors.red),
        ),
      ),
    );
  }

  // MARK: - Safe State Update
  void _safeSetState(VoidCallback callback) {
    if (mounted) {
      setState(callback);
    }
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    // Use Consumer to automatically rebuild when provider data changes
    return Consumer<Providers>(
      builder: (context, provider, child) {
        final baseCurrency = context.read<Providers>().baseCurrency;
        final symbolCurrency = context.read<Providers>().snapshotmodel.currency;

        // Always get fresh data from provider
        final fullName = _buildFullName(provider);
        final email = provider.details[2];
        final imageUrl = _processImageUrl(provider.details[7]);

        return Scaffold(
          appBar: _buildAppBar(),
          backgroundColor: Colors.white,
          body: ListView(
            padding: EdgeInsets.all(16.sp),
            children: [
              _buildProfileSection(fullName, email, imageUrl),
              SizedBox(height: 20.h),
              _buildSettingsCard([
                SettingsTile(
                  svgPath: 'assets/settings/changepword.png',
                  title: 'Change Password',
                  onPressed: _navigateToChangePassword,
                ),
                SettingsTile(
                  svgPath: 'assets/settings/fingerprint.png',
                  title: 'Preferred Sign-In option',
                  onPressed: _navigateToSignInPreferences,
                  subtitle: _isSignInPrefsLoading ? 'Loading...' : null,
                ),
              ]),
              SizedBox(height: 20.h),
              _buildSettingsCard([
                SettingsTile(
                  svgPath: 'assets/settings/settings.png',
                  title: 'Preferences',
                  onPressed: _navigateToPreferences,
                ),
                SettingsTile(
                  svgPath: 'assets/settings/paint_roller.png',
                  title: 'App Appearance',
                  onPressed: _showAppAppearanceSheet,
                ),
                SettingsTile(
                  svgPath: 'assets/settings/exchange.png',
                  title: 'Exchange Rate',
                  onPressed: _navigateToExchangeRates,
                ),
                SettingsTile(
                  svgPath: 'assets/settings/currency.png',
                  title: 'Base Currency',
                  subtitle: _formatCurrency(baseCurrency, symbolCurrency),
                  onPressed: _navigateToChangeBaseCurrency,
                ),
                SettingsTile(
                  svgPath: 'assets/settings/documents.png',
                  title: 'Legal Documents',
                  onPressed: _navigateToLegalDocuments,
                ),
              ]),
              SizedBox(height: 20.h),
              _buildSettingsCard([
                SettingsTile(
                  svgPath: 'assets/settings/rate.png',
                  title: 'Rate this app',
                  onPressed: _launchAppRating,
                ),
                SettingsTile(
                  svgPath: 'assets/settings/socialmedia.png',
                  title: 'Follow us on social media',
                  onPressed: _showSocialMediaSheet,
                ),
              ]),
              const SizedBox(height: 30),
              _buildLogoutButton(),
            ],
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.white,
      title: Text(
        "Settings",
        style: GoogleFonts.nunitoSans(
          color: Colors.black,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  final String svgPath;
  final String title;
  final String? subtitle;
  final VoidCallback? onPressed;

  const SettingsTile({
    super.key,
    required this.svgPath,
    required this.title,
    this.subtitle,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Image.asset(svgPath, height: 28.h, width: 28.w),
      ),
      title: Text(title, style: GoogleFonts.nunitoSans(color: Colors.black)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: GoogleFonts.nunitoSans(color: Colors.grey))
          : null,
      trailing: Icon(
        Icons.chevron_right,
        size: 16.sp,
        color: const Color(0xFFA6A6A6),
      ),
      onTap: onPressed,
    );
  }
}
