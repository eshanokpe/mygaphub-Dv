import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:GapHub/screens/portfolio/braiditem.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/custom_input_field.dart';
import 'package:GapHub/widgets/custom_input_field_multistep.dart';
import 'package:GapHub/widgets/plus_button.dart';
import 'package:expandable/expandable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
import 'dart:convert';

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
  var document1;
  var document2;
  var document3;
  var document4;
  var document5;
  var document6;
  var document7;
  var document8;
  List documents = [];
  DialogBox dialogBox = DialogBox();
  TextEditingController docName = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController value = TextEditingController();
  TextEditingController income = TextEditingController();
  String? imgurl;
  Dio dio = Dio();
  final int _radioValue = 0;
  String asset = '-Select-';
  File? _image;

  @override
  void initState() {
    super.initState();
    imgurl = widget.data['data']["asset"]["photo_url"];
    var data = widget.data['data']["asset"];
    print("data:${data['automated_rate']}");
    name.text = data["name"];
    description.text = data["description"];
    document1 = data["document1"];

    if (document1 != null) {
      documents.add(document1);
    }
    document2 = data["document2"];
    if (document2 != null) {
      documents.add(document2);
    }
    document3 = data["document3"];
    if (document3 != null) {
      documents.add(document3);
    }
    document4 = data["document4"];
    if (document4 != null) {
      documents.add(document4);
    }
    document5 = data["document5"];
    if (document5 != null) {
      documents.add(document5);
    }
    document6 = data["document6"];
    if (document6 != null) {
      documents.add(document6);
    }
    document7 = data["document7"];
    if (document7 != null) {
      documents.add(document7);
    }
    document8 = data["document8"];
    if (document8 != null) {
      documents.add(document8);
    }
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.data['data']["asset"];
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    final picker = ImagePicker();
    File image;

    Future getImageCam() async {
      final pickedFile = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 50,
      );

      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
          print('_image:$image');
          updateImage(data, image);
        } else {}
      });
    }

    Future getImageGall() async {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
      );

      setState(() {
        if (pickedFile != null) {
          image = File(pickedFile.path);
          updateImage(data, image);
        } else {}
      });
    }

    var namea = "";
    File? file;

    Future getDocument() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      List ext = [".doc", ".docx", ".pdf", '.jpg'];
      String? fileName = result!.files.single.name;

      // namea = result.names.first.substring(result.names.first.length - 4);
      namea = fileName
          .substring(fileName.length - 4)
          .toLowerCase(); // Extract last 4 characters

      if (!ext.contains(namea)) {
        dialogBox.information(context, "Status", "Unsupported filetype");
      } else if (result != null) {
        setState(() {
          file = File(result.files.single.path!);
          updateDocument(data, file!);
        });
      } else {}
    }

    Future getPhotoLibrarylDoc() async {
      final XFile? pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery, // Opens photo library
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (pickedFile == null) return; // User canceled

      setState(() {
        file = File(pickedFile.path); // Convert XFile to File
      });
      await updateDocument(data, file!);
    }

    Widget topMenu() => GestureDetector(
      onTap: () {
        updateDetails(data);
      },
      child: Text(
        'Done',
        style: TextStyle(color: Colors.black, fontSize: width * .04),
      ),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Edit Details',
          style: TextStyle(color: AppColors.grayColor, fontSize: width * .04),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * .04),
            child: Row(children: [topMenu()]),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * .04),
        child: ListView(
          children: [
            SizedBox(height: height * .03),
            DisplayImage(
              imagePath: imgurl!,
              onPressed: () {
                _showBottomSheetImage(context, getImageCam, getImageGall);
              },
            ),
            SizedBox(height: height * .02),
            CustomInputField(
              label: 'Name',
              labelText: true,
              obscureText: false,
              keyboardType: TextInputType.text,
              controller: name,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Field cannot be empty";
                }
                return null;
              },
            ),
            SizedBox(height: height * .02),
            CustomInputFieldMultiStep(
              label: 'Description',
              image: '',
              maxLines: 6,
              currencies: '',
              suffixText: '',
              keyboardType: TextInputType.text,
              controller: description,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the amount';
                }
                return null;
              },
            ),
            SizedBox(height: height * .02),
            Center(
              child: Row(
                children: [
                  Text(
                    'Documents'.toUpperCase(),
                    style: TextStyle(
                      color: const Color(0xff808080),
                      fontSize: width * .04,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: height * .01),
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
                  padding: EdgeInsets.all(
                    width * .02,
                  ), // Added padding for better layout
                  child: Column(
                    children: <Widget>[
                      ExpansionTile(
                        leading: Image.asset(
                          'assets/images/pdf_icon.png',
                          width: width * .10,
                        ),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '${documents.length} Documents uploaded',
                              style: TextStyle(
                                fontSize: width * .04,
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
                              // Extract file extension (case-insensitive)
                              final String fileName = documents[index]["name"]
                                  .toString()
                                  .toLowerCase();
                              final bool isPDF = fileName.endsWith('.pdf');
                              final bool isImage =
                                  fileName.endsWith('.jpg') ||
                                  fileName.endsWith('.jpeg') ||
                                  fileName.endsWith('.png');
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: height * .005,
                                  horizontal: width * .05,
                                ),
                                child: Row(
                                  children: [
                                    Image.asset(
                                      isPDF
                                          ? 'assets/images/pdf1.png'
                                          : isImage
                                          ? 'assets/images/image_icon.png'
                                          : 'assets/images/pdf1.png', // Fallback for other types
                                      width: width * .10,
                                    ),
                                    SizedBox(width: width * .02),
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          launchDocu(
                                            "${documents[index]["document"]}",
                                          );
                                        },
                                        child: Text(
                                          "${documents[index]["name"]}",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: width * .04,
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
            SizedBox(height: height * .02),
            Padding(
              padding: EdgeInsets.only(left: width * .50),
              child: PlusButton(
                color: Colors.white,
                iconsColor: const Color(0xffEDAC5C),
                textColor: AppColors.blackColor,
                icons: Icons.add,
                text: 'Upload New',
                onPressed: () {
                  _showBottomSheet(context, getDocument, getPhotoLibrarylDoc);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateDetails(Map<String, dynamic> data) async {
    FocusScope.of(context).requestFocus(FocusNode());
    if (result != null && docName.text.isEmpty) {
      dialogBox.information(
        context,
        "Status",
        "Please provide a document name",
      );
      return;
    }
    var timer = Timer(const Duration(seconds: 30), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    dialogBox.waiting(context, "Loading");

    var url = "$baseUrl/app/portfolio/update/details/${data["id"]}";
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    Map body = {
      "asset_name": name.text,
      "asset_value": data["asset_value"],
      "portfolio_type": data['portfolio_type_id'],
      "automated_rate": data['automated'],
      "description": description.text,
    };

    print("body$body");

    try {
      final headers = {
        "Accept": "application/json",
        "Authorization": 'Bearer $token',
      };

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        timer.cancel();
        getItem(data["id"], data["asset_class"]);
        Fluttertoast.showToast(msg: 'Data updated successfully');
        Navigator.pop(context);
      } else {
        var body = jsonDecode(response.body);
        print("body:$body");
        timer.cancel();

        dialogBox.information(
          context,
          "Status",
          'Something went wrong, try again',
        );
        Navigator.pop(context);
      }
      print("here1: ${response.statusCode}");
      EasyLoading.dismiss();
    } catch (e) {
      EasyLoading.dismiss();
      print("here1: ${e.toString()}");

      timer.cancel();
      dialogBox.information(
        context,
        "Status",
        'Something went wrong, try again',
      );
    }
  }

  getItem(int id, String type) async {
    Timer timer = Timer(const Duration(seconds: 40), () {
      EasyLoading.dismiss();
      return;
    });

    var url = Uri.parse("$baseUrl/app/portfolio/$type/$id");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      timer.cancel();

      Navigator.push(
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
    } else {
      Fluttertoast.showToast(msg: "Error");
    }
    timer.cancel();
    EasyLoading.dismiss();
  }

  launchDocu(String url) async {
    var url0 = url;
    await canLaunch(url0) ? launch(url0) : Fluttertoast.showToast(msg: 'Error');
  }

  void _showBottomSheet(
    BuildContext context,
    VoidCallback getDoc,
    VoidCallback getImgGalDoc,
  ) {
    showModalBottomSheet(
      context: context,
      // isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Orientation orientation = MediaQuery.of(context).orientation;
        final height = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Divider(
                    color: const Color(0xffcdcdcd),
                    height: height * .02,
                    thickness: 5,
                    indent: width * .38,
                    endIndent: width * .38,
                  ),
                ),
              ),
              SizedBox(height: height * .02),
              ListTile(
                onTap: () {
                  getDoc();
                  Navigator.of(context).pop();
                },
                leading: Image.asset("assets/images/files_icon.png"),
                title: Text(
                  'Choose from files',
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  getImgGalDoc();

                  Navigator.of(context).pop();
                },
                leading: Image.asset(
                  "assets/images/gallery_icon.png",
                  width: width * .05,
                ),
                title: Text(
                  'Choose from photo library',
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
    VoidCallback getImgCam,
    VoidCallback getImgGal,
  ) {
    showModalBottomSheet(
      context: context,
      // isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        Orientation orientation = MediaQuery.of(context).orientation;
        final height = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height
            : MediaQuery.of(context).size.width;
        final width = orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.height;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Divider(
                    color: const Color(0xffcdcdcd),
                    height: height * .02,
                    thickness: 5,
                    indent: width * .38,
                    endIndent: width * .38,
                  ),
                ),
              ),
              SizedBox(height: height * .02),
              ListTile(
                onTap: () {
                  getImgGal();
                  Navigator.of(context).pop();
                },
                leading: Image.asset(
                  "assets/images/gallery_icon.png",
                  width: width * .05,
                ),
                title: Text(
                  'Choose from photo library',
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  getImgCam();
                  Navigator.of(context).pop();
                },
                leading: Image.asset(
                  "assets/images/files_icon.png",
                  width: width * .05,
                ),
                title: Text(
                  'Choose from files',
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                onTap: () {
                  Navigator.pop(context);
                },
                leading: Image.asset(
                  "assets/images/delete_red.png",
                  width: width * .05,
                ),
                title: Text(
                  'Remove current picture',
                  style: TextStyle(
                    color: const Color(0xffF50100),
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: height * 0.03),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateDocument(Map<String, dynamic> data, File file) async {
    print('File: $file');

    // Define API URL
    final String url = "$baseUrl/app/portfolio/update/details/${data["id"]}";
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('tokenDB');

    // Check if token exists
    if (token == null) {
      print('Authorization token not found');
      Fluttertoast.showToast(msg: 'Authorization token not found');
      return;
    }

    // Timeout handling
    Timer timeoutTimer = Timer(Duration(seconds: timeoutDuration), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
    });

    // Show loading dialog
    dialogBox.waiting(context, 'Loading');

    try {
      FormData formData;
      String filename = file.path.split('/').last;
      formData = FormData.fromMap({
        "asset_document": await MultipartFile.fromFile(
          file.path,
          filename: filename,
        ),
        "asset_document_name": filename.toString(),
        "asset_name": name.text,
        "asset_value": data["asset_value"],
        "portfolio_type": data['portfolio_type_id'],
        "automated_rate": data['automated'],
        "description": description.text,
      });

      var response = await dio.post(
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
        // timeoutTimer.cancel();
        print('Response Status: ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Document updated successfully');
        getItem(data["id"], data["asset_class"]);
        // Navigator.pop(context);
      } else {
        // timeoutTimer.cancel();
        print('Unexpected Response Status: ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Failed to update document');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Something went wrong');
      print('Error: $e');
    } finally {
      // Cleanup
      timeoutTimer.cancel();
      Navigator.pop(context);
    }
  }

  FilePickerResult? result;
  int timeoutDuration = 30;

  Future<void> updateImagee(Map<String, dynamic> data, File image) async {
    print('getImageGallDoc:');

    final String url = '$baseUrl/app/portfolio/update/photo/${data["id"]}';
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('tokenDB');

    if (token == null) {
      print('Authorization token not found');
      return;
    }

    Timer? timeoutTimer;
    try {
      // Start a timeout timer
      timeoutTimer = Timer(Duration(seconds: timeoutDuration), () {
        Navigator.pop(context);
        dialogBox.information(context, 'Status', 'Service timed out');
      });

      // Show waiting dialog
      dialogBox.waiting(context, 'Loading');

      // Prepare image upload data
      String filename = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: MediaType('image', 'jpg'),
        ),
      });

      // Send HTTP POST request
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token',
          },
        ),
      );

      // Handle response
      if (response.statusCode == 200) {
        print('Response Status: ${response.statusCode}');
        Fluttertoast.showToast(msg: 'Image upload successful');
        getItem(data["id"], data["asset_class"]);
      } else {
        print('Response Status: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());

      print('Error: ${e.toString()}');
    } finally {
      timeoutTimer!.cancel();
      Navigator.pop(context);
    }
  }

  Future<void> updateImage(Map<String, dynamic> data, File? image) async {
    print('🖼️ Updating Image...');

    if (image == null) {
      print('❌ No image selected');
      Fluttertoast.showToast(msg: 'No image selected');
      return;
    }

    final String url = '$baseUrl/app/portfolio/update/photo/${data["id"]}';
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('tokenDB');

    if (token == null) {
      print('❌ Authorization token not found');
      Fluttertoast.showToast(msg: 'Authorization token not found');
      return;
    }

    print('🔗 API Endpoint: $url');
    print('🔑 Authorization Token: $token');
    dialogBox.waiting(context, "Loading");

    Timer? timeoutTimer;
    try {
      // Start a timeout timer
      timeoutTimer = Timer(Duration(seconds: timeoutDuration), () {
        Fluttertoast.showToast(msg: 'Service timed out');
      });

      // Prepare image upload data
      String filename = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        "photo": await MultipartFile.fromFile(
          image.path,
          filename: filename,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      print('📸 Uploading Image: $filename');

      Dio dio = Dio();

      // Send HTTP POST request
      Response response = await dio.post(
        url,
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "Authorization": 'Bearer $token',
          },
          validateStatus: (status) =>
              true, // Prevent Dio from throwing an error
        ),
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📩 Response Data: ${response.data}');

      // Handle response
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: '✅ Image upload successful');
        getItem(data["id"], data["asset_class"]);
      } else {
        Fluttertoast.showToast(
          msg: '❌ Error ${response.statusCode}: ${response.data}',
        );
      }
    } catch (e) {
      print('🚨 Error: ${e.toString()}');
      Fluttertoast.showToast(msg: 'Something went wrong: ${e.toString()}');
    } finally {
      Navigator.pop(context);
      timeoutTimer?.cancel();
    }
  }
}
