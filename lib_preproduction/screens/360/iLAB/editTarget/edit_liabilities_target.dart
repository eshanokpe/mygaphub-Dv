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

class EditLiabilitiesTarget extends StatefulWidget {
  const EditLiabilitiesTarget({super.key});

  @override
  State<EditLiabilitiesTarget> createState() => _EditLiabilitiesTargetState();
}

class _EditLiabilitiesTargetState extends State<EditLiabilitiesTarget> {
  Map data = {};
  DialogBox dialogBox = DialogBox();

  bool _isAnyFieldFocused = false;
  bool _isDirty = false;

  late FocusNode _creditFocusNode;
  late FocusNode _mortgageFocusNode;

  late TextEditingController investContTargetValue;
  late TextEditingController equityContTargetValue;
  late TextEditingController savingsContTargetValue;
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

  late FormattedTextController mortgageTargetController;
  late FormattedTextController creditTargetController;

  @override
  void initState() {
    super.initState();

    _creditFocusNode = FocusNode();
    _mortgageFocusNode = FocusNode();

    _creditFocusNode.addListener(_onFocusChange);
    _mortgageFocusNode.addListener(_onFocusChange);

    initializeControllers();
  }

  void _onFocusChange() {
    setState(() {
      _isAnyFieldFocused =
          _creditFocusNode.hasFocus || _mortgageFocusNode.hasFocus;
      if (_isAnyFieldFocused) _isDirty = true;
    });
  }

  // ─── Reads `current` or `target` from the liabilities array by key ────────
  String _valueFromLiabilities(
    List<dynamic> liabilitiesList,
    String key,
    String field,
  ) {
    for (final item in liabilitiesList) {
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
    mortgageTargetValue = TextEditingController();
    creditTargetValue = TextEditingController();

    mortgageTargetController = FormattedTextController();
    creditTargetController = FormattedTextController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        final providerData = context.read<Providers>().ilabdata;

        if (providerData.isEmpty) return;

        // ── Unwrap consistently with WheelPainterWidget ───────────────────
        final Map<String, dynamic> raw = (providerData['liabilities'] != null)
            ? Map<String, dynamic>.from(providerData)
            : Map<String, dynamic>.from(providerData['data'] as Map? ?? {});

        data = raw;

        // ── Parse liabilities array from new API structure ────────────────
        final List<dynamic> liabilitiesList = raw['liabilities'] != null
            ? List<dynamic>.from(raw['liabilities'] as List)
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
        liabCreditCurrentValue.text = formatNumber(
          _valueFromLiabilities(liabilitiesList, 'credit', 'current'),
        );
        mortgateCurrentValue.text = formatNumber(
          _valueFromLiabilities(liabilitiesList, 'mortgage', 'current'),
        );

        // ── Populate target controllers if target is not null ─────────────
        final creditTarget = _valueFromLiabilities(
          liabilitiesList,
          'credit',
          'target',
        );
        final mortgageTarget = _valueFromLiabilities(
          liabilitiesList,
          'mortgage',
          'target',
        );

        liabCreditTargetValue.text = formatNumber(creditTarget);
        mortgateTargetValue.text = formatNumber(mortgageTarget);

        creditTargetController.text = liabCreditTargetValue.text;
        mortgageTargetController.text = mortgateTargetValue.text;

        debugPrint(
          '[EditLiabilitiesTarget] credit current: ${liabCreditCurrentValue.text}, '
          'target: ${liabCreditTargetValue.text}',
        );
        debugPrint(
          '[EditLiabilitiesTarget] mortgage current: ${mortgateCurrentValue.text}, '
          'target: ${mortgateTargetValue.text}',
        );
      });
    });
  }

  @override
  void dispose() {
    _creditFocusNode.removeListener(_onFocusChange);
    _mortgageFocusNode.removeListener(_onFocusChange);
    _creditFocusNode.dispose();
    _mortgageFocusNode.dispose();

    npContCurrentValue.dispose();
    npContTargetValue.dispose();
    apContCurrentValue.dispose();
    apContTargetValue.dispose();
    mortgageTargetValue.dispose();
    creditTargetValue.dispose();
    investContTargetValue.dispose();
    equityContTargetValue.dispose();
    savingsContTargetValue.dispose();
    liabCreditCurrentValue.dispose();
    liabCreditTargetValue.dispose();
    mortgateTargetValue.dispose();
    mortgateCurrentValue.dispose();
    eduContTargetValue.dispose();
    expContTargetValue.dispose();
    disContTargetValue.dispose();
    mortgageTargetController.dispose();
    creditTargetController.dispose();

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

      // ── Returns the numeric string or null if value is empty/zero ───────
      String? parseNumericValue(String value) {
        final clean = value.replaceAll(',', '').trim();
        if (clean.isEmpty) return null;
        final parsed = double.tryParse(clean);
        if (parsed == null || parsed == 0) return null;
        return clean.endsWith('.') ? clean.substring(0, clean.length - 1) : clean;
      }

      // ── Falls back to current value when target is empty or zero ─────────
      String resolveValue(String? targetParsed, String currentRaw) {
        if (targetParsed != null) return targetParsed;
        final clean = currentRaw.replaceAll(',', '').trim();
        if (clean.isEmpty) return '0';
        return clean.endsWith('.') ? clean.substring(0, clean.length - 1) : clean;
      }

      final creditTarget = parseNumericValue(creditTargetController.text);
      final mortgageTarget = parseNumericValue(mortgageTargetController.text);

      final creditValue = resolveValue(
        creditTarget,
        liabCreditCurrentValue.text,
      );
      final mortgageValue = resolveValue(
        mortgageTarget,
        mortgateCurrentValue.text,
      );

      debugPrint(
        '[EditLiabilitiesTarget] Saving — '
        'credit: $creditValue, mortgage: $mortgageValue',
      );

      final response = await http.post(
        url,
        body: {
          "credit": creditValue,
          "mortgage": mortgageValue,
          "category": "liabilities",
          "period": "current",
        },
        headers: {"Authorization": 'Bearer $token'},
      );

      debugPrint(
        '[EditLiabilitiesTarget] POST ${response.statusCode}: ${response.body}',
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
            // Store only the inner data map — consistent with WheelPainterWidget
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
                          "Liabilities",
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

                  /// Credit Card
                  LiabilitiesCard(
                    label: "Credit",
                    currentValue: "$currency${liabCreditCurrentValue.text}",
                    targetController: creditTargetController,
                    currency: currency,
                    focusNode: _creditFocusNode,
                    showBorder: _creditFocusNode.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  /// Mortgage Card
                  LiabilitiesCard(
                    label: "Mortgage",
                    currentValue: "$currency${mortgateCurrentValue.text}",
                    targetController: mortgageTargetController,
                    currency: currency,
                    focusNode: _mortgageFocusNode,
                    showBorder: _mortgageFocusNode.hasFocus,
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

// ─── LiabilitiesCard ──────────────────────────────────────────────────────────

class LiabilitiesCard extends StatelessWidget {
  final String label;
  final String currentValue;
  final FormattedTextController targetController;
  final String currency;
  final FocusNode focusNode;
  final bool showBorder;

  const LiabilitiesCard({
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
                colors: [Color(0xFF7A009A), Color(0xFF420953)],
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
