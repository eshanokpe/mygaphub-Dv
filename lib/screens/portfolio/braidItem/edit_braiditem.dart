import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:GapHub/screens/portfolio/braiditem.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_input_field.dart';
import 'package:GapHub/widgets/custom_input_field_multistep.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import 'widget/display_image_widget.dart';

class BaidItemEdit extends StatefulWidget {
  final String imgurl;
  final Map data;
  final String? type;
  final String? id;

  const BaidItemEdit({
    super.key,
    required this.imgurl,
    required this.data,
    this.type,
    this.id,
  });

  @override
  State<BaidItemEdit> createState() => _BaidItemEditState();
}

class _BaidItemEditState extends State<BaidItemEdit> {
  // MARK: - Constants
  static const int _timeoutDuration = 30;
  static const List<String> _allowedFileExtensions = [
    '.doc',
    '.docx',
    '.pdf',
    '.jpg',
  ];
  static const String _defaultAssetSelect = '-Select-';

  // MARK: - Dependencies
  late final Dio _dio;
  late final DialogBox _dialogBox;
  final ImagePicker _imagePicker = ImagePicker();

  // MARK: - Document Variables
  var document1;
  var document2;
  var document3;
  var document4;
  var document5;
  var document6;
  var document7;
  var document8;
  final List<dynamic> documents = [];

  // MARK: - Controllers
  final TextEditingController _docNameController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _incomeController = TextEditingController();

  // MARK: - State Variables
  String? _imageUrl;
  final int _radioValue = 0;
  final String _asset = _defaultAssetSelect;
  File? _selectedImage;
  File? _selectedFile;
  FilePickerResult? _filePickerResult;

  // MARK: - Lifecycle Methods
  @override
  void initState() {
    super.initState();
    _initializeDependencies();
    _initializeData();
  }

  @override
  void dispose() {
    _docNameController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _valueController.dispose();
    _incomeController.dispose();
    super.dispose();
  }

  // MARK: - Initialization
  void _initializeDependencies() {
    _dio = Dio();
    _dialogBox = DialogBox();
  }

  void _initializeData() {
    final assetData = widget.data['data']["asset"];
    _imageUrl = assetData["photo_url"];

    print("Asset data: ${assetData['automated_rate']}");

    _nameController.text = assetData["name"] ?? '';
    _descriptionController.text = assetData["description"] ?? '';

    _loadDocuments(assetData);
  }

  void _loadDocuments(Map<String, dynamic> assetData) {
    final documentFields = [
      assetData["document1"],
      assetData["document2"],
      assetData["document3"],
      assetData["document4"],
      assetData["document5"],
      assetData["document6"],
      assetData["document7"],
      assetData["document8"],
    ];

    for (var doc in documentFields) {
      if (doc != null) {
        documents.add(doc);
      }
    }
  }

  // MARK: - Image Picker Methods
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        print('Selected image: $_selectedImage');
        _updateImage(_selectedImage!);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _updateImage(_selectedImage!);
      });
    }
  }

  // MARK: - Document Picker Methods
  Future<void> _pickDocumentFromFiles() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return;

    final fileName = result.files.single.name;
    final fileExtension = fileName.substring(fileName.length - 4).toLowerCase();

    if (!_allowedFileExtensions.contains(fileExtension)) {
      _dialogBox.information(context, "Status", "Unsupported file type");
      return;
    }

    setState(() {
      _filePickerResult = result;
      _selectedFile = File(result.files.single.path!);
      _updateDocument(_selectedFile!);
    });
  }

  Future<void> _pickDocumentFromPhotoLibrary() async {
    final pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1800,
      maxHeight: 1800,
    );

    if (pickedFile == null) return;

    setState(() {
      _selectedFile = File(pickedFile.path);
    });

    await _updateDocument(_selectedFile!);
  }

  // MARK: - API Methods
  // MARK: - API Methods
  Future<void> _updateDetails(Map<String, dynamic> assetData) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (_filePickerResult != null && _docNameController.text.isEmpty) {
      _dialogBox.information(
        context,
        "Status",
        "Please provide a document name",
      );
      return;
    }

    // Show loading dialog
    _dialogBox.waiting(context, "Loading");

    // Set up timeout timer
    final timer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        Navigator.pop(context); // Pop loading dialog
        _dialogBox.information(context, 'Status', 'Service timed out');
      }
    });

    try {
      final url = "$baseUrl/app/portfolio/update/details/${assetData["id"]}";
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context);
          _dialogBox.information(
            context,
            "Authentication Error",
            'Session expired. Please login again.',
          );
        }
        return;
      }

      // Convert all values to strings to avoid type casting issues
      final Map<String, String> body = {
        "asset_name": _nameController.text,
        "asset_value": assetData["asset_value"].toString(),
        "portfolio_type": assetData['portfolio_type_id'].toString(),
        "automated_rate": assetData['automated'].toString(),
        "description": _descriptionController.text,
      };

      print("🔵 Request URL: $url");
      print("🔵 Request Body: $body");
      print("🔵 Token: ${token.substring(0, 10)}...");

      final headers = {
        "Accept": "application/json",
        "Authorization": 'Bearer $token',
        "Content-Type": "application/x-www-form-urlencoded",
      };

      // Try PUT method first (more appropriate for updates), fallback to POST
      late http.Response response;

      try {
        response = await http
            .post(Uri.parse(url), headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
      } catch (putError) {
        // If PUT fails with method not allowed, try POST
        print("🔵 PUT failed, trying POST...");
        response = await http
            .post(Uri.parse(url), headers: headers, body: body)
            .timeout(const Duration(seconds: 30));
      }

      print("🔵 Response Status: ${response.statusCode}");
      print("🔵 Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context); // Pop loading dialog

          final responseData = jsonDecode(response.body);

          // Check different success indicators
          if (responseData['status'] == 'success' ||
              responseData['success'] == true ||
              responseData['message']?.contains('success') == true) {
            Fluttertoast.showToast(msg: 'Data updated successfully');
            await _navigateToItemDetails(
              assetData["id"],
              assetData["asset_class"],
            );
          } else {
            _dialogBox.information(
              context,
              "Status",
              responseData['message'] ?? 'Update completed',
            );
            // Still navigate since update might have worked
            await _navigateToItemDetails(
              assetData["id"],
              assetData["asset_class"],
            );
          }
        }
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.pop(context); // Pop loading dialog

          String errorMessage = 'Something went wrong, try again';
          try {
            final errorData = jsonDecode(response.body);
            errorMessage =
                errorData['message'] ??
                errorData['error'] ??
                'Error ${response.statusCode}';
          } catch (e) {
            errorMessage =
                'Error ${response.statusCode}: ${response.reasonPhrase}';
          }

          _dialogBox.information(context, "Status", errorMessage);
        }
      }
    } on TimeoutException catch (_) {
      print("🔴 Timeout Error");
      timer.cancel();
      if (mounted) {
        Navigator.pop(context);
        _dialogBox.information(context, "Status", 'Request timed out');
      }
    } catch (e) {
      print("🔴 Error: $e");
      print("🔴 Error type: ${e.runtimeType}");
      timer.cancel();
      if (mounted) {
        Navigator.pop(context);
        _dialogBox.information(context, "Status", 'Error: ${e.toString()}');
      }
    }
  }

  Future<void> _navigateToItemDetails(int id, String type) async {
    try {
      final url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        Fluttertoast.showToast(msg: "Authentication error");
        return;
      }

      print("🔵 Fetching item details: $url");

      final response = await http
          .get(url, headers: {"Authorization": 'Bearer $token'})
          .timeout(const Duration(seconds: 30));

      print("🔵 Item details response: ${response.statusCode}");

      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Braiditem(
                data: jsonDecode(response.body),
                archived: false,
                type: widget.type,
                id: widget.id,
              ),
            ),
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: "Error loading item details: ${response.statusCode}",
        );
        // Optionally go back
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      print("🔴 Error fetching item details: $e");
      Fluttertoast.showToast(msg: "Error loading item details");
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _updateDocument(File file) async {
    print('Updating document: $file');

    final assetData = widget.data['data']["asset"];
    final url = "$baseUrl/app/portfolio/update/details/${assetData["id"]}";
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    if (token == null) {
      print('Authorization token not found');
      Fluttertoast.showToast(msg: 'Authorization token not found');
      return;
    }

    final timeoutTimer = Timer(const Duration(seconds: _timeoutDuration), () {
      if (mounted) {
        Navigator.pop(context);
        _dialogBox.information(context, 'Status', 'Service timed out');
      }
    });

    _dialogBox.waiting(context, 'Loading');

    try {
      final filename = file.path.split('/').last;
      final formData = FormData.fromMap({
        "asset_document": await MultipartFile.fromFile(
          file.path,
          filename: filename,
        ),
        "asset_document_name": filename,
        "asset_name": _nameController.text,
        "asset_value": assetData["asset_value"],
        "portfolio_type": assetData['portfolio_type_id'],
        "automated_rate": assetData['automated'],
        "description": _descriptionController.text,
      });

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Document update successful: ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Document updated successfully');
        await _navigateToItemDetails(assetData["id"], assetData["asset_class"]);
      } else {
        print('Document update failed: ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Failed to update document');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
      print('Document update error: $e');
    } finally {
      timeoutTimer.cancel();
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _updateImage(File image) async {
    print('🖼️ Updating image...');

    final assetData = widget.data['data']["asset"];
    final url = '$baseUrl/app/portfolio/update/photo/${assetData["id"]}';
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');

    if (token == null) {
      print('❌ Authorization token not found');
      Fluttertoast.showToast(msg: 'Authorization token not found');
      return;
    }

    print('🔗 API Endpoint: $url');
    print('🔑 Authorization token present: ${token.isNotEmpty}');

    _dialogBox.waiting(context, "Loading");

    Timer? timeoutTimer;
    try {
      timeoutTimer = Timer(const Duration(seconds: _timeoutDuration), () {
        Fluttertoast.showToast(msg: 'Service timed out');
      });

      final filename = image.path.split('/').last;
      final formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      print('📸 Uploading image: $filename');

      final response = await _dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token',
          },
          validateStatus: (status) => true,
        ),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📩 Response data: ${response.data}');

      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: '✅ Image upload successful');
        await _navigateToItemDetails(assetData["id"], assetData["asset_class"]);
      } else {
        Fluttertoast.showToast(
          msg: '❌ Error ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      print('🚨 Error: ${e.toString()}');
      Fluttertoast.showToast(msg: 'Something went wrong: ${e.toString()}');
    } finally {
      if (mounted) Navigator.pop(context);
      timeoutTimer?.cancel();
    }
  }

  // MARK: - Helper Methods
  void _launchDocument(String url) async {
    final canLaunchUrl = await canLaunch(url);
    if (canLaunchUrl) {
      await launch(url);
    } else {
      Fluttertoast.showToast(msg: 'Error opening document');
    }
  }

  // MARK: - Bottom Sheet Methods
  void _showDocumentPickerBottomSheet() {
    _showBottomSheet(
      context,
      _pickDocumentFromFiles,
      _pickDocumentFromPhotoLibrary,
    );
  }

  void _showImagePickerBottomSheet() {
    _showBottomSheetImage(context, _pickImageFromCamera, _pickImageFromGallery);
  }

  void _showBottomSheet(
    BuildContext context,
    VoidCallback onFilesSelected,
    VoidCallback onPhotoLibrarySelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final width = mediaQuery.size.width;
        final height = mediaQuery.size.height;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHandle(width, height),
              SizedBox(height: height * 0.02),
              _buildBottomSheetOption(
                onTap: () {
                  onFilesSelected();
                  Navigator.of(context).pop();
                },
                iconPath: "assets/images/files_icon.png",
                label: 'Choose from files',
                width: width,
              ),
              _buildBottomSheetOption(
                onTap: () {
                  onPhotoLibrarySelected();
                  Navigator.of(context).pop();
                },
                iconPath: "assets/images/gallery_icon.png",
                label: 'Choose from photo library',
                width: width,
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        );
      },
    );
  }

  void _showBottomSheetImage(
    BuildContext context,
    VoidCallback onCameraSelected,
    VoidCallback onGallerySelected,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final mediaQuery = MediaQuery.of(context);
        final width = mediaQuery.size.width;
        final height = mediaQuery.size.height;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildBottomSheetHandle(width, height),
              SizedBox(height: height * 0.02),
              _buildBottomSheetOption(
                onTap: () {
                  onGallerySelected();
                  Navigator.of(context).pop();
                },
                iconPath: "assets/images/gallery_icon.png",
                label: 'Choose from photo library',
                width: width,
              ),
              _buildBottomSheetOption(
                onTap: () {
                  onCameraSelected();
                  Navigator.of(context).pop();
                },
                iconPath: "assets/images/files_icon.png",
                label: 'Choose from camera',
                width: width,
              ),
              _buildBottomSheetOption(
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement remove picture functionality
                },
                iconPath: "assets/images/delete_red.png",
                label: 'Remove current picture',
                labelColor: const Color(0xffF50100),
                width: width,
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSheetHandle(double width, double height) {
    return Center(
      child: InkWell(
        onTap: () => Navigator.pop(context),
        child: Divider(
          color: const Color(0xffcdcdcd),
          height: height * 0.02,
          thickness: 5,
          indent: width * 0.38,
          endIndent: width * 0.38,
        ),
      ),
    );
  }

  Widget _buildBottomSheetOption({
    required VoidCallback onTap,
    required String iconPath,
    required String label,
    required double width,
    Color labelColor = Colors.black,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Image.asset(iconPath, width: width * 0.05),
      title: Text(
        label,
        style: TextStyle(
          color: labelColor,
          fontSize: width * 0.04,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // MARK: - UI Builders
  Widget _buildDocumentsSection(double width, double height) {
    return Column(
      children: [
        Center(
          child: Row(
            children: [
              Text(
                'Documents'.toUpperCase(),
                style: TextStyle(
                  color: const Color(0xff808080),
                  fontSize: width * 0.04,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: height * 0.01),
        Card(
          color: AppColors.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: const BorderSide(color: Color(0xffFAFAFA), width: 0.5),
          ),
          child: ExpandableTheme(
            data: const ExpandableThemeData(
              iconColor: Colors.blue,
              useInkWell: true,
            ),
            child: Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Column(
                children: <Widget>[
                  ExpansionTile(
                    leading: Image.asset(
                      'assets/images/pdf_icon.png',
                      width: width * 0.10,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '${documents.length} Documents uploaded',
                          style: TextStyle(
                            fontSize: width * 0.04,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    children: <Widget>[
                      ListView.builder(
                        itemCount: documents.length,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          final fileName = documents[index]["name"]
                              .toString()
                              .toLowerCase();
                          final isPDF = fileName.endsWith('.pdf');
                          final isImage =
                              fileName.endsWith('.jpg') ||
                              fileName.endsWith('.jpeg') ||
                              fileName.endsWith('.png');

                          return Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: height * 0.005,
                              horizontal: width * 0.05,
                            ),
                            child: Row(
                              children: [
                                Image.asset(
                                  isPDF
                                      ? 'assets/images/pdf1.png'
                                      : isImage
                                      ? 'assets/images/image_icon.png'
                                      : 'assets/images/pdf1.png',
                                  width: width * 0.10,
                                ),
                                SizedBox(width: width * 0.02),
                                Expanded(
                                  child: TextButton(
                                    onPressed: () => _launchDocument(
                                      documents[index]["document"],
                                    ),
                                    child: Text(
                                      documents[index]["name"],
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: width * 0.04,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadButton(double width, double height) {
    return Padding(
      padding: EdgeInsets.only(left: width * 0.50),
      child: PlusButton(
        color: Colors.white,
        iconsColor: const Color(0xffEDAC5C),
        textColor: AppColors.blackColor,
        icons: Icons.add,
        text: 'Upload New',
        onPressed: _showDocumentPickerBottomSheet,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(double width) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: true,
      elevation: 0,
      title: Text(
        'Edit Details',
        style: TextStyle(color: AppColors.grayColor, fontSize: width * 0.04),
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      actions: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _updateDetails(widget.data['data']["asset"]),
                child: Text(
                  'Done',
                  style: TextStyle(color: Colors.black, fontSize: width * 0.04),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // MARK: - Build Method
  @override
  Widget build(BuildContext context) {
    final assetData = widget.data['data']["asset"];
    final mediaQuery = MediaQuery.of(context);
    final height = mediaQuery.size.height;
    final width = mediaQuery.size.width;

    return Scaffold(
      appBar: _buildAppBar(width),
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        child: ListView(
          children: [
            SizedBox(height: height * 0.03),
            DisplayImage(
              imagePath: _imageUrl!,
              onPressed: _showImagePickerBottomSheet,
            ),
            SizedBox(height: height * 0.02),
            CustomInputField(
              label: 'Name',
              labelText: true,
              obscureText: false,
              keyboardType: TextInputType.text,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Field cannot be empty";
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.02),
            CustomInputFieldMultiStep(
              label: 'Description',
              image: '',
              maxLines: 6,
              currencies: '',
              suffixText: '',
              keyboardType: TextInputType.text,
              controller: _descriptionController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the description';
                }
                return null;
              },
            ),
            SizedBox(height: height * 0.02),
            _buildDocumentsSection(width, height),
            SizedBox(height: height * 0.02),
            _buildUploadButton(width, height),
          ],
        ),
      ),
    );
  }
}
