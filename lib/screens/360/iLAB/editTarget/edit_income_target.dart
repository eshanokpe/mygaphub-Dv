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
import 'show_success_modal.dart';

class EditIncomeTarget extends StatefulWidget {
  const EditIncomeTarget({super.key});

  @override
  State<EditIncomeTarget> createState() => _EditIncomeTargetState();
}

class _EditIncomeTargetState extends State<EditIncomeTarget> {
  Map data = {};
  DialogBox dialogBox = DialogBox();

  bool _isAnyFieldFocused = false;
  bool _isDirty = false;

  late FocusNode _portfolioFocusNode;
  late FocusNode _nonPortfolioFocusNode;

  late TextEditingController investContTargetValue;
  late TextEditingController equityContTargetValue;
  late TextEditingController savingsContTargetValue;
  late TextEditingController liabContTargetValue;
  late TextEditingController mortContTargetValue;
  late TextEditingController eduContTargetValue;
  late TextEditingController expContTargetValue;
  late TextEditingController disContTargetValue;
  late TextEditingController npContCurrentValue;
  late TextEditingController npContTargetValue;
  late TextEditingController apContCurrentValue;
  late TextEditingController apContTargetValue;

  late FormattedTextController portfolioTargetController;
  late FormattedTextController nonPortfolioTargetController;

  @override
  void initState() {
    super.initState();

    _portfolioFocusNode = FocusNode();
    _nonPortfolioFocusNode = FocusNode();

    _portfolioFocusNode.addListener(_onFocusChange);
    _nonPortfolioFocusNode.addListener(_onFocusChange);

    initializeControllers();
  }

  void _onFocusChange() {
    setState(() {
      _isAnyFieldFocused =
          _portfolioFocusNode.hasFocus || _nonPortfolioFocusNode.hasFocus;
      if (_isAnyFieldFocused) _isDirty = true;
    });
  }

  // ─── Reads `current` or `target` from the income array by key ────────────
  String _valueFromIncome(List<dynamic> incomeList, String key, String field) {
    for (final item in incomeList) {
      final map = Map<String, dynamic>.from(item as Map);
      if (map['key'] == key) {
        return map[field]?.toString() ?? '0';
      }
    }
    return '0';
  }

  void initializeControllers() {
    equityContTargetValue = TextEditingController();
    investContTargetValue = TextEditingController();
    savingsContTargetValue = TextEditingController();
    liabContTargetValue = TextEditingController();
    mortContTargetValue = TextEditingController();
    eduContTargetValue = TextEditingController();
    expContTargetValue = TextEditingController();
    disContTargetValue = TextEditingController();
    npContCurrentValue = TextEditingController();
    npContTargetValue = TextEditingController();
    apContCurrentValue = TextEditingController();
    apContTargetValue = TextEditingController();
    portfolioTargetController = FormattedTextController();
    nonPortfolioTargetController = FormattedTextController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        final providerData = context.read<Providers>().ilabdata;

        // ── Unwrap consistently with WheelPainterWidget ───────────────────
        // ilabdata holds responseData['data'] (the inner map).
        // Guard in case the full envelope was stored instead.
        if (providerData.isEmpty) return;

        final Map<String, dynamic> raw = (providerData['income'] != null)
            ? Map<String, dynamic>.from(providerData)
            : Map<String, dynamic>.from(providerData['data'] as Map? ?? {});

        data = raw;

        // ── Parse income array from new API structure ─────────────────────
        final List<dynamic> incomeList = raw['income'] != null
            ? List<dynamic>.from(raw['income'] as List)
            : [];

        // Format with 2 decimal places and thousands separator
        String formatNumber(String rawValue) {
          final num = double.tryParse(rawValue) ?? 0;
          return num.toStringAsFixed(2).replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          );
        }

        // ── Populate current value controllers ────────────────────────────
        // portfolio → apContCurrentValue
        apContCurrentValue.text = formatNumber(
          _valueFromIncome(incomeList, 'portfolio', 'current'),
        );

        // non_portfolio → npContCurrentValue
        npContCurrentValue.text = formatNumber(
          _valueFromIncome(incomeList, 'non_portfolio', 'current'),
        );

        // ── Populate target controllers if target is not null ─────────────
        final portfolioTarget = _valueFromIncome(
          incomeList,
          'portfolio',
          'target',
        );
        final nonPortfolioTarget = _valueFromIncome(
          incomeList,
          'non_portfolio',
          'target',
        );

        apContTargetValue.text = formatNumber(portfolioTarget);
        npContTargetValue.text = formatNumber(nonPortfolioTarget);

        portfolioTargetController.text = apContTargetValue.text;
        nonPortfolioTargetController.text = npContTargetValue.text;

        debugPrint(
          '[EditIncomeTarget] portfolio current: ${apContCurrentValue.text}, '
          'target: ${apContTargetValue.text}',
        );
        debugPrint(
          '[EditIncomeTarget] non_portfolio current: ${npContCurrentValue.text}, '
          'target: ${npContTargetValue.text}',
        );
      });
    });
  }

  @override
  void dispose() {
    _portfolioFocusNode.removeListener(_onFocusChange);
    _nonPortfolioFocusNode.removeListener(_onFocusChange);
    _portfolioFocusNode.dispose();
    _nonPortfolioFocusNode.dispose();

    npContCurrentValue.dispose();
    npContTargetValue.dispose();
    apContCurrentValue.dispose();
    apContTargetValue.dispose();
    portfolioTargetController.dispose();
    nonPortfolioTargetController.dispose();
    investContTargetValue.dispose();
    equityContTargetValue.dispose();
    savingsContTargetValue.dispose();
    liabContTargetValue.dispose();
    mortContTargetValue.dispose();
    eduContTargetValue.dispose();
    expContTargetValue.dispose();
    disContTargetValue.dispose();

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

      // ── Returns the numeric string or null if the value is empty/zero ───
      String? parseNumericValue(String value) {
        final clean = value.replaceAll(',', '').trim();
        if (clean.isEmpty) return null;
        final parsed = double.tryParse(clean);
        if (parsed == null || parsed == 0) return null;
        return clean.endsWith('.')
            ? clean.substring(0, clean.length - 1)
            : clean;
      }

      // ── Fall back to current value when target is empty or zero ───────────
      String resolveValue(String? targetParsed, String currentRaw) {
        if (targetParsed != null) return targetParsed;
        final clean = currentRaw.replaceAll(',', '').trim();
        if (clean.isEmpty) return '0';
        return clean.endsWith('.') ? clean.substring(0, clean.length - 1) : clean;
      }

      final portfolioTarget = parseNumericValue(portfolioTargetController.text);
      final nonPortfolioTarget = parseNumericValue(
        nonPortfolioTargetController.text,
      );

      final portfolioValue = resolveValue(
        portfolioTarget,
        apContCurrentValue.text,
      );
      final nonPortfolioValue = resolveValue(
        nonPortfolioTarget,
        npContCurrentValue.text,
      );

      debugPrint(
        '[EditIncomeTarget] Saving — '
        'portfolio: $portfolioValue, '
        'non_portfolio: $nonPortfolioValue',
      );

      final response = await http.post(
        url,
        body: {
          "portfolio": portfolioValue,
          "non_portfolio": nonPortfolioValue,
          "category": "income",
          "period": "current",
        },
        headers: {"Authorization": 'Bearer $token'},
      );

      debugPrint(
        '[EditIncomeTarget] POST ${response.statusCode}: ${response.body}',
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

          Fluttertoast.showToast(
            backgroundColor: const Color(0xff00B050),
            msg: 'iLab target has been updated',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
          );

          setState(() => _isDirty = false);

          final responseData = getResponse.data;
          if (responseData is Map &&
              (responseData['status'] == true ||
                  responseData['status'] == null)) {
            context.read<Providers>().setIlabdata(
              responseData['data'] ?? responseData,
            );

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
    String currency = context.watch<Providers>().snapshotmodel.currency;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                          "Income",
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

                  /// Portfolio Card
                  IncomeCard(
                    label: "Portfolio",
                    currentValue: "$currency${apContCurrentValue.text}",
                    targetController: portfolioTargetController,
                    currency: currency,
                    focusNode: _portfolioFocusNode,
                    showBorder: _portfolioFocusNode.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  /// Non Portfolio Card
                  IncomeCard(
                    label: "Non-Portfolio",
                    currentValue: "$currency${npContCurrentValue.text}",
                    targetController: nonPortfolioTargetController,
                    currency: currency,
                    focusNode: _nonPortfolioFocusNode,
                    showBorder: _nonPortfolioFocusNode.hasFocus,
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
}

// ─── IncomeCard ───────────────────────────────────────────────────────────────

class IncomeCard extends StatelessWidget {
  final String label;
  final String currentValue;
  final FormattedTextController targetController;
  final String currency;
  final FocusNode focusNode;
  final bool showBorder;

  const IncomeCard({
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
                colors: [Color(0xFFF6981E), Color(0xFFCA7708)],
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

          /// Current
          Text(
            "Current",
            style: TextStyle(
              color: AppColors.grayColor3,
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),
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

          /// Target
          const Text("Target", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),

          /// Target Input
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
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
