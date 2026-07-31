import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:GapHub/models/notification_model.dart';
import 'package:GapHub/screens/SEED/seedash/historic_seed/historicdate.dart';
import 'package:GapHub/screens/acquisition/preacquisition.dart';
import 'package:GapHub/screens/analytics/kpistab.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../models/analyticsinfo.dart';
import '../../../provider/providers.dart';
import '../../../utils/httpErrorDisplay.dart';
import '../../360/threesixty.dart';
import '../../analytics/analytics.dart';
import '../../analytics/tab/bespoke_KPI.dart';
import '../../portfolio/portdashboard.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isLoading = false;

  Future<void> _handleSeedAction() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(height: 16.h),
                  const Text('Loading...'),
                ],
              ),
            ),
          ),
        ),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      // First API call: Get seed periods
      final seedUrl = Uri.parse("$baseUrl/app/seed/");
      final seedResponse = await http.get(
        seedUrl,
        headers: {
          "Authorization": 'Bearer $token',
          "Accept": "application/json",
        },
      );

      if (seedResponse.statusCode == 200) {
        final Map<String, dynamic> seedBody = jsonDecode(seedResponse.body);

        // Check if periods exists and handle both Map and List cases
        List<dynamic> periodsList = [];

        if (seedBody["data"] != null && seedBody["data"]['periods'] != null) {
          final periodsData = seedBody["data"]['periods'];

          if (periodsData is Map) {
            periodsList = periodsData.values.toList();
          } else if (periodsData is List) {
            periodsList = periodsData;
          }
        }

        // Extract date from notification received_at field
        final dateTime = widget.notification.receivedAt;
        final datePart =
            "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

        // Second API call: Get seed history for specific date
        final historyUrl = Uri.parse("$baseUrl/app/seed/history/$datePart");
        final historyResponse = await http.get(
          historyUrl,
          headers: {
            "Authorization": 'Bearer $token',
            "Accept": "application/json",
          },
        );

        // Close loading dialog
        if (mounted) Navigator.pop(context);

        if (historyResponse.statusCode == 200) {
          final Map<String, dynamic> historyData = jsonDecode(
            historyResponse.body,
          );

          // Navigate to HistoricDate screen
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HistoricDate(
                  historicdata: historyData,
                  date: datePart,
                  list: periodsList,
                ),
              ),
            );
          }
        } else {
          Fluttertoast.showToast(
            backgroundColor: Colors.red,
            textColor: Colors.white,
            msg: 'Failed to load seed history',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } else {
        if (mounted) Navigator.pop(context);
        Fluttertoast.showToast(
          backgroundColor: Colors.red,
          textColor: Colors.white,
          msg: 'Failed to load seed data',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      print('Error in seed action: $e');
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'An error occurred: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleAnalyticsAction() {
    final providers = context.read<Providers>();
    final sevenGees = providers.sevengeemodel.steps;

    // Safely parse values with fallback to 0.0
    double alpha = double.tryParse(sevenGees[6].toString()) ?? 0.0;
    double beta = double.tryParse(sevenGees[5].toString()) ?? 0.0;
    double credit = double.tryParse(sevenGees[4].toString()) ?? 0.0;
    double debt = double.tryParse(sevenGees[3].toString()) ?? 0.0;
    double education = double.tryParse(sevenGees[2].toString()) ?? 0.0;
    double freedom = double.tryParse(sevenGees[1].toString()) ?? 0.0;
    double grand = double.tryParse(sevenGees[0].toString()) ?? 0.0;
    final colors = context.select<Providers, List>(
      (p) => p.sevengeemodel.backgrounds,
    );
    Color _safeColor(String raw) {
      try {
        final cleaned = raw.replaceAll('#', '').trim();
        if (cleaned.length == 6) return Color(int.parse('0xff$cleaned'));
        if (cleaned.length == 8) return Color(int.parse('0x$cleaned'));
      } catch (_) {}
      return const Color(0xff000000);
    }

    final average =
        (alpha + beta + credit + debt + education + freedom + grand) / 7;
    final List<int> realColors = colors
        .map((e) => _safeColor(e.toString()).value)
        .toList();

    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    // Determine newUserAnalytics from provider or notification data
    // Adjust this based on where your source of truth lives

    bool newUserAnalytics = false;

    // Create the tab pages - matching Editpage structure exactly
    final tabPages = <Widget>[
      Analytics(
        key: const PageStorageKey('analyticsPage'),
        height: height,
        newUserAnalytics: newUserAnalytics,
        average: average,
        realColors: realColors,
        seriesData: const [],
        width: width,
      ),
      const BespokeKPI(key: PageStorageKey('bespokePage')),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Kpistab(
          tabPages: tabPages,
          height: height,
          width: width,
          contains: newUserAnalytics,
          fromSave: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: TextStyle(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              _shouldShowNotification(widget.notification)
                  ? widget.notification.title
                  : widget.notification.title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 5.h),
            _buildMetadataRowTime(
              icon: Icons.access_time_outlined,
              time: _formatDateTime(widget.notification.createdAt),
            ),

            SizedBox(height: 12.h),

            SizedBox(
              width: double.infinity,
              child: Text(
                widget.notification.message,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF272727),
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget? _buildBottomBar() {
    final action = widget.notification.action;

    // Handle seed action specially
    if (action == 'seed' || action == 'Seed') {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 46.h,
          top: 8.h,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleSeedAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
            ),
            label: Text(
              _isLoading ? 'Loading...' : 'View Seed History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Handle analytics action
    if (action == 'analytics' ||
        action == 'analytic' ||
        action == 'Analytics' ||
        action == 'Analytic') {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 46.h,
          top: 8.h,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton.icon(
            onPressed: _handleAnalyticsAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
            ),
            label: Text(
              'View Analytics',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Handle portfolio / pro folio action
    if (action == 'portfolio' ||
        action == 'pro folio' ||
        action == 'ProFolio') {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 46.h,
          top: 8.h,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Portdashboard()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
            ),
            label: Text(
              'View Portfolio',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Handle Acquisition action
    if (action == 'Acquisition' || action == 'acquisition') {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 46.h,
          top: 8.h,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Preacquisition(bottomNav: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
            ),
            label: Text(
              'View Acquisition',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Handle 360 action
    if (action == '360') {
      return Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          bottom: 46.h,
          top: 8.h,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 60.h,
          child: ElevatedButton.icon(
            onPressed: _handleThreeSixtyAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
            ),
            label: Text(
              'View 360 View',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      );
    }

    // Handle portfolio, new_feature, special_offer, settings, support, dashboard
    // and any other actions that have a URL to launch
    if (action != null && action.isNotEmpty) {
      // Check if we have a label to display
      final label = widget.notification.data?['label'];

      if (label != null && label.toString().isNotEmpty) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            bottom: 46.h,
            top: 8.h,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 60.h,
            child: ElevatedButton.icon(
              onPressed: () async {
                print("actions_category:${widget.notification.action}");
                try {
                  if (await canLaunch(action)) {
                    await launch(action);
                  } else {
                    Fluttertoast.showToast(
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      msg: 'Cannot open this link',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                } catch (e) {
                  print('Error opening URL: $e');
                  Fluttertoast.showToast(
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    msg: 'Error opening link',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 32.w),
              ),
              label: Text(
                label.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }
    }

    // No bottom bar for notifications without actionable content
    return null;
  }

  Widget _buildMetadataRowTime({required IconData icon, required String time}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.isNotEmpty
                      ? label[0].toUpperCase() + label.substring(1)
                      : label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty
                      ? value[0].toUpperCase() + value.substring(1)
                      : value,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final formatter = DateFormat('d MMMM yyyy, h:mma');
    return formatter.format(dateTime).toLowerCase();
  }

  bool _shouldShowNotification(NotificationModel notification) {
    final platform = notification.data?['platform'];

    if (platform == 'android' && Platform.isAndroid) {
      return true;
    }

    if (platform == 'ios' && Platform.isIOS) {
      return true;
    }

    // If no platform specified, show for all
    if (platform == null || platform.isEmpty) {
      return true;
    }

    return false;
  }

  // Helper to check internet connection
  Future<bool> _hasInternetConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Helper to handle Dio errors
  void _handleDioError(DioException error) {
    print("Dio Error: ${error.message}");
  }

  String _getDioErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'No internet connection. Please check your network settings.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  // The 360 Logic
  Future<void> _handleThreeSixtyAction() async {
    const timeoutDuration = Duration(seconds: 30);
    const loadingMessage = 'Loading';
    const statusMessage = 'Network Error';
    const errorMessage = 'Something went wrong. Please try again.';

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
      dialogBox.information(
        context,
        statusMessage,
        'Connection timeout. Please check your internet connection.',
      );
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

      // Initialize Dio if not already global
      final dio = Dio();

      // Fetch income data with error handling
      final responseInc = await dio
          .get(
            urlIncome,
            options: Options(
              headers: {"Authorization": 'Bearer $token'},
              validateStatus: (status) {
                return status! < 500;
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
              continue;
            }
          }
        }

        final incomeData = incomeResponse["incomes"] ?? [];
        final amounts = incomeData
            .map((income) => income["amount"]?.round() ?? 0)
            .toList();

        context.read<Providers>().setAssets(assetList);
        context.read<Providers>().setMapAsset(assets);

        final portfolioDiff =
            incomeResponse["income_info"]?["portfolio_diff"]?.toDouble() ?? 0;
        context.read<Providers>().setPortfolioDiff(portfolioDiff);

        // Fetch tiles data
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

          timer.cancel();

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
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
          throw Exception("Failed to load tiles data.");
        }
      } else {
        throw Exception("Failed to load income data.");
      }
    } on DioException catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      String errorMsg = _getDioErrorMessage(e);
      dialogBox.information(context, statusMessage, errorMsg);
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
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
}
