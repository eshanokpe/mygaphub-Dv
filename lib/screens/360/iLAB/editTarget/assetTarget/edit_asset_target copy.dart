import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../show_success_modal.dart';

class EditAssetTarget extends StatefulWidget {
  const EditAssetTarget({super.key});

  @override
  State<EditAssetTarget> createState() => _EditAssetTargetState();
}

class _EditAssetTargetState extends State<EditAssetTarget> {
  Map data = {};
  DialogBox dialogBox = DialogBox();

  bool _isAnyFieldFocused = false;
  bool _isDirty = false;

  // ─── State variables that drive the card UI ───────────────────────────────
  // These are set inside setState so the cards always rebuild with fresh values.
  String _investmentDisplay = '0.00';
  String _homeEquityDisplay = '0.00';
  String _cashDisplay = '0.00';

  late TextEditingController investContTargetValue;
  late TextEditingController investContCurrentValue;
  late TextEditingController equityContTargetValue;
  late TextEditingController equityContCurrentValue;
  late TextEditingController savingsContTargetValue;
  late TextEditingController savingsContCurrentValue;
  late TextEditingController liabCreditCurrentValue;
  late TextEditingController liabCreditTargetValue;
  late TextEditingController mortgateTargetValue;
  late TextEditingController mortgateCurrentValue;
  late TextEditingController eduContTargetValue;
  late TextEditingController expContTargetValue;
  late TextEditingController disContTargetValue;
  late TextEditingController npContCurrentValue;
  late TextEditingController npContTargetValue;
  late TextEditingController apContCurrentValue;
  late TextEditingController apContTargetValue;
  late TextEditingController mortgageTargetValue;
  late TextEditingController creditTargetValue;

  late FormattedTextController investTargetController;
  late FormattedTextController equityTargetController;
  late FormattedTextController savingsTargetController;

  late FocusNode _investFocusNode;
  late FocusNode _equityFocusNode;
  late FocusNode _savingsFocusNode;

  @override
  void initState() {
    super.initState();

    _investFocusNode = FocusNode();
    _equityFocusNode = FocusNode();
    _savingsFocusNode = FocusNode();

    _investFocusNode.addListener(_onFocusChange);
    _equityFocusNode.addListener(_onFocusChange);
    _savingsFocusNode.addListener(_onFocusChange);

    initializeControllers();
  }

  void _onFocusChange() {
    setState(() {
      _isAnyFieldFocused =
          _investFocusNode.hasFocus ||
          _equityFocusNode.hasFocus ||
          _savingsFocusNode.hasFocus;
      if (_isAnyFieldFocused) _isDirty = true;
    });
  }

  // ─── Reads `current` or `target` from the asset array by key ─────────────
  String _valueFromAsset(List<dynamic> assetList, String key, String field) {
    for (final item in assetList) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['key'] == key) {
        return map[field]?.toString() ?? '0';
      }
    }
    return '0';
  }

  // ─── Format a raw numeric string: 2 decimals + thousands separator ────────
  String _formatNumber(String rawValue) {
    final num = double.tryParse(rawValue) ?? 0;
    return num.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  // ─── Single method that populates ALL controllers from any response map ───
  // Called on initial load AND after a successful save so values always
  // reflect the latest server state.
  void _populateControllersFromData(Map<String, dynamic> raw) {
    data = raw;

    final List<dynamic> assetList = raw['asset'] != null
        ? List<dynamic>.from(raw['asset'] as List)
        : [];

    // ── Current values ────────────────────────────────────────────────────
    investContCurrentValue.text = _formatNumber(
      _valueFromAsset(assetList, 'investment', 'current'),
    );
    equityContCurrentValue.text = _formatNumber(
      _valueFromAsset(assetList, 'equity', 'current'),
    );
    savingsContCurrentValue.text = _formatNumber(
      _valueFromAsset(assetList, 'cash', 'current'),
    );

    // ── Update display state so the cards rebuild with the correct values ──
    _investmentDisplay = investContCurrentValue.text;
    _homeEquityDisplay = equityContCurrentValue.text;
    _cashDisplay = savingsContCurrentValue.text;

    // ── Target values ─────────────────────────────────────────────────────
    final investTarget = _valueFromAsset(assetList, 'investment', 'target');
    final equityTarget = _valueFromAsset(assetList, 'equity', 'target');
    final cashTarget = _valueFromAsset(assetList, 'cash', 'target');

    investContTargetValue.text = _formatNumber(investTarget);
    equityContTargetValue.text = _formatNumber(equityTarget);
    savingsContTargetValue.text = _formatNumber(cashTarget);

    investTargetController.text = investContTargetValue.text;
    equityTargetController.text = equityContTargetValue.text;
    savingsTargetController.text = savingsContTargetValue.text;

    debugPrint(
      '[EditAssetTarget] Controllers populated —\n'
      '  investment  current: ${investContCurrentValue.text}  target: ${investContTargetValue.text}\n'
      '  equity      current: ${equityContCurrentValue.text}  target: ${equityContTargetValue.text}\n'
      '  cash        current: ${savingsContCurrentValue.text}  target: ${savingsContTargetValue.text}',
    );
  }

  void initializeControllers() {
    investContTargetValue = TextEditingController();
    investContCurrentValue = TextEditingController();
    equityContTargetValue = TextEditingController();
    equityContCurrentValue = TextEditingController();
    savingsContTargetValue = TextEditingController();
    savingsContCurrentValue = TextEditingController();
    mortgageTargetValue = TextEditingController();
    creditTargetValue = TextEditingController();
    liabCreditCurrentValue = TextEditingController();
    liabCreditTargetValue = TextEditingController();
    mortgateTargetValue = TextEditingController();
    mortgateCurrentValue = TextEditingController();
    eduContTargetValue = TextEditingController();
    expContTargetValue = TextEditingController();
    disContTargetValue = TextEditingController();
    npContCurrentValue = TextEditingController();
    npContTargetValue = TextEditingController();
    apContCurrentValue = TextEditingController();
    apContTargetValue = TextEditingController();

    investTargetController = FormattedTextController();
    equityTargetController = FormattedTextController();
    savingsTargetController = FormattedTextController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final providerData = context.read<Providers>().ilabdata;
      if (providerData.isEmpty) return;

      debugPrint(
        '[EditAssetTarget] providerData keys: ${providerData.keys.toList()}',
      );
      debugPrint(
        '[EditAssetTarget] asset key present: ${providerData["asset"] != null}',
      );
      debugPrint(
        '[EditAssetTarget] data key present: ${providerData["data"] != null}',
      );

      // Walk every possible nesting level until we find the map that owns 'asset'
      Map<String, dynamic> raw = Map<String, dynamic>.from(providerData);

      if (raw['asset'] == null && raw['data'] is Map) {
        raw = Map<String, dynamic>.from(raw['data'] as Map);
      }

      if (raw['asset'] == null) {
        debugPrint(
          '[EditAssetTarget] WARNING: asset still null. raw keys: ${raw.keys.toList()}',
        );
      }

      setState(() => _populateControllersFromData(raw));
    });
  }

  @override
  void dispose() {
    _investFocusNode.removeListener(_onFocusChange);
    _equityFocusNode.removeListener(_onFocusChange);
    _savingsFocusNode.removeListener(_onFocusChange);

    _investFocusNode.dispose();
    _equityFocusNode.dispose();
    _savingsFocusNode.dispose();

    investContTargetValue.dispose();
    investContCurrentValue.dispose();
    equityContTargetValue.dispose();
    equityContCurrentValue.dispose();
    savingsContTargetValue.dispose();
    savingsContCurrentValue.dispose();
    npContCurrentValue.dispose();
    npContTargetValue.dispose();
    apContCurrentValue.dispose();
    apContTargetValue.dispose();
    mortgageTargetValue.dispose();
    creditTargetValue.dispose();
    liabCreditCurrentValue.dispose();
    liabCreditTargetValue.dispose();
    mortgateTargetValue.dispose();
    mortgateCurrentValue.dispose();
    eduContTargetValue.dispose();
    expContTargetValue.dispose();
    disContTargetValue.dispose();

    investTargetController.dispose();
    equityTargetController.dispose();
    savingsTargetController.dispose();

    super.dispose();
  }

  Future<void> _saveTargets() async {
    FocusScope.of(context).requestFocus(FocusNode());
    dialogBox.waiting(context, "Loading");

    try {
      final url = Uri.parse("$baseUrl/app/360/ilab");
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        dialogBox.information(
          context,
          "Error",
          "Authentication token not found",
        );
        return;
      }

      // Returns rounded int string, or null if value is empty / zero
      String? parseToIntOrNull(String value) {
        final clean = value.replaceAll(',', '').trim();
        if (clean.isEmpty) return null;
        final parsed = double.tryParse(clean) ?? 0;
        if (parsed == 0) return null;
        return parsed.round().toString();
      }

      // Falls back to the current controller value when target is empty or zero
      String resolveValue(
        String? targetParsed,
        TextEditingController currentCtrl,
      ) {
        if (targetParsed != null) return targetParsed;
        final clean = currentCtrl.text.replaceAll(',', '').trim();
        final current = double.tryParse(clean) ?? 0;
        return current.round().toString();
      }

      final investTarget = parseToIntOrNull(investTargetController.text);
      final equityTarget = parseToIntOrNull(equityTargetController.text);
      final cashTarget = parseToIntOrNull(savingsTargetController.text);

      // Resolve final POST values directly from current controllers as fallback
      final investValue = resolveValue(investTarget, investContCurrentValue);
      final equityValue = resolveValue(equityTarget, equityContCurrentValue);
      final cashValue = resolveValue(cashTarget, savingsContCurrentValue);

      debugPrint(
        '[EditAssetTarget] Saving — '
        'investment: $investValue, equity: $equityValue, cash: $cashValue',
      );

      final response = await http.post(
        url,
        body: {
          "investment": investValue,
          "equity": equityValue,
          "cash": cashValue,
          "category": "asset",
          "period": "current",
        },
        headers: {"Authorization": 'Bearer $token'},
      );

      debugPrint(
        '[EditAssetTarget] POST ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 400) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        dialogBox.information(context, "Status", 'Something went wrong');
        return;
      }

      if (response.statusCode == 200) {
        final getResponse = await Dio().get(
          "$baseUrl/app/360/ilab?period=current",
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (!mounted) return;

        if (getResponse.statusCode == 200) {
          if (Navigator.canPop(context)) Navigator.pop(context);

          final responseData = getResponse.data;

          if (responseData is Map &&
              (responseData['status'] == true ||
                  responseData['status'] == null)) {
            // Unwrap inner data map — same pattern as WheelPainterWidget
            final Map<String, dynamic> freshData = Map<String, dynamic>.from(
              responseData['data'] ?? responseData,
            );

            // ── Update provider with fresh server data ────────────────────
            context.read<Providers>().setIlabdata(freshData);

            setState(() {
              _populateControllersFromData(freshData);
              _isDirty = false;
            });
            _handleSuccess();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const SuccessModal(
                message: "Your target position has been successfully saved.",
              ),
            ); 
          } else {
            Fluttertoast.showToast(
              backgroundColor: Colors.red,
              msg:
                  responseData['message']?.toString() ??
                  'Failed to set iLab target',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
            );
          }
        } else {
          if (Navigator.canPop(context)) Navigator.pop(context);
        }
      } else {
        if (Navigator.canPop(context)) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted && Navigator.canPop(context)) Navigator.pop(context);
      if (mounted) {
        dialogBox.information(
          context,
          "Error",
          'An error occurred: ${e.toString()}',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = context.watch<Providers>().snapshotmodel.currency;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          surfaceTintColor: Colors.transparent,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_isDirty)
                    GestureDetector(
                      onTap: _saveTargets,
                      child: Text(
                        "Save",
                        style: GoogleFonts.nunitoSans(
                          color: const Color(0xff0FB707),
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Asset",
                          style: GoogleFonts.nunitoSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Edit your target positions",
                          style: TextStyle(
                            color: const Color(0xff393737),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),

                  /// Investments Card
                  AssetCard(
                    label: "Investments",
                    currentValue: "$currency$_investmentDisplay",
                    targetController: investTargetController,
                    currency: currency,
                    focusNode: _investFocusNode,
                    showBorder: _investFocusNode.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  /// Home Equity Card
                  AssetCard(
                    label: "Home Equity",
                    currentValue: "$currency$_homeEquityDisplay",
                    targetController: equityTargetController,
                    currency: currency,
                    focusNode: _equityFocusNode,
                    showBorder: _equityFocusNode.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  /// Cash Card
                  AssetCard(
                    label: "Cash",
                    currentValue: "$currency$_cashDisplay",
                    targetController: savingsTargetController,
                    currency: currency,
                    focusNode: _savingsFocusNode,
                    showBorder: _savingsFocusNode.hasFocus,
                  ),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  
  bool _isLoading = false;

  void _showError(String msg) {
    if (mounted) setState(() => _isLoading = false);
    Fluttertoast.showToast(
      backgroundColor: AppColors.expenditureColor,
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  String _dioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Request timed out. Please check your connection.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please try again.';
      default:
        return e.response?.data?['message']?.toString() ??
            'Something went wrong. Please try again.';
    }
  }
  
  Future<void> _handleSuccess() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('tokenDB');

      if (token == null) {
        _showError('Authentication failed. Please log in again.');
        return;
      }

      final response = await Dio().get(
        "$baseUrl/app/360/ilab?period=current",
        options: Options(
          headers: {"Authorization": 'Bearer $token'},
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData is Map &&
            (responseData['status'] == true ||
                responseData['status'] == null)) {
          // Store only the inner data map — consistent with how
          // WheelPainterWidget and I360LabScreen read from the provider
          final Map<dynamic, dynamic> freshData =
              responseData['data'] ?? responseData;
          context.read<Providers>().setIlabdata(freshData);
          context.read<Providers>().setSettarget(freshData);

          Navigator.pop(context);
          Navigator.pop(context);
        } else {
          _showError(
            responseData['message']?.toString() ?? 'Failed to load iLab data.',
          );
        }
      } else {
        _showError(
          'Request failed (${response.statusCode}). Please try again.',
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      _showError(_dioErrorMessage(e));
    } catch (_) {
      if (!mounted) return;
      _showError('An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

}

// ─── AssetCard ────────────────────────────────────────────────────────────────

class AssetCard extends StatelessWidget {
  final String label;
  final String currentValue;
  final FormattedTextController targetController;
  final String currency;
  final FocusNode focusNode;
  final bool showBorder;

  const AssetCard({
    super.key,
    required this.label,
    required this.currentValue,
    required this.targetController,
    required this.currency,
    required this.focusNode,
    required this.showBorder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEEEEE), width: 0.7),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// Label Badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF256825), Color(0xFF173C17)],
              ),
              borderRadius: BorderRadius.circular(57),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x29000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          /// Current label
          Text(
            "Current",
            style: TextStyle(
              color: AppColors.grayColor3,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),

          /// Current value display
          Builder(
            builder: (context) {
              String displayValue = currentValue;
              if (!displayValue.contains('.')) {
                displayValue = '$displayValue.00';
              }
              final parts = displayValue.split('.');

              return RichText(
                text: TextSpan(
                  style: GoogleFonts.nunitoSans(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  children: [
                    TextSpan(text: parts[0]),
                    TextSpan(
                      text: '.${parts[1]}',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff777777),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 16.h),

          /// Target label
          const Text("Target", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),

          /// Target input
          Container(
            height: 50.h,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: showBorder
                    ? const Color(0xFF272727)
                    : Colors.grey.shade300,
                width: showBorder ? 2.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Text(
                  currency,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextFormField(
                    controller: targetController,
                    focusNode: focusNode,
                    keyboardType: TextInputType.number,
                    cursorColor: Colors.black,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r',')),
                    ],
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      final raw = targetController.text.replaceAll(',', '');
                      final value = double.tryParse(raw) ?? 0;
                      if (value == 0) {
                        targetController.clear();
                      } else {
                        targetController.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: targetController.text.length,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FormattedTextController ──────────────────────────────────────────────────

class FormattedTextController extends TextEditingController {
  FormattedTextController() {
    addListener(_formatValue);
  }

  bool _isFormatting = false;

  void _formatValue() {
    if (_isFormatting) return;
    _isFormatting = true;

    final raw = text.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');

    if (raw.isEmpty) {
      _isFormatting = false;
      return;
    }

    final parts = raw.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? '.${parts[1]}' : '';

    String formatted = '';
    if (integerPart.isNotEmpty) {
      final number = int.tryParse(integerPart) ?? 0;
      formatted = number.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (m) => ',',
      );
    }

    final newText = '$formatted$decimalPart';

    if (newText != text) {
      value = value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }

    _isFormatting = false;
  }

  @override
  void dispose() {
    removeListener(_formatValue);
    super.dispose();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final text = this.text;
    if (text.contains('.')) {
      final parts = text.split('.');
      return TextSpan(
        style: style,
        children: [
          TextSpan(
            text: parts[0],
            style: GoogleFonts.nunitoSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          TextSpan(
            text: '.${parts[1]}',
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xff777777),
            ),
          ),
        ],
      );
    }
    return TextSpan(text: text, style: style);
  }
}
