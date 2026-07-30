import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/bottomnav.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http_parser/http_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';

class AvatarGrid extends StatefulWidget {
  const AvatarGrid({super.key});

  @override
  _AvatarGridState createState() => _AvatarGridState();
}

class _AvatarGridState extends State<AvatarGrid> {
  final DialogBox dialogBox = DialogBox();
  final ImagePicker picker = ImagePicker();
  final Dio dio = Dio();
  File? _image;

  // Avatar configuration
  static const _avatarCount = 2;
  final List<String> defAVatars = [
    'default_nabjna',
    'avamale1_ienbabdhbs',
    'avafemale1_ienbabdhbs',
    'avamale2_ienbabdhbs',
    'avafemale5_ienbabdhbs',
    'avamale3_ienbabdhbs',
    'avafemale3_ienbabdhbs',
    'avamale4_ienbabdhbs',
    'avafemale4_ienbabdhbs',
    'avamale5_ienbabdhbs',
    'avafemale2_ienbabdhbs',
  ];

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isPortrait = media.orientation == Orientation.portrait;
    final height = isPortrait ? media.size.height : media.size.width;
    final width = isPortrait ? media.size.width : media.size.height;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      bottomNavigationBar: const BottomNav(4),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: height * 0.02),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width * 0.05),
              child: Text(
                'Select from the available Avatars or choose your preferred profile picture',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: width * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: height * 0.01),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(12),
                childAspectRatio: 0.9,
                children: List.generate(
                  _avatarCount,
                  (index) => _buildAvatarCard(context, index),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _handleAvatarSelection(index),
        child: index == 0
            ? _buildCustomAvatarOption()
            : CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/settings/avatar$index.png'),
              ),
      ),
    );
  }

  Widget _buildCustomAvatarOption() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(flex: 2, child: Image.asset('assets/settings/avatar.png')),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAvatarSelection(int index) async {
    if (index == 0) {
      await _showImageSourceSelector();
    } else {
      await _setDefaultAvatar(defAVatars[index - 1]);
    }
  }

  Future<void> _showImageSourceSelector() async {
    if (Platform.isIOS) {
      await _showCupertinoImagePicker();
    } else {
      await _showMaterialImagePicker();
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
              await _setDefaultAvatar(defAVatars[1]);
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
                await _setDefaultAvatar(defAVatars[1]);
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
    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 800,
      );

      if (pickedFile != null) {
        final image = File(pickedFile.path);
        if (await _validateImage(image) && await _validateImageType(image)) {
          await _uploadImageWithRetry(image);
        } else {
          _showErrorToast('Image must be JPG/PNG format and less than 5MB');
        }
      }
    } catch (e) {
      print('Image pick error: $e');
      _showErrorToast('Failed to pick image');
    }
  }

  Future<bool> _validateImage(File image) async {
    const maxSize = 5 * 1024 * 1024; // 5MB
    final size = await image.length();
    return size <= maxSize;
  }

  Future<bool> _validateImageType(File image) async {
    final path = image.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png');
  }

  Future<void> _uploadImageWithRetry(File image, {int retries = 2}) async {
    for (int attempt = 0; attempt <= retries; attempt++) {
      try {
        await _uploadImage(image);
        return; // Success, exit the function
      } catch (e) {
        if (attempt == retries) {
          rethrow; // All retries failed
        }
        await Future.delayed(const Duration(seconds: 1)); // Wait before retry
      }
    }
  }

  Future<void> _uploadImage(File image) async {
    final timer = Timer(const Duration(seconds: 30), () {
      _showErrorDialog('Service timed out');
    });

    try {
      dialogBox.waiting(context, 'Saving picture');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');
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

      final formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: contentType,
        ),
      });

      // Add debug logging
      print('Uploading file: $filename, type: ${contentType.mimeType}');

      final response = await dio.post(
        '$baseUrl/app/picture',
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token',
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      // Check response
      print('Upload response: ${response.statusCode}');
      print('Upload response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchAndUpdateProfile(token!);
        _showSuccessToast('Saved successfully');
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } on DioException catch (e) {
      print('Dio error details: $e');
      print('Response data: ${e.response?.data}');
      print('Response headers: ${e.response?.headers}');

      String errorMessage = 'Failed to upload image';
      if (e.response?.statusCode == 400) {
        errorMessage =
            'Invalid image format or size. Please try another image.';
      } else if (e.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.response?.statusCode == 413) {
        errorMessage = 'Image is too large. Please select a smaller image.';
      } else if (e.response?.statusCode == 415) {
        errorMessage = 'Unsupported image format. Please use JPG or PNG.';
      } else {
        errorMessage = 'Failed to upload image: ${e.message}';
      }

      _showErrorDialog(errorMessage);
    } catch (e) {
      print('Upload error: $e');
      _showErrorDialog('Failed to upload image: ${e.toString()}');
    } finally {
      timer.cancel();
    }
  }

  Future<void> _setDefaultAvatar(String avatar) async {
    final timer = Timer(const Duration(seconds: 30), () {
      _showErrorDialog('Service timed out');
    });

    try {
      dialogBox.waiting(context, 'Saving picture');

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      final response = await http.post(
        Uri.parse('$baseUrl/app/default/picture'),
        body: {'avatar': avatar},
        headers: {
          "Authorization": 'Bearer $token',
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _fetchAndUpdateProfile(token!);
        _showSuccessToast('Saved successfully');
        //  Navigator.of(context, rootNavigator: true).pop();
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      print('Set default avatar error: $e');
      _showErrorDialog('Failed to set avatar: ${e.toString()}');
    } finally {
      timer.cancel();
      EasyLoading.dismiss();
    }
  }

  Future<void> _fetchAndUpdateProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/app/profile"),
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final editdetails = Editdetails.fromJson(jsonDecode(response.body));
        final user = editdetails.user;
        final profile = user["profile"];

        final providers = context.read<Providers>();
        providers.setDetailsList(user["firstname"].toString(), 0);
        providers.setDetailsList(user["surname"].toString(), 1);
        providers.setDetailsList(user["email"].toString(), 2);
        providers.setDetailsList(profile["phone"].toString(), 3);
        providers.setDetailsList(profile["date_of_birth"].toString(), 4);
        providers.setDetailsList(profile["country"].toString(), 5);
        providers.setDetailsList(profile["ancesry"].toString(), 6);

        String? imgurl = profile["image"];
        if (imgurl != null) {
          imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
          imgurl = '$imgPrefix/$imgurl';
        }
        providers.setDetailsList(imgurl!, 7);
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      print('Fetch profile error: $e');
      throw Exception('Failed to fetch profile: $e');
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
}
