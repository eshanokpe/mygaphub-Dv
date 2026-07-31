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

class EditBudgetTarget extends StatefulWidget {
  const EditBudgetTarget({super.key});

  @override
  State<EditBudgetTarget> createState() => _EditBudgetTargetState();
}

class _EditBudgetTargetState extends State<EditBudgetTarget> {
  DialogBox dialogBox = DialogBox();

  bool _isDirty = false;

  // ─── Display state variables — these drive the card UI ───────────────────
  String _periodicSavingDisplay = '0.00';
  String _educationDisplay = '0.00';
  String _expenditureDisplay = '0.00';
  String _discretionaryDisplay = '0.00';

  late FocusNode _periodicSaving;
  late FocusNode _education;
  late FocusNode _expenditure;
  late FocusNode _discretionary;

  // ─── Current value controllers ────────────────────────────────────────────
  late TextEditingController periodicSavingCurrentValue;
  late TextEditingController educationCurrentValue;
  late TextEditingController expenditureCurrentValue;
  late TextEditingController discretionaryCurrentValue;

  // ─── Formatted target controllers (bound to the input fields) ────────────
  late FormattedTextController periodicSavingTargetController;
  late FormattedTextController educationTargetController;
  late FormattedTextController expenditureTargetController;
  late FormattedTextController discretionaryTargetController;

  @override
  void initState() {
    super.initState();

    _periodicSaving = FocusNode();
    _education = FocusNode();
    _expenditure = FocusNode();
    _discretionary = FocusNode();

    _periodicSaving.addListener(_onFocusChange);
    _education.addListener(_onFocusChange);
    _expenditure.addListener(_onFocusChange);
    _discretionary.addListener(_onFocusChange);

    periodicSavingCurrentValue = TextEditingController();
    educationCurrentValue = TextEditingController();
    expenditureCurrentValue = TextEditingController();
    discretionaryCurrentValue = TextEditingController();

    periodicSavingTargetController = FormattedTextController();
    educationTargetController = FormattedTextController();
    expenditureTargetController = FormattedTextController();
    discretionaryTargetController = FormattedTextController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final raw = context.read<Providers>().ilabdata;
      if (raw.isEmpty) return;
      _applyResponseData(Map<String, dynamic>.from(raw));
    });
  }

  void _onFocusChange() {
    setState(() {
      if (_periodicSaving.hasFocus ||
          _education.hasFocus ||
          _expenditure.hasFocus ||
          _discretionary.hasFocus) {
        _isDirty = true;
      }
    });
  }

  // ─── Reads current/target from an array by key ───────────────────────────
  String _fromList(List<dynamic> list, String key, String field) {
    for (final item in list) {
      final m = Map<String, dynamic>.from(item as Map);
      if (m['key'] == key) return m[field]?.toString() ?? '0';
    }
    return '0';
  }

  // ─── Formats a raw numeric string ────────────────────────────────────────
  String _fmt(dynamic value) {
    if (value == null) return '0.00';
    final n = double.tryParse(value.toString()) ?? 0;
    return n
        .toStringAsFixed(2)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  // ─── Single method: populate controllers + display state from response ────
  // ilabdata stores the inner data map directly:
  // { income: [...], liabilities: [...], asset: [...], budget: [...] }
  void _applyResponseData(Map<String, dynamic> response) {
    // If the full response wrapper is present unwrap it, otherwise use as-is
    final dataMap = response.containsKey('data')
        ? Map<String, dynamic>.from(response['data'] as Map? ?? {})
        : response;
    final budgetList = List<dynamic>.from(dataMap['budget'] as List? ?? []);

    final periodicCurrent = _fromList(
      budgetList,
      'periodic_savings',
      'current',
    );
    final educationCurrent = _fromList(budgetList, 'education', 'current');
    final expenditureCurrent = _fromList(budgetList, 'expenditure', 'current');
    final discretionaryCurrent = _fromList(
      budgetList,
      'discretionary',
      'current',
    );

    final periodicTarget = _fromList(budgetList, 'periodic_savings', 'target');
    final educationTarget = _fromList(budgetList, 'education', 'target');
    final expenditureTarget = _fromList(budgetList, 'expenditure', 'target');
    final discretionaryTarget = _fromList(
      budgetList,
      'discretionary',
      'target',
    );

    setState(() {
      periodicSavingCurrentValue.text = _fmt(periodicCurrent);
      educationCurrentValue.text = _fmt(educationCurrent);
      expenditureCurrentValue.text = _fmt(expenditureCurrent);
      discretionaryCurrentValue.text = _fmt(discretionaryCurrent);

      periodicSavingTargetController.text = _fmt(periodicTarget);
      educationTargetController.text = _fmt(educationTarget);
      expenditureTargetController.text = _fmt(expenditureTarget);
      discretionaryTargetController.text = _fmt(discretionaryTarget);

      // These are the reactive state variables the cards actually read
      _periodicSavingDisplay = periodicSavingCurrentValue.text;
      _educationDisplay = educationCurrentValue.text;
      _expenditureDisplay = expenditureCurrentValue.text;
      _discretionaryDisplay = discretionaryCurrentValue.text;
    });

    debugPrint(
      '[EditBudgetTarget] periodic_savings current: ${periodicSavingCurrentValue.text}  target: ${periodicSavingTargetController.text}\n'
      '[EditBudgetTarget] education        current: ${educationCurrentValue.text}  target: ${educationTargetController.text}\n'
      '[EditBudgetTarget] expenditure      current: ${expenditureCurrentValue.text}  target: ${expenditureTargetController.text}\n'
      '[EditBudgetTarget] discretionary    current: ${discretionaryCurrentValue.text}  target: ${discretionaryTargetController.text}',
    );
  }

  @override
  void dispose() {
    _periodicSaving.removeListener(_onFocusChange);
    _education.removeListener(_onFocusChange);
    _expenditure.removeListener(_onFocusChange);
    _discretionary.removeListener(_onFocusChange);

    _periodicSaving.dispose();
    _education.dispose();
    _expenditure.dispose();
    _discretionary.dispose();

    periodicSavingCurrentValue.dispose();
    educationCurrentValue.dispose();
    expenditureCurrentValue.dispose();
    discretionaryCurrentValue.dispose();

    periodicSavingTargetController.dispose();
    educationTargetController.dispose();
    expenditureTargetController.dispose();
    discretionaryTargetController.dispose();

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

      String parseDecimalValue(String value) {
        final clean = value.replaceAll(',', '').trim();
        if (clean.isEmpty) return '0';

        final parsed = double.tryParse(clean) ?? 0;
        if (parsed == 0) return '0';

        if (clean.endsWith('.')) {
          return clean.substring(0, clean.length - 1);
        }

        return clean;
      }

      debugPrint(
        '[EditBudgetTarget] Saving — '
        'periodic_savings: ${parseDecimalValue(periodicSavingTargetController.text)}  '
        'education: ${parseDecimalValue(educationTargetController.text)}  '
        'expenditure: ${parseDecimalValue(expenditureTargetController.text)}  '
        'discretionary: ${parseDecimalValue(discretionaryTargetController.text)}',
      );

      final response = await http.post(
        url,
        body: {
          "period": "current",
          "category": "budget",
          "periodic_savings": parseDecimalValue(periodicSavingTargetController.text),
          "education": parseDecimalValue(educationTargetController.text),
          "expenditure": parseDecimalValue(expenditureTargetController.text),
          "discretionary": parseDecimalValue(discretionaryTargetController.text),
        },
        headers: {"Authorization": 'Bearer $token'},
      );

      debugPrint(
        '[EditBudgetTarget] POST ${response.statusCode}: ${response.body}',
      );

      if (response.statusCode == 400) {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
        dialogBox.information(context, "Status", 'Something went wrong');
        return;
      }

      if (response.statusCode == 200) {
        // ── GET fresh data with period=current ────────────────────────────
        final getResponse = await Dio().get(
          "$baseUrl/app/360/ilab?period=current",
          options: Options(headers: {"Authorization": 'Bearer $token'}),
        );

        if (!mounted) return;
        if (Navigator.canPop(context)) Navigator.pop(context);

        if (getResponse.statusCode == 200) {
          final responseData = Map<String, dynamic>.from(
            getResponse.data as Map,
          );

          if (responseData['status'] == true) {
            // Update provider with full response
            context.read<Providers>().setIlabdata(responseData);

            // Re-populate all controllers + display state from fresh response
            _applyResponseData(responseData);

            setState(() => _isDirty = false);
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
        }
      } else {
        if (mounted && Navigator.canPop(context)) Navigator.pop(context);
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
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Budget",
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

                  LiabilitiesCard(
                    label: "Savings Periodic",
                    currentValue: "$currency$_periodicSavingDisplay",
                    targetController: periodicSavingTargetController,
                    currency: currency,
                    focusNode: _periodicSaving,
                    showBorder: _periodicSaving.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  LiabilitiesCard(
                    label: "Education",
                    currentValue: "$currency$_educationDisplay",
                    targetController: educationTargetController,
                    currency: currency,
                    focusNode: _education,
                    showBorder: _education.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  LiabilitiesCard(
                    label: "Expenditure",
                    currentValue: "$currency$_expenditureDisplay",
                    targetController: expenditureTargetController,
                    currency: currency,
                    focusNode: _expenditure,
                    showBorder: _expenditure.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  LiabilitiesCard(
                    label: "Discretionary",
                    currentValue: "$currency$_discretionaryDisplay",
                    targetController: discretionaryTargetController,
                    currency: currency,
                    focusNode: _discretionary,
                    showBorder: _discretionary.hasFocus,
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

// ─── LiabilitiesCard ─────────────────────────────────────────────────────────

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
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFC61A24), Color(0xFF6A1116)],
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

          const Text("Target", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 8),

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
