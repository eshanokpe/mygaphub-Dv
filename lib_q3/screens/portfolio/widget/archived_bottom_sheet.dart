import 'dart:async';
import 'dart:convert';
import 'package:GapHub/models/snapshotmodel.dart';
import 'package:GapHub/screens/portfolio/braidetails.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ArchivedBottomSheet {
  static void show(BuildContext context, Map data, bool archived, String type) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
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
                leading: Container(
                  width: width * 0.10,
                  height: width * 0.10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xfff5f5f5), // Background color
                  ),
                  child: Image.asset(
                    "assets/images/recover_asset.png",
                    width: width * .08,
                  ),
                ),
                title: Text(
                  'Recover Asset',
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  print("recover:${data['data']["asset"]['name']}");
                  var assetName = data['data']["asset"]['name'];
                  addorremove(context, data, archived, assetName);

                  // Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Container(
                  width: width * 0.10,
                  height: width * 0.10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xfff5f5f5), // Background color
                  ),
                  child: Image.asset(
                    "assets/images/delete_asset.png",
                    width: width * .08,
                  ),
                ),
                title: Text(
                  'Permanently Delete Asset',
                  style: TextStyle(
                    fontSize: width * .04,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _showBottomSheetDeleteAsset(context, data, archived, type);
                },
              ),
              SizedBox(height: height * 0.03),
              CustomButton(
                text: 'Close',
                fontSize: 16.sp,
                isLoading: false,
                borderRadius: 30,
                borderColor: const Color(0xffC8CECC),
                onPressed: () {
                  Navigator.pop(context);
                },
                color: Colors.white,
                textColor: Colors.black,
              ),
              SizedBox(height: height * 0.05),
            ],
          ),
        );
      },
    );
  }
}

DialogBox dialogBox = DialogBox();
Dio dio = Dio();

void addorremove(
  BuildContext context,
  Map data,
  bool archived,
  String assetName,
) async {
  var timer = Timer(const Duration(milliseconds: 20000), () {
    Navigator.pop(context);
    dialogBox.information(context, 'Status', 'Service timed out');
    return;
  });
  dialogBox.waiting(context, "Loading");

  var url = archived
      ? "$baseUrl/app/portfolio/${data['data']["asset"]["asset_class"]}/${data['data']["asset"]["id"]}?header=pasjknmxjknjzkxnjxnjzhxnxcfdxajknknniojakn&access=atyhgujhashgbsxdhgvshgsghfgnbvjbsjkbvjbvjhdx&account=${data['data']["asset"]["id"]}"
      : "$baseUrl/app/portfolio/${data['data']["asset"]["asset_class"]}/${data['data']["asset"]["id"]}?header=pasjknmxjknjzkxnjxnjzhxnxcfdxajknknniojakn&access=uyaghgbshgbhsjxbhsjxbvbhxdbvdhgbvghdvcghvgdhcvhsnbhsb&account=${data['data']["asset"]["id"]}";
  print("archived:$archived");

  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenDB');
  var response = await dio.get(
    url,
    options: Options(headers: {"Authorization": 'Bearer $token'}),
  );

  if (response.statusCode == 200 && response.data["success"]) {
    try {
      getData(
        context,
        archived,
        "${data['data']["asset"]["asset_class"]}",
        "${data['data']["asset"]["asset_class"]}",
        true,
        assetName,
      );
      // Fluttertoast.showToast(
      //     msg: archived
      //         ? "Asset unarchived successfully"
      //         : "Asset archived successfully");
    } catch (e) {
      Navigator.pop(context);
    }
    timer.cancel();
  } else {
    timer.cancel();
    Navigator.pop(context);
  }
}

getData(
  BuildContext context,
  bool archived,
  String cap,
  String small,
  bool removal,
  String assetName,
) async {
  var url = Uri.parse("$baseUrl/app/portfolio/$small");
  var urlInc = "$baseUrl/app/360/income";

  final prefs = await SharedPreferences.getInstance();
  var token = prefs.getString('tokenDB');

  var response = await http.get(
    url,
    headers: {"Authorization": 'Bearer $token'},
  );
  if (response.statusCode == 200) {
    if (removal) {
      var responseInc = await dio.get(
        urlInc,
        options: Options(headers: {"Authorization": 'Bearer $token'}),
      );

      List assets = responseInc.data["portfolio_asset"];
      List<String> listofassets = ['-Select-'];
      for (var i = 0; i < assets.length; i++) {
        if (assets[i]["isArchive"] != 1) {
          listofassets.add(
            "${assets[i]["name"]} (${assets[i]["asset_currency"]}${assets[i]["monthly_roi"].toStringAsFixed(2)})"
                .replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                ),
          );
        }
      }
      context.read<Providers>().setAssets(listofassets);
      context.read<Providers>().setMapAsset(assets);
      var urlSnapshot = Uri.parse('$baseUrl/app/snapshot');

      final response3 = await http.get(
        urlSnapshot,
        headers: {"Authorization": 'Bearer $token'},
      );
      Snapshotmodel snapshotmodel = Snapshotmodel.fromJson(
        jsonDecode(response3.body),
      );
      context.read<Providers>().setSnapshot(snapshotmodel);
      context.read<Providers>().setCurrentPortfolio(
        snapshotmodel.financial["portfolio"],
      );

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      if (archived) {
        Navigator.pop(context);
      }
    }
    popUpMessage(context, cap, response, assetName);
  } else {
    Fluttertoast.showToast(msg: "Error");
  }
}

void _showBottomSheetDeleteAsset(
  BuildContext context,
  Map data,
  bool archived,
  String type,
) {
  showModalBottomSheet(
    context: context,
    // isDismissible: false,
    backgroundColor: Colors.white,
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
            Text(
              'Are you sure?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
            ),
            SizedBox(height: height * .01),
            Text(
              ' This asset will be permanently deleted and cannot be recovered.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.sp,
                color: AppColors.grayColor,
              ),
            ),
            SizedBox(height: height * 0.03),
            CustomButton(
              text: 'Delete Asset',
              fontSize: 16.sp,
              isLoading: false,
              borderRadius: 30,
              borderColor: const Color(0xffC8CECC),
              onPressed: () {
                print("data:${data['data']["asset"]['id']}");

                deleteAssets(context, data, archived, type);
              },
              color: Colors.white,
              textColor: Colors.black,
            ),
            SizedBox(height: height * .02),
            CustomButton(
              text: 'Cancel',
              fontSize: width * .040,
              isLoading: false,
              borderRadius: 30,
              borderColor: const Color(0xffC8CECC),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              color: AppColors.primaryColor,
              textColor: Colors.white,
            ),
            SizedBox(height: height * 0.05),
          ],
        ),
      );
    },
  );
}

Future<void> deleteAssets(
  BuildContext context,
  Map data,
  bool archived,
  String type,
) async {
  Timer? timer;
  try {
    timer = Timer(const Duration(seconds: 2), () {
      Navigator.pop(context); // Close any dialog
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });

    // Show loading dialog
    dialogBox.waiting(context, "Loading");

    // Prepare the URL and token
    final url = Uri.parse(
      "$baseUrl/app/portfolio/${data['data']["asset"]["id"]}",
    );

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    if (token == null) {
      timer.cancel();
      Navigator.pop(context);
      dialogBox.information(context, 'Error', 'Authentication token not found');
      return;
    }

    var response = await http.delete(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    print("response:${response.body}");
    var url2 = Uri.parse("$baseUrl/app/portfolio/$type");
    var response2 = await http.get(
      url2,
      headers: {"Authorization": 'Bearer $token'},
    );
    // Handle the response
    if (response.statusCode == 200) {
      timer.cancel(); // Cancel the timer on success
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Braidetails(type, jsonDecode(response2.body), false),
        ),
      );
      Fluttertoast.showToast(msg: "Asset deleted successfully");
    } else {
      var body = jsonDecode(response.body);
      timer.cancel();
      Navigator.pop(context); // Close loading dialog
      dialogBox.information(context, 'Error', '${body['message']}');
    }
  } catch (e) {
    timer?.cancel(); // Ensure the timer is canceled in case of an exception
    Navigator.pop(context); // Close loading dialog
    dialogBox.information(context, 'Error', 'An error occurred: $e');
  }
}

void popUpMessage(
  context,
  String cap,
  http.Response response,
  String assetName,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) =>
        SuccessAlertMessage(cap: cap, response: response, assetName: assetName),
  );
}

class SuccessAlertMessage extends StatelessWidget {
  final String cap;
  final http.Response response;
  final String assetName;

  const SuccessAlertMessage({
    super.key,
    required this.cap,
    required this.response,
    required this.assetName,
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 15),
      titlePadding: EdgeInsets.only(top: height * .02),
      backgroundColor: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * .04),
                    color: const Color(0xffFBFBFB),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        "assets/images/success.png",
                        height: height * .15,
                      ),
                      SizedBox(height: height * .01),
                    ],
                  ),
                ),
                SizedBox(height: height * .01),
                Text(
                  "Well done! You have Successfully recovered your $assetName Asset",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: width * .045,
                  ),
                ),
                SizedBox(height: height * .03),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Close',
                        fontSize: 16,
                        borderRadius: 30,
                        borderColor: const Color(0xffefefef),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Braidetails(
                                cap,
                                jsonDecode(response.body),
                                false,
                              ),
                            ),
                          );
                        },
                        color: Colors.white,
                        textColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
