import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:provider/provider.dart';

class AvatarPickerButton extends StatefulWidget {
  final ValueChanged<String?> onImageUploaded;

  const AvatarPickerButton({super.key, required this.onImageUploaded});

  @override
  State<AvatarPickerButton> createState() => _AvatarPickerButtonState();
}

class _AvatarPickerButtonState extends State<AvatarPickerButton> {
  final DialogBox dialogBox = DialogBox();
  final ImagePicker picker = ImagePicker();

  // Make it nullable and initialize lazily
  Dio? _dio;
  bool _isUploading = false;
  bool _isInitialized = false;

  // Cache for token to avoid repeated SharedPreferences access
  String? _cachedToken;

  final List<String> defAVatars = ['default_nabjna', 'avamale1_ienbabdhbs'];

  @override
  void initState() {
    super.initState();
    _initializeAsync();
  }

  Future<void> _initializeAsync() async {
    await _loadToken();
    _initializeDio();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _cachedToken = prefs.getString('tokenDB');
      print('Token loaded: ${_cachedToken != null}');
    } catch (e) {
      print('Error loading token: $e');
    }
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          return status! < 500; // Accept all status codes below 500
        },
      ),
    );

    // Add interceptors for better error handling and logging
    _dio!.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          print('Request Headers: ${options.headers}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => DATA: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('ERROR[${e.response?.statusCode}] => MESSAGE: ${e.message}');
          print('Error Response Data: ${e.response?.data}');
          return handler.next(e);
        },
      ),
    );

    print('Dio initialized successfully');
  }

  // Method to ensure Dio is initialized
  Future<Dio> _getDio() async {
    if (_dio == null) {
      _initializeDio();
    }
    return _dio!;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 5),
      child: InkWell(
        onTap: (_isUploading || !_isInitialized) ? null : _showAvatarModal,
        child: Container(
          width: 40.sp,
          height: 40.sp,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(233, 233, 233, 0.48),
            borderRadius: BorderRadius.circular(80),
            border: Border.all(color: const Color(0xFFEBEBEB), width: 0.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(-1, 1),
                blurRadius: 4,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(80),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: 0.6,
                  child: Image.asset(
                    'assets/settings/edit_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                if (_isUploading || !_isInitialized)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarModal() {
    if (Platform.isIOS) {
      _showCupertinoImagePicker();
    } else {
      _showMaterialImagePicker();
    }
  }

  Future<void> _showCupertinoImagePicker() async {
    final action = await showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Change profile picture',
          style: GoogleFonts.nunitoSans(
            color: const Color(0xff79767D),
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(context);
              await _setDefaultAvatar();
            },
            child: Text(
              'Remove current photo',
              style: GoogleFonts.nunitoSans(
                color: AppColors.primaryColor,
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            child: Text(
              'Take a photo',
              style: GoogleFonts.nunitoSans(
                color: const Color(0xff0F77F0),
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            child: Text(
              'Choose from Library',
              style: GoogleFonts.nunitoSans(
                color: const Color(0xff0F77F0),
                fontSize: 20.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          isDefaultAction: true,
          child: Text(
            'Cancel',
            style: GoogleFonts.nunitoSans(
              color: const Color(0xff0F77F0),
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    if (action != null) {
      await _pickAndUploadImage(action);
    }
  }

  Future<void> _showMaterialImagePicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xff79747f),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20.h),
            ListTile(
              title: Text(
                'Change profile picture',
                style: GoogleFonts.nunitoSans(
                  color: const Color(0xff79767D),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            ListTile(
              title: Text(
                'Remove current photo',
                style: GoogleFonts.nunitoSans(
                  color: AppColors.primaryColor,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _setDefaultAvatar();
              },
            ),
            ListTile(
              title: Text(
                'Take Photo',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              title: Text(
                'Choose from Library',
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickAndUploadImage(source);
    }
  }

  Future<void> _pickAndUploadImage(ImageSource source) async {
    if (_isUploading) return;

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final image = File(pickedFile.path);

        // Ensure file is readable
        if (!await image.exists()) {
          _showErrorToast('Image file not found');
          return;
        }

        // Wait a moment for file to be fully accessible (fix for Android 11+)
        await Future.delayed(const Duration(milliseconds: 500));

        if (await _validateImage(image) && await _validateImageType(image)) {
          await _uploadImageWithRetry(image);
        } else {
          _showErrorToast('Image must be JPG/PNG format and less than 5MB');
        }
      }
    } catch (e) {
      print('Image pick error: $e');
      _showErrorToast('Failed to pick image: ${e.toString()}');
    }
  }

  Future<bool> _validateImage(File image) async {
    try {
      const maxSize = 5 * 1024 * 1024; // 5MB
      final size = await image.length();
      return size <= maxSize;
    } catch (e) {
      print('Image validation error: $e');
      return false;
    }
  }

  Future<bool> _validateImageType(File image) async {
    try {
      final path = image.path.toLowerCase();
      return path.endsWith('.jpg') ||
          path.endsWith('.jpeg') ||
          path.endsWith('.png');
    } catch (e) {
      print('Image type validation error: $e');
      return false;
    }
  }

  Future<void> _uploadImageWithRetry(File image, {int maxRetries = 2}) async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    try {
      // Ensure Dio is initialized
      final dio = await _getDio();

      // Ensure we have a fresh token
      if (_cachedToken == null) {
        await _loadToken();
      }

      for (int attempt = 0; attempt <= maxRetries; attempt++) {
        try {
          final updatedImageUrl = await _uploadImage(image, dio);

          // Success - exit the retry loop
          if (mounted) {
            widget.onImageUploaded(updatedImageUrl);
          }
          return;
        } catch (e) {
          print('Upload attempt $attempt failed: $e');

          // ✅ FIXED: Don't retry if error is from profile fetch
          // Profile fetch errors should not trigger image upload retry
          if (e.toString().contains('Fetch profile error') ||
              e.toString().contains('Failed to fetch profile')) {
            print('Profile fetch error detected, not retrying upload');
            // Still mark as success since upload itself succeeded
            if (mounted) {
              widget.onImageUploaded(null);
            }
            return;
          }

          if (attempt == maxRetries) {
            // All retries failed
            rethrow;
          }

          // Check if error is due to token/auth
          if (e.toString().contains('401') ||
              e.toString().contains('unauthorized')) {
            // Token might be expired, refresh it
            await _loadToken();
          }

          // Exponential backoff: wait longer between retries
          await Future.delayed(Duration(seconds: (attempt + 1) * 2));
        }
      }
    } catch (e) {
      // _showErrorDialog('Failed to upload image after multiple attempts');
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<String?> _uploadImage(File image, Dio dio) async {
    final timer = Timer(const Duration(seconds: 30), () {
      throw TimeoutException('Upload timeout');
    });

    try {
      if (_cachedToken == null) {
        await _loadToken();
        if (_cachedToken == null) {
          throw Exception('No authentication token found');
        }
      }

      final filename = image.path.split('/').last;
      final fileExtension = filename.split('.').last.toLowerCase();

      // Determine content type based on file extension
      MediaType contentType;
      if (fileExtension == 'png') {
        contentType = MediaType('image', 'png');
      } else if (fileExtension == 'jpeg' || fileExtension == 'jpg') {
        contentType = MediaType('image', 'jpeg');
      } else {
        throw Exception('Unsupported file format');
      }

      // Create a new instance of FormData for each attempt
      final formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: contentType,
        ),
      });

      print('Uploading file: $filename, type: ${contentType.mimeType}');
      print('Using token: ${_cachedToken?.substring(0, 10)}...');

      final response = await dio.post(
        '$baseUrl/app/picture',
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $_cachedToken',
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print('Upload response: ${response.statusCode}');
      print('Upload response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ FIXED: Upload is successful, show success message immediately
        _showSuccessToast('Saved successfully');

        // ✅ FIXED: Update profile in background without blocking upload success
        // This way, profile fetch errors won't trigger retry logic
        if (_cachedToken != null && _cachedToken!.isNotEmpty) {
          return await _fetchAndUpdateProfile(_cachedToken!);
        } else {
          print('Token not available, skipping profile update');
        }

        return null;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio error details: $e');
      print('Response data: ${e.response?.data}');
      print('Response headers: ${e.response?.headers}');

      String errorMessage = 'Failed to upload image';

      // Handle specific Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.response?.statusCode == 400) {
        errorMessage =
            'Invalid image format or size. Please try another image.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please login again.';
        // Clear cached token on auth error
        _cachedToken = null;
      } else if (e.response?.statusCode == 413) {
        errorMessage = 'Image is too large. Please select a smaller image.';
      } else if (e.response?.statusCode == 415) {
        errorMessage = 'Unsupported image format. Please use JPG or PNG.';
      } else {
        errorMessage = 'Upload failed: ${e.message}';
      }

      throw Exception(errorMessage);
    } catch (e) {
      print('Upload error: $e');
      throw Exception('Upload failed: ${e.toString()}');
    } finally {
      timer.cancel();
    }
  }

  Future<void> _setDefaultAvatar() async {
    if (_isUploading) return;

    setState(() => _isUploading = true);

    final timer = Timer(const Duration(seconds: 30), () {
      _showErrorDialog('Service timed out');
    });

    try {
      if (_cachedToken == null) {
        await _loadToken();
        if (_cachedToken == null) {
          throw Exception('No authentication token found');
        }
      }

      final response = await http.post(
        Uri.parse('$baseUrl/app/default/picture'),
        body: {'avatar': defAVatars[1]},
        headers: {
          "Authorization": 'Bearer $_cachedToken',
          "Content-Type": "application/x-www-form-urlencoded",
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _showSuccessToast('Photo removed successfully');

        if (_cachedToken != null && _cachedToken!.isNotEmpty) {
          final updatedImageUrl = await _fetchAndUpdateProfile(_cachedToken!);
          if (mounted) {
            widget.onImageUploaded(updatedImageUrl);
          }
        } else {
          print('Token not available, skipping profile update');
        }

        // if (mounted) {
        //   Navigator.of(context, rootNavigator: true).pop();
        //   widget.onImageUploaded.call(null);
        // }
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Remove photo error: $e');
      _showErrorDialog('Failed to remove photo: ${e.toString()}');
    } finally {
      timer.cancel();
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<String?> _fetchAndUpdateProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/app/profile"),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print('Profile response received');

        // ✅ FIXED: Handle both nested user object and direct profile response
        dynamic userData;
        dynamic profileData;

        // Check if response has a 'user' key (nested structure)
        if (jsonData['user'] != null) {
          userData = jsonData['user'];
          profileData = jsonData['profile'] ?? userData['user_profile'] ?? {};
        } else {
          // Direct profile response structure
          userData = jsonData;
          profileData = jsonData;
        }

        if (mounted) {
          try {
            final providers = context.read<Providers>();

            // ✅ CRITICAL FIX: Guarantee all values are String, never null
            String firstName = _ensureString(userData['firstname']);
            String surname = _ensureString(userData['surname']);
            String email = _ensureString(userData['email']);
            String phone = _ensureString(profileData['phone']);
            String dateOfBirth = _ensureString(profileData['date_of_birth']);
            String country = _ensureString(profileData['country']);
            String ancestry = _ensureString(profileData['ancesry']);

            print(
              'Setting profile data: firstName="$firstName", surname="$surname", email="$email"',
            );
            print(
              'Phone="$phone", DOB="$dateOfBirth", Country="$country", Ancestry="$ancestry"',
            );

            // ✅ All values are now guaranteed String, never null
            providers.setDetailsList(firstName, 0);
            providers.setDetailsList(surname, 1);
            providers.setDetailsList(email, 2);
            providers.setDetailsList(phone, 3);
            providers.setDetailsList(dateOfBirth, 4);
            providers.setDetailsList(country, 5);
            providers.setDetailsList(ancestry, 6);

            // ✅ Handle image URL safely
            String imgurl = _ensureString(profileData['image']);
            if (imgurl.isNotEmpty && imgurl.length >= 6) {
              imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
              imgurl = '$imgPrefix/$imgurl';
            }
            print('Image URL: "$imgurl"');
            providers.setDetailsList(imgurl, 7);

            print('Profile updated successfully');
            return imgurl;
          } catch (providerError) {
            print('Provider update error: $providerError');
            print('Provider error stack: ${providerError.toString()}');
            // Don't rethrow - upload succeeded, profile update is non-critical
            return null;
          }
        }
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch profile error: $e');
      // Don't rethrow - let it fail silently as it's a background task
      return null;
    }
    return null;
  }

  // ✅ HELPER METHOD: Guarantee a String value, NEVER returns null
  String _ensureString(dynamic value) {
    if (value == null) {
      return '';
    }
    if (value is String) {
      return value.isEmpty ? '' : value;
    }
    if (value is int || value is double || value is bool) {
      return value.toString();
    }
    try {
      return value.toString();
    } catch (e) {
      print('Error converting value to string: $e');
      return '';
    }
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      // Parse for better error messages
      if (message.contains('status code: 400')) {
        message = 'Invalid request. Please try again.';
      } else if (message.contains('status code: 401')) {
        message = 'Authentication failed. Please login again.';
      } else if (message.contains('status code: 413')) {
        message = 'Image is too large. Please select a smaller image.';
      } else if (message.contains('status code: 415')) {
        message = 'Unsupported image format. Please use JPG or PNG.';
      }

      dialogBox.information(context, 'Error', message);
    }
  }

  @override
  void dispose() {
    _dio?.close(force: true);
    super.dispose();
  }
}
