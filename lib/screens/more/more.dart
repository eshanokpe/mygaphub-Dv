import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/screens/SEED/seedash/seedallocation/record_spend/recordspend.dart';
import 'package:GapHub/screens/SEED/seedash/seedash.dart';
import 'package:GapHub/screens/acquisition/favourites.dart';
import 'package:GapHub/screens/more/feedbacks.dart';
import 'package:GapHub/screens/homepage/assistance/assistant.dart';
import 'package:GapHub/screens/reminder/reminder.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:GapHub/utils/constants.dart';
import '../../provider/reminderProvider.dart';
import 'support/Support.dart';

class More extends StatefulWidget {
  const More({super.key});

  @override
  _MoreState createState() => _MoreState();
}

class _MoreState extends State<More> {
  final picker = ImagePicker();
  Dio dio = Dio();
  DialogBox dialogBox = DialogBox();
  List<ReminderModel> reminderList = [];

  void dropdown(BuildContext context) {
    showDialog(context: context, builder: (context) => Select());
  }

  void priviewedModel(BuildContext context) {
    showDialog(context: context, builder: (context) => Priviewed());
  }

  List<String> todoList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _isLoading = true;
    });

    setState(() {
      _isLoading = false;
    });
    // navigateToLastPage();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    String imgurl = context.watch<Providers>().details[7];
    if (imgurl.contains('/user/')) {
      imgurl = imgurl.replaceFirst('//app/', '/');
      // print("image__DashboardHeader (User Image): $imgurl");
    } else if (imgurl.contains('/avatar/')) {
      imgurl = imgurl.replaceFirst(
        "appstaging.mygaphub.com/app/assets/storage/app",
        "app/assets/storage/",
      );
      // print("image__DashboardHeader (Avatar Image): $imgurl");
    } else {
      imgurl =
          'https://appstaging.mygaphub.com/assets/storage/avatar/default.png';
    }
    Future getImg() async {
      return Image.network(
        imgurl,
        width: width * .5,
        height: width * .5,
        fit: BoxFit.cover,
      );
    }

    pop() {
      SystemNavigator.pop();
    }

    return WillPopScope(
      onWillPop: () async {
        return await dialogBox.options(
          context,
          'Exit',
          'Are you sure you want to exit?',
          pop,
        );
      },
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: width * .03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: height * .02),
              SectionTitle(title: "Essential Tools"),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                crossAxisSpacing: 20,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ToolItem(
                    onTap: () async {
                      seedData();
                    },
                    imagePath: "assets/images/pie.png",
                    label: "Seed",
                  ),
                  ToolItem(
                    onTap: () async {
                      threesixtyData();
                    },
                    imagePath: "assets/images/360.png",
                    label: "360",
                  ),
                  ToolItem(
                    onTap: () async {
                      Navigator.of(context).pushNamed('Actionplan');
                    },
                    imagePath: "assets/images/king.png",
                    label: "Strategy",
                  ),
                ],
              ),
              SizedBox(height: height * .02),
              SectionTitle(title: "Extras "),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 20,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ToolItem(
                    onTap: () {
                      reminderData();
                    },
                    imagePath: "assets/images/bell.png",
                    label: "Reminder",
                  ),
                  ToolItem(
                    onTap: () => goToFavourites(context),
                    imagePath: "assets/images/favourite.png",
                    label: "Favourite",
                  ),
                  ToolItem(
                    onTap: () => goToFeedback(context),
                    imagePath: "assets/images/feedback.png",
                    label: "Feedback",
                  ),
                  ToolItem(
                    onTap: () => goToSupport(),
                    imagePath: "assets/images/support.png",
                    label: "Support",
                  ),
                  ToolItem(
                    onTap: () {},
                    imagePath: "assets/images/investor_hub.png",
                    label: "InvestorHub",
                  ),
                ],
              ),
              SizedBox(height: height * .05),
              const PersonallAssitance(),
              SizedBox(height: height * .02),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> goToFavourites(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading', dismissOnTap: false);

      final prefs = await SharedPreferences.getInstance();
      var token = prefs.getString('tokenDB');
      var url = Uri.parse("$baseUrl/app/property/favourite");
      // var url2 = Uri.parse("$baseUrl/app/property/favourite/ganp");

      var reapresponse = await http.get(
        url,
        headers: {"Authorization": 'Bearer $token'},
      );
      // var reapGanpresponse =
      //     await http.get(url2, headers: {"Authorization": 'Bearer $token'});
      print('favorite:${reapresponse.statusCode}');

      if (reapresponse.statusCode == 200) {
        var body = jsonDecode(reapresponse.body);
        List reap = body['data'];
        print('body:${body['data']}');
        Provider.of<Providers>(context, listen: false).setFavorites(reap);
        EasyLoading.dismiss();
        final route = MaterialPageRoute(
          builder: (ctx) => const FavouritesPage(),
        );
        await Navigator.push(context, route);
      } else {
        throw Exception("Failed to load favourite assets");
      }
    } catch (e) {
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'No Asset has been added to Favorite',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> goToSupport() async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/support");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);

      List data = body['data']['gap_supports']['data'];
      print(data);
      context.read<Providers>().setSupport(data);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Support()),
      );
      timer.cancel();
      EasyLoading.dismiss();
    } else {
      timer.cancel();
      EasyLoading.dismiss();

      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Something went wrong ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> goToFeedback(BuildContext context) async {
    var timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      dialogBox.information(context, 'Status', 'Service timed out');
      return;
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);
    var url = Uri.parse("$baseUrl/app/support");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);

      List data = body['data']['feedbacks']['data'];
      print(data);
      context.read<Providers>().setFeedback(data);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Feedbacks()),
      );
      timer.cancel();
      EasyLoading.dismiss();
    } else {
      timer.cancel();
      EasyLoading.dismiss();
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Something went wrong ',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future seedData() async {
    // dialogBox.waiting(context, "Loading");
    var url = Uri.parse("$baseUrl/app/seed");
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');
    var response = await http.get(
      url,
      headers: {"Authorization": 'Bearer $token'},
    );
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body);
      var current = body['data']['current_detail']['total'];
      print("current:$current");
      if (current == 1) {
        var url = Uri.parse("$baseUrl/app/seed");
        var timer = Timer(const Duration(milliseconds: 20000), () {
          Navigator.pop(context);
          dialogBox.information(context, 'Status', 'Service timed out');
          return;
        });
        dialogBox.waiting(context, 'Loading');
        final prefs = await SharedPreferences.getInstance();
        var token = prefs.getString('tokenDB');
        var response = await http.get(
          url,
          headers: {"Authorization": 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          var body = jsonDecode(response.body);

          context.read<Providers>().setSeeData(body);
          timer.cancel();
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Seedash()),
          );
        } else if (response.statusCode == 500) {
          timer.cancel();
          Navigator.pop(context);

          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: 'Internal Server Error',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        } else {
          timer.cancel();
          Navigator.pop(context);
        }
      } else {
        EasyLoading.dismiss();
        dropdown(context);
      }

      print('current_allocation: $current');
    }
    // dropdown(context);
  }

  Future<void> threesixtyData() async {
    const timeoutDuration = Duration(seconds: 30);
    const loadingMessage = 'Loading';
    const timeoutMessage =
        'Connection timeout. Please check your internet connection.';
    const statusMessage = 'Network Error';
    const errorMessage = 'Something went wrong. Please try again.';
    const noInternetMessage =
        'No internet connection. Please check your network settings.';

    // Check internet connectivity first
    if (!await _hasInternetConnection()) {
      dialogBox.information(
        context,
        statusMessage,
        'Unable to connect to the internet. Please check your connection and try again.',
      );
      return;
    }

    // Start a timeout timer
    var timer = Timer(timeoutDuration, () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the dialog box
      }
      dialogBox.information(context, statusMessage, timeoutMessage);
      return;
    });

    try {
      dialogBox.waiting(context, loadingMessage);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception("Authentication token not found. Please log in again.");
      }

      const urlTiles = "$baseUrl/app/360/tiles";
      const urlIncome = "$baseUrl/app/360/income";
      var urlLiability = "$baseUrl/app/360/liability";

      // Fetch income data with error handling
      final responseInc = await dio
          .get(
            urlIncome,
            options: Options(
              headers: {"Authorization": 'Bearer $token'},
              validateStatus: (status) {
                return status! < 500; // Accept any status code below 500
              },
            ),
          )
          .catchError((error) {
            if (error is DioException) {
              _handleDioError(error);
            }
            throw error;
          });

      if (responseInc.statusCode == 200) {
        final incomeResponse = responseInc.data;
        final assets = incomeResponse["portfolio_asset"] ?? [];

        List<String> assetList = ['-Select-'];
        for (var asset in assets) {
          if (asset["isArchive"] != 1) {
            try {
              final formattedAsset =
                  "${asset["name"]} (${asset["asset_currency"]}${asset["monthly_roi"].toStringAsFixed(2)})"
                      .replaceAllMapped(
                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                        (match) => '${match[1]},',
                      );
              assetList.add(formattedAsset);
            } catch (e) {
              // Skip problematic asset formatting
              continue;
            }
          }
        }

        final incomeData = incomeResponse["incomes"] ?? [];
        final amounts = incomeData
            .map((income) => income["amount"]?.round() ?? 0)
            .toList();
        final totalIncome = amounts.fold(0, (sum, amount) => sum + amount);

        context.read<Providers>().setAssets(assetList);
        context.read<Providers>().setMapAsset(assets);

        final portfolioDiff =
            incomeResponse["income_info"]?["portfolio_diff"]?.toDouble() ?? 0;
        context.read<Providers>().setPortfolioDiff(portfolioDiff);

        // Fetch tiles data with error handling
        final responseTiles = await dio
            .get(
              urlTiles,
              options: Options(
                headers: {"Authorization": 'Bearer $token'},
                validateStatus: (status) => status! < 500,
              ),
            )
            .catchError((error) {
              if (error is DioException) {
                _handleDioError(error);
              }
              throw error;
            });

        if (responseTiles.statusCode == 200) {
          context.read<Providers>().setRecent(
            responseTiles.data["tiles"] ?? [],
          );

          var responseLiability = await dio
              .get(
                urlLiability,
                options: Options(
                  headers: {"Authorization": 'Bearer $token'},
                  validateStatus: (status) => status! < 500,
                ),
              )
              .catchError((error) {
                if (error is DioException) {
                  _handleDioError(error);
                }
                throw error;
              });

          timer.cancel(); // Cancel the timer

          if (Navigator.canPop(context)) {
            Navigator.pop(context); // Close the dialog box
          }

          var seveng = responseLiability.data?["seveng"] ?? {};

          // Navigate to the next screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Threesixty(data: seveng),
              maintainState: true,
            ),
          );
        } else {
          throw Exception(
            "Failed to load tiles data. Status code: ${responseTiles.statusCode}",
          );
        }
      } else {
        throw Exception(
          "Failed to load income data. Status code: ${responseInc.statusCode}",
        );
      }
    } on DioException catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the dialog box
      }

      String errorMessage = _getDioErrorMessage(e);
      dialogBox.information(context, statusMessage, errorMessage);
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Close the dialog box
      }

      dialogBox.information(
        context,
        statusMessage,
        e.toString().contains("Exception")
            ? e.toString().replaceFirst("Exception: ", "")
            : errorMessage,
      );
    }
  }

  // Helper method to check internet connectivity
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // Helper method to handle Dio errors
  String _getDioErrorMessage(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';

      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';

      case DioExceptionType.badResponse:
        return 'Server error occurred. Please try again later.';

      case DioExceptionType.connectionError:
        return 'Network connection error. Please check your internet connection.';

      case DioExceptionType.unknown:
        if (error.message?.contains('Failed host lookup') == true) {
          return 'No internet connection. Please check your network settings.';
        }
        return 'An unexpected error occurred. Please try again.';

      default:
        return 'Network error occurred. Please try again.';
    }
  }

  // Helper method to handle Dio errors with logging
  void _handleDioError(DioException error) {
    print('DioException: ${error.type} - ${error.message}');
    // You can add analytics/logging here
  }

  Future reminderData() async {
    var currency = context.watch<Providers>().snapshotmodel.currency;

    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    reminderProvider.fetchReminders(currency);
    navigateWithSlideTransition(
      context: context,
      destinationScreen: const ReminderScreen(),
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  getdetails() async {
    var urlEditDetails = Uri.parse("$baseUrl/app/profile");
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString('tokenDB');

    await http
        .get(
          urlEditDetails,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        )
        .then((value) {
          Editdetails editdetails = Editdetails.fromJson(
            jsonDecode(value.body),
          );

          context.read<Providers>().setDetailsList(
            editdetails.user["firstname"],
            0,
          );
          context.read<Providers>().setDetailsList(
            editdetails.user["surname"],
            1,
          );
          context.read<Providers>().setDetailsList(
            editdetails.user["email"],
            2,
          );
          context.read<Providers>().setDetailsList(
            editdetails.user["profile"]["phone"],
            3,
          );
          context.read<Providers>().setDetailsList(
            editdetails.user["profile"]["date_of_birth"],
            4,
          );
          context.read<Providers>().setDetailsList(
            editdetails.user["profile"]["country"],
            5,
          );
          context.read<Providers>().setDetailsList(
            editdetails.user["profile"]["ancesry"],
            6,
          );
          String imgurl = editdetails.user["profile"]["image"];
          imgurl = imgurl.replaceRange(0, 6, 'assets/storage');
          imgurl = '$imgPrefix/$imgurl';

          context.read<Providers>().setDetailsList(imgurl, 7);
        });
  }
}

class Select extends StatefulWidget {
  const Select({super.key});

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  void priviewedModel(BuildContext context) {
    showDialog(context: context, builder: (context) => Priviewed());
  }

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
      insetPadding: EdgeInsets.zero,
      //titlePadding: EdgeInsets.only(top: width * .01),
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.only(
        top: 0,
        bottom: height * .05,
      ), // Adjust content padding
      elevation: 5,
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.cancel_outlined),
                      highlightColor: Colors.pink,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: () async {
                    var url = Uri.parse("$baseUrl/app/seed");
                    var timer = Timer(const Duration(milliseconds: 20000), () {
                      Navigator.pop(context);
                      dialogBox.information(
                        context,
                        'Status',
                        'Service timed out',
                      );
                      return;
                    });
                    dialogBox.waiting(context, 'Loading');
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('tokenDB');
                    var response = await http.get(
                      url,
                      headers: {"Authorization": 'Bearer $token'},
                    );
                    if (response.statusCode == 200) {
                      var body = jsonDecode(response.body);

                      context.read<Providers>().setSeeData(body);
                      timer.cancel();
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordSpend(true),
                        ),
                      );
                    } else {
                      timer.cancel();
                      Navigator.pop(context);
                      print("Error:${response.statusCode}");
                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: 'Internal Server Error',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                  child: Text(
                    "Record Spend",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                    ),
                  ),
                ),
                SizedBox(height: height * .01),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7F7F7F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(width * .01),
                    ),
                  ),
                  onPressed: () async {
                    var url = Uri.parse("$baseUrl/app/seed");
                    var timer = Timer(const Duration(milliseconds: 20000), () {
                      Navigator.pop(context);
                      EasyLoading.dismiss();
                      dialogBox.information(
                        context,
                        'Status',
                        'Service timed out',
                      );
                      return;
                    });
                    EasyLoading.show(status: 'Loading', dismissOnTap: false);
                    final prefs = await SharedPreferences.getInstance();
                    var token = prefs.getString('tokenDB');
                    var response = await http.get(
                      url,
                      headers: {"Authorization": 'Bearer $token'},
                    );
                    if (response.statusCode == 200) {
                      var body = jsonDecode(response.body);
                      var previwed = body['data']['current_seed']['priviewed'];
                      var previousBudget = body['data']['previous_budgets'];

                      if (previwed == 0 && previousBudget > 2) {
                        timer.cancel();
                        showDialog(
                          context: context,
                          builder: (context) => Priviewed(),
                        );
                        priviewedModel(context);
                        EasyLoading.dismiss();
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Seedash()),
                        );
                      } else {
                        //dialogBox.waiting(context, 'Loading');
                        print('previwed:$previwed');
                        context.read<Providers>().setSeeData(body);
                        timer.cancel();

                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Seedash()),
                        );
                        EasyLoading.dismiss();
                      }
                    } else if (response.statusCode == 500) {
                      timer.cancel();
                      Navigator.pop(context);

                      Fluttertoast.showToast(
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        msg: 'Internal Server Error',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      timer.cancel();
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    "View Budget",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: width * .04,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class Priviewed extends StatelessWidget {
  Dio dio = Dio();

  Priviewed({super.key});
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
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.only(top: width * .01),
      elevation: 5,
      content: StatefulBuilder(
        builder: (context, StateSetter setState) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: height * .02),
                Text(
                  "Budget from last month has been rolled over",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                    fontSize: width * .04,
                  ),
                ),
                SizedBox(height: height * .01),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7F7F7F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * .01),
                        ),
                      ),
                      onPressed: () async {
                        var url2 = Uri.parse(
                          "$baseUrl/app/seed?preview=7w6refsgwubjhsdbfgcyuxbhsjwdcfuhghvbqansmdbjhjnhjb",
                        );
                        var url3 = Uri.parse("$baseUrl/app/seed/");
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');
                        var timer = Timer(
                          const Duration(milliseconds: 20000),
                          () {
                            Navigator.pop(context);
                            EasyLoading.dismiss();
                            dialogBox.information(
                              context,
                              'Status',
                              'Service timed out',
                            );
                            return;
                          },
                        );
                        var response2 = await http.get(
                          url2,
                          headers: {"Authorization": 'Bearer $token'},
                        );
                        if (response2.statusCode == 200) {
                          var bodyy = jsonDecode(response2.body);
                          print("bodyyyy:$bodyy");

                          var response3 = await http.get(
                            url3,
                            headers: {"Authorization": 'Bearer $token'},
                          );
                          if (response3.statusCode == 200) {
                            var body = jsonDecode(response2.body);
                            context.read<Providers>().setSeeData(body);

                            Fluttertoast.showToast(
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                              msg: 'Rollover Changed',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                            Navigator.pop(context);
                            timer.cancel();
                            // Navigator.push(
                            //     context,
                            //     MaterialPageRoute(
                            //       builder: (context) => Setbudget(true),
                            //     ));
                          } else {
                            timer.cancel();
                            Fluttertoast.showToast(
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              msg: 'Something went wrong',
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }

                          // Fluttertoast.showToast(msg: "${data["message"]}");
                        } else {
                          EasyLoading.dismiss();
                          Navigator.pop(context);
                          Fluttertoast.showToast(msg: "Error occurred");
                        }
                      },
                      child: Text(
                        "Make Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: width * .04,
                        ),
                      ),
                    ),
                    Text(
                      "or",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                        fontSize: width * .04,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7F7F7F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(width * .01),
                        ),
                      ),
                      onPressed: () async {
                        var url2 = Uri.parse(
                          "$baseUrl/app/seed?preview=7w6refsgwubjhsdbfgcyuxbhsjwdcfuhghvbqansmdbjhjnhjb",
                        );
                        final prefs = await SharedPreferences.getInstance();
                        var token = prefs.getString('tokenDB');

                        var response2 = await http.get(
                          url2,
                          headers: {"Authorization": 'Bearer $token'},
                        );
                        if (response2.statusCode == 200) {
                          var bodyy = jsonDecode(response2.body);
                          print("bodyyyy:$bodyy");

                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => More()),
                          );
                          EasyLoading.dismiss();
                        } else {
                          Fluttertoast.showToast(
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            msg: 'Something went wrong',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                          );
                        }
                      },
                      child: Text(
                        "Keep",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: width * .04,
                        ),
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

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final height = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final width = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: width * .04, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class ToolItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const ToolItem({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onTap,
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
    return InkWell(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        color: const Color(0xffF2F2F2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: width * .09, height: height * .04),
            SizedBox(height: height * .01),
            Text(
              label,
              style: TextStyle(
                fontSize: width * .035,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
