import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:GapHub/models/loginusermodel.dart';
import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/screens/360/iLAB/I360LabScreen.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/screens/SEED/seedash/seedallocation/record_spend/recordspend.dart';
import 'package:GapHub/screens/SEED/seedash/seedash.dart';
import 'package:GapHub/screens/acquisition/favourites.dart';
import 'package:GapHub/screens/homepage/assistance/assistant.dart';
import 'package:GapHub/screens/more/feedbacks.dart';
import 'package:GapHub/screens/reminder/reminder.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart' as legacy;
import 'package:shared_preferences/shared_preferences.dart';

import '../acquisition/actionplan/presentation/action_plan_strategy.dart';
import 'support/Support.dart';

// ---------------------------------------Fto------------------------------------
// Riverpod Providers
// ---------------------------------------------------------------------------

/// Holds the auth token so it can be read anywhere without BuildContext.
final authTokenProvider = FutureProvider<String?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('tokenDB');
});

/// Lightweight state for the "loading" overlay shown on the More screen.
final moreLoadingProvider = StateProvider<bool>((ref) => false);

// ---------------------------------------------------------------------------
// More Screen
// ---------------------------------------------------------------------------

class More extends ConsumerStatefulWidget {
  const More({super.key});

  @override
  ConsumerState<More> createState() => _MoreState();
}

class _MoreState extends ConsumerState<More> {
  // ── Dependencies ────────────────────────────────────────────────────────
  final _picker = ImagePicker();
  final _dio = Dio();
  final _dialogBox = DialogBox();

  List<ReminderModel> _reminderList = [];

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    // Invalidate token cache on mount so it is always fresh.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(authTokenProvider);
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    final height = orientation == Orientation.portrait
        ? size.height
        : size.width;
    final width = orientation == Orientation.portrait
        ? size.width
        : size.height;

    // Image-url resolution (kept identical to original logic).
    String imgUrl = legacy.Provider.of<Providers>(
      context,
    ).details[7]; // legacy provider
    if (imgUrl.contains('/user/')) {
      imgUrl = imgUrl.replaceFirst('//app/', '/');
    } else if (imgUrl.contains('/avatar/')) {
      imgUrl = imgUrl.replaceFirst(
        'appstaging.mygaphub.com/app/assets/storage/app',
        'app/assets/storage/',
      );
    } else {
      imgUrl =
          'https://appstaging.mygaphub.com/assets/storage/avatar/default.png';
    }

    return WillPopScope(
      onWillPop: () async => _dialogBox.options(
        context,
        'Exit',
        'Are you sure you want to exit?',
        SystemNavigator.pop,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width * .03),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: height * .02),
              const _SectionTitle(title: 'Essential Tools'),
              _ToolGrid(
                crossAxisCount: 3,
                children: [
                  _ToolItem(
                    imagePath: 'assets/images/pie.png',
                    label: 'Seed',
                    onTap: _handleSeed,
                  ),
                  _ToolItem(
                    imagePath: 'assets/images/360.png',
                    label: '360',
                    onTap: _handleThreeSixty,
                  ),
                  _ToolItem(
                    imagePath: 'assets/images/king.png',
                    label: 'Strategy',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ActionPlanStrategy(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: height * .02),
              const _SectionTitle(title: 'Extras'),
              _ToolGrid(
                crossAxisCount: 3,
                children: [
                  _ToolItem(
                    imagePath: 'assets/images/bell.png',
                    label: 'Reminder',
                    onTap: _handleReminder,
                  ),
                  _ToolItem(
                    imagePath: 'assets/images/favourite.png',
                    label: 'Favourite',
                    onTap: _handleFavourites,
                  ),
                  _ToolItem(
                    imagePath: 'assets/images/feedback.png',
                    label: 'Feedback',
                    onTap: _handleFeedback,
                  ),
                  _ToolItem(
                    imagePath: 'assets/images/support.png',
                    label: 'Support',
                    onTap: _handleSupport,
                  ),
                  _ToolItem(
                    imagePath: 'assets/images/investor_hub.png',
                    label: 'InvestorHub',
                    onTap: () {},
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

  // ── Navigation helpers ───────────────────────────────────────────────────

  void _showDropdown() =>
      showDialog(context: context, builder: (_) => const _SelectDialog());

  // ── Action Handlers ──────────────────────────────────────────────────────

  Future<void> _handleFavourites() async {
    try {
      EasyLoading.show(status: 'Loading', dismissOnTap: false);
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/app/property/favourite');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final reap = body['data'] as List;
        legacy.Provider.of<Providers>(
          context,
          listen: false,
        ).setFavorites(reap);
        EasyLoading.dismiss();
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FavouritesPage()),
        );
      } else {
        throw Exception('Failed to load favourite assets');
      }
    } catch (_) {
      EasyLoading.dismiss();
      _showErrorToast('No Asset has been added to Favorite');
    }
  }

  Future<void> _handleSupport() async {
    final timer = _timeoutTimer(
      onTimeout: () =>
          _dialogBox.information(context, 'Status', 'Service timed out'),
    );
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/app/support');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data']['gap_supports']['data'] as List;
        context.read<Providers>().setSupport(data);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Support()),
        );
      } else {
        _showErrorToast('Something went wrong');
      }
    } finally {
      timer.cancel();
      EasyLoading.dismiss();
    }
  }

  Future<void> _handleFeedback() async {
    final timer = _timeoutTimer(
      onTimeout: () =>
          _dialogBox.information(context, 'Status', 'Service timed out'),
    );
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    try {
      final token = await _getToken();
      final url = Uri.parse('$baseUrl/app/support');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final data = body['data']['feedbacks']['data'] as List;
        context.read<Providers>().setFeedback(data);
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => Feedbacks()),
        );
      } else {
        _showErrorToast('Something went wrong');
      }
    } finally {
      timer.cancel();
      EasyLoading.dismiss();
    }
  }

  Future<void> _handleSeed() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/app/seed');
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final current = body['data']['current_detail']['total'];

      if (current == 1) {
        final timer = _timeoutTimer(
          onTimeout: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
            _dialogBox.information(context, 'Status', 'Service timed out');
          },
        );
        _dialogBox.waiting(context, 'Loading');

        final r2 = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );
        if (r2.statusCode == 200) {
          context.read<Providers>().setSeeData(jsonDecode(r2.body));
          timer.cancel();
          if (Navigator.canPop(context)) Navigator.pop(context);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Seedash()),
          );
        } else if (r2.statusCode == 500) {
          timer.cancel();
          if (Navigator.canPop(context)) Navigator.pop(context);
          _showErrorToast('Internal Server Error');
        } else {
          timer.cancel();
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      } else {
        EasyLoading.dismiss();
        _showDropdown();
      }
    }
  }

  /// NOTE: Logic is preserved exactly as provided. Only style/structure changed.
  Future<void> _handleThreeSixty() => threesixtyData();

  Future<void> _handleReminder() async {
    final currency = legacy.Provider.of<Providers>(
      context,
      listen: false,
    ).snapshotmodel.currency;
    final reminderProvider = legacy.Provider.of<ReminderProvider>(
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

  // ── threesixtyData — logic unchanged ────────────────────────────────────

  Future<void> threesixtyData() async {
    const timeoutDuration = Duration(seconds: 30);
    const loadingMessage = 'Loading';
    const timeoutMessage =
        'Connection timeout. Please check your internet connection.';
    const statusMessage = 'Network Error';
    const errorMessage = 'Something went wrong. Please try again.';

    if (!await _hasInternetConnection()) {
      _dialogBox.information(
        context,
        statusMessage,
        'Unable to connect to the internet. Please check your connection and try again.',
      );
      return;
    }

    var timer = Timer(timeoutDuration, () {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _dialogBox.information(context, statusMessage, timeoutMessage);
    });

    try {
      _dialogBox.waiting(context, loadingMessage);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      const urlTiles = '$baseUrl/app/360/tiles';
      const urlIncome =
          '$baseUrl/app/360/income?archive=0&header=&access=&account=&period=&income=&crd=&alo=';
      var urlLiability =
          '$baseUrl/app/360/liability?archive=0&header=&access=&account=&kpi=&crd=&alo=';

      final responseInc = await _dio.get(
        urlIncome,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (responseInc.statusCode == 200) {
        final responseData = responseInc.data;

        if (responseData is Map && responseData['status'] == true) {
          final incomeData = responseData['data'] as Map? ?? {};
          final assets = incomeData['portfolio_asset'] as List? ?? [];

          List<String> assetList = ['-Select-'];
          for (var asset in assets) {
            if (asset is Map && asset['isArchive'] != 1) {
              try {
                final name = asset['name']?.toString() ?? 'Unknown';
                final currency = asset['asset_currency']?.toString() ?? '';
                final monthlyRoi = asset['monthly_roi'];
                String roiFormatted = '0.00';
                if (monthlyRoi != null) {
                  roiFormatted = monthlyRoi is num
                      ? monthlyRoi.toStringAsFixed(2)
                      : monthlyRoi.toString();
                }
                assetList.add('$name ($currency$roiFormatted)');
              } catch (_) {
                continue;
              }
            }
          }

          context.read<Providers>().setAssets(assetList);
          context.read<Providers>().setMapAsset(assets);

          final incomeInfo = incomeData['income_info'] as Map? ?? {};
          final portfolioDiff = (incomeInfo['portfolio_diff'] is num)
              ? (incomeInfo['portfolio_diff'] as num).toDouble()
              : 0.0;
          context.read<Providers>().setPortfolioDiff(portfolioDiff);

          final responseTiles = await _dio.get(
            urlTiles,
            options: Options(
              headers: {'Authorization': 'Bearer $token'},
              validateStatus: (status) => status! < 500,
            ),
          );

          if (responseTiles.statusCode == 200) {
            final tilesData = responseTiles.data;
            if (tilesData is Map && tilesData['status'] == true) {
              final tilesContent = tilesData['data'] as Map? ?? {};
              context.read<Providers>().setRecent(tilesContent['tiles'] ?? []);
            } else {
              context.read<Providers>().setRecent([]);
            }

            var responseLiability = await _dio.get(
              urlLiability,
              options: Options(
                headers: {'Authorization': 'Bearer $token'},
                validateStatus: (status) => status! < 500,
              ),
            );

            timer.cancel();
            if (Navigator.canPop(context)) Navigator.pop(context);

            List<dynamic> sevengList = [];
            if (responseLiability.statusCode == 200) {
              final liabilityData = responseLiability.data;
              if (liabilityData is Map) {
                final src = liabilityData['status'] == true
                    ? (liabilityData['data'] as Map? ?? {})
                    : liabilityData;
                final sevengData = src['seveng'];
                if (sevengData is List) {
                  sevengList = sevengData;
                } else if (sevengData is Map) {
                  sevengList = [sevengData];
                }
              }
            }

            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Threesixty(data: sevengList),
                maintainState: true,
              ),
            );
          } else {
            throw Exception(
              'Failed to load tiles data. Status code: ${responseTiles.statusCode}',
            );
          }
        } else {
          throw Exception(
            "API returned error: ${responseInc.data['message'] ?? 'Unknown error'}",
          );
        }
      } else {
        throw Exception(
          'Failed to load income data. Status code: ${responseInc.statusCode}',
        );
      }
    } on DioException catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) Navigator.pop(context);
      _dialogBox.information(context, statusMessage, _getDioErrorMessage(e));
    } catch (e) {
      timer.cancel();
      if (Navigator.canPop(context)) Navigator.pop(context);
      _dialogBox.information(
        context,
        statusMessage,
        e.toString().contains('Exception')
            ? e.toString().replaceFirst('Exception: ', '')
            : errorMessage,
      );
    }
  }

  // ── iLab (unchanged logic, style only) ──────────────────────────────────

  Future<void> _iLabData() async {
    FocusScope.of(context).requestFocus(FocusNode());
    _dialogBox.waiting(context, 'Loading');

    try {
      final token = await _getToken();
      if (token == null) {
        if (Navigator.canPop(context)) Navigator.pop(context);
        _showSuccessToast('Authentication failed. Please log in again.');
        return;
      }

      final url = '$baseUrl/app/360/ilab';
      final response = await _dio.get(
        url,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (Navigator.canPop(context)) Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && (data['status'] == true || data['status'] == null)) {
          Fluttertoast.showToast(
            backgroundColor: const Color(0xff00B050),
            msg: data['message'] ?? 'iLab target has been set',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );
          context.read<Providers>().setIlabdata(data);
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const I360LabScreen()),
          );
        } else {
          _showErrorToast(data['message'] ?? 'Failed to set iLab target');
        }
      } else {
        _showErrorToast('Failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showErrorToast(_getDioErrorMessage(e));
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      _showErrorToast('An error occurred: $e');
    }
  }

  // ── Profile details ──────────────────────────────────────────────────────

  Future<void> _getDetails() async {
    final token = await _getToken();
    final url = Uri.parse('$baseUrl/app/profile');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    final editDetails = Editdetails.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );

    final p = legacy.Provider.of<Providers>(context, listen: false);
    p.setDetailsList(editDetails.user['firstname'], 0);
    p.setDetailsList(editDetails.user['surname'], 1);
    p.setDetailsList(editDetails.user['email'], 2);
    p.setDetailsList(editDetails.user['profile']['phone'], 3);
    p.setDetailsList(editDetails.user['profile']['date_of_birth'], 4);
    p.setDetailsList(editDetails.user['profile']['country'], 5);
    p.setDetailsList(editDetails.user['profile']['ancesry'], 6);

    String imgUrl = editDetails.user['profile']['image'] as String;
    imgUrl = imgUrl.replaceRange(0, 6, 'assets/storage');
    imgUrl = '$imgPrefix/$imgUrl';
    p.setDetailsList(imgUrl, 7);
  }

  // ── Utility methods ──────────────────────────────────────────────────────

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('tokenDB');
  }

  Timer _timeoutTimer({required VoidCallback onTimeout}) =>
      Timer(const Duration(milliseconds: 20000), onTimeout);

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.badCertificate:
        return 'Invalid SSL certificate. Please check your connection.';
      case DioExceptionType.badResponse:
        return 'Server error (${e.response?.statusCode}). Please try again later.';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your network settings.';
      case DioExceptionType.unknown:
        if (e.message?.contains('SocketException') ?? false) {
          return 'No internet connection. Please check your network settings.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }

  void _showErrorToast(String message) => Fluttertoast.showToast(
    backgroundColor: Colors.red,
    textColor: Colors.white,
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );

  void _showSuccessToast(String message) => Fluttertoast.showToast(
    backgroundColor: const Color(0xff00B050),
    textColor: Colors.white,
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
  );
}

// ---------------------------------------------------------------------------
// _SelectDialog  (was: Select)
// ---------------------------------------------------------------------------

class _SelectDialog extends ConsumerStatefulWidget {
  const _SelectDialog();

  @override
  ConsumerState<_SelectDialog> createState() => _SelectDialogState();
}

class _SelectDialogState extends ConsumerState<_SelectDialog> {
  final _dialogBox = DialogBox();

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    final height = orientation == Orientation.portrait
        ? size.height
        : size.width;
    final width = orientation == Orientation.portrait
        ? size.width
        : size.height;

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.only(bottom: height * .05),
      elevation: 5,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.cancel_outlined),
                highlightColor: Colors.pink,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            _DialogButton(
              label: 'Record Spend',
              width: width,
              onPressed: () => _handleRecordSpend(width),
            ),
            SizedBox(height: height * .01),
            _DialogButton(
              label: 'View Budget',
              width: width,
              onPressed: () => _handleViewBudget(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRecordSpend(double width) async {
    final url = Uri.parse('$baseUrl/app/seed');
    final timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      _dialogBox.information(context, 'Status', 'Service timed out');
    });
    _dialogBox.waiting(context, 'Loading');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      context.read<Providers>().setSeeData(jsonDecode(response.body));
      timer.cancel();
      Navigator.pop(context);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecordSpend(true)),
      );
    } else {
      timer.cancel();
      Navigator.pop(context);
      Fluttertoast.showToast(
        backgroundColor: Colors.red,
        textColor: Colors.white,
        msg: 'Internal Server Error',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  Future<void> _handleViewBudget() async {
    final url = Uri.parse('$baseUrl/app/seed');
    final timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      EasyLoading.dismiss();
      _dialogBox.information(context, 'Status', 'Service timed out');
    });
    EasyLoading.show(status: 'Loading', dismissOnTap: false);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final previewed = body['data']['current_seed']['priviewed'];
      final previousBudgets = body['data']['previous_budgets'];

      context.read<Providers>().setSeeData(body);
      timer.cancel();
      Navigator.pop(context);
      EasyLoading.dismiss();

      if (previewed == 0 && previousBudgets > 2) {
        showDialog(context: context, builder: (_) => _PreviewedDialog());
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Seedash()),
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
  }
}

// ---------------------------------------------------------------------------
// _PreviewedDialog  (was: Priviewed)
// ---------------------------------------------------------------------------

class _PreviewedDialog extends StatelessWidget {
  _PreviewedDialog();

  final _dio = Dio();
  final _dialogBox = DialogBox();

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    final height = orientation == Orientation.portrait
        ? size.height
        : size.width;
    final width = orientation == Orientation.portrait
        ? size.width
        : size.height;

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.only(top: width * .01),
      elevation: 5,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: height * .02),
            Text(
              'Budget from last month has been rolled over',
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: width * .04,
              ),
            ),
            SizedBox(height: height * .01),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DialogButton(
                  label: 'Make Changes',
                  width: width,
                  onPressed: () => _handleMakeChanges(context),
                ),
                Text(
                  'or',
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: width * .04,
                  ),
                ),
                _DialogButton(
                  label: 'Keep',
                  width: width,
                  onPressed: () => _handleKeep(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMakeChanges(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    final previewUrl = Uri.parse(
      '$baseUrl/app/seed?preview=7w6refsgwubjhsdbfgcyuxbhsjwdcfuhghvbqansmdbjhjnhjb',
    );
    final seedUrl = Uri.parse('$baseUrl/app/seed/');
    final timer = Timer(const Duration(milliseconds: 20000), () {
      Navigator.pop(context);
      EasyLoading.dismiss();
      _dialogBox.information(context, 'Status', 'Service timed out');
    });

    final r1 = await http.get(
      previewUrl,
      headers: {'Authorization': 'Bearer $token'},
    );
    if (r1.statusCode == 200) {
      final r2 = await http.get(
        seedUrl,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (r2.statusCode == 200) {
        context.read<Providers>().setSeeData(jsonDecode(r1.body));
        Fluttertoast.showToast(
          backgroundColor: Colors.green,
          textColor: Colors.white,
          msg: 'Rollover Changed',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
        timer.cancel();
        Navigator.pop(context);
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
    } else {
      EasyLoading.dismiss();
      Navigator.pop(context);
      Fluttertoast.showToast(msg: 'Error occurred');
    }
  }

  Future<void> _handleKeep(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('tokenDB');
    final url = Uri.parse(
      '$baseUrl/app/seed?preview=7w6refsgwubjhsdbfgcyuxbhsjwdcfuhghvbqansmdbjhjnhjb',
    );
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      Navigator.pop(context);
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const More()),
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
  }
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).orientation == Orientation.portrait
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

/// Wraps a GridView so callers do not need to repeat boilerplate.
class _ToolGrid extends StatelessWidget {
  final int crossAxisCount;
  final List<Widget> children;
  const _ToolGrid({required this.crossAxisCount, required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: crossAxisCount,
      shrinkWrap: true,
      crossAxisSpacing: 20,
      physics: const NeverScrollableScrollPhysics(),
      children: children,
    );
  }
}

/// Renamed from `ToolItem` and made private.
class _ToolItem extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const _ToolItem({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final size = MediaQuery.of(context).size;
    final height = orientation == Orientation.portrait
        ? size.height
        : size.width;
    final width = orientation == Orientation.portrait
        ? size.width
        : size.height;

    return GestureDetector(
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

/// Shared styled button used inside dialogs.
class _DialogButton extends StatelessWidget {
  final String label;
  final double width;
  final VoidCallback onPressed;

  const _DialogButton({
    required this.label,
    required this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xff7F7F7F),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(width * .01),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
          fontSize: width * .04,
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Public aliases kept for backwards compatibility with any existing imports.
// ---------------------------------------------------------------------------

/// @deprecated Use [_SelectDialog] internally. Kept public for any legacy nav pushes.
typedef Select = _SelectDialog;

/// @deprecated Use [_PreviewedDialog] internally.
typedef Priviewed = _PreviewedDialog;

/// @deprecated Use [_SectionTitle] internally.
typedef SectionTitle = _SectionTitle;

/// @deprecated Use [_ToolItem] internally.
typedef ToolItem = _ToolItem;
