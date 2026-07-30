import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../show_success_modal.dart';
import 'edit_asset_notifier.dart';

// ─── EditAssetTarget ──────────────────────────────────────────────────────────

class EditAssetTarget extends ConsumerStatefulWidget {
  const EditAssetTarget({super.key});

  @override
  ConsumerState<EditAssetTarget> createState() => _EditAssetTargetState();
}

class _EditAssetTargetState extends ConsumerState<EditAssetTarget> {
  // ── Controllers (UI concerns — live in the widget, not in Riverpod state) ──
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

    _initializeControllers();
  }

  void _onFocusChange() {
    final hasFocus = _investFocusNode.hasFocus ||
        _equityFocusNode.hasFocus ||
        _savingsFocusNode.hasFocus;

    // Delegate dirty tracking to the notifier.
    ref.read(editAssetProvider.notifier).onFocusChanged(hasFocus: hasFocus);

    // Still call setState so the border highlight rebuilds — purely visual.
    setState(() {});
  }

  void _initializeControllers() {
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

      _registerLegacyProviderCallbacks();

      final rawData = _readIlabDataFromContext();
      if (rawData == null) return;

      final values = ref
          .read(editAssetProvider.notifier)
          .populateFromProviderData(rawData);
      if (values == null) return;

      _applyPopulatedValues(values);
    });
  }

  void _registerLegacyProviderCallbacks() {
    ref.read(ilabDataUpdateCallbackProvider.notifier).state =
        (Map<dynamic, dynamic> freshData) {
      context.read<Providers>().setIlabdata(freshData);
    };
    ref.read(setTargetUpdateCallbackProvider.notifier).state =
        (Map<dynamic, dynamic> freshData) {
      context.read<Providers>().setSettarget(freshData);
    };
  }

  /// Reads ilabdata from the legacy Provider<Providers>.
  /// Replace / remove this once Provider is fully migrated.
  Map<dynamic, dynamic>? _readIlabDataFromContext() {
    try {
      // Import and use your existing Providers class here exactly as before:
        final data = context.read<Providers>().ilabdata;
        return data.isEmpty ? null : data;
      
      // ── Temporary shim (replace with real import): ──────────────────────
      // ignore: dead_code
      return null; // Replace this line with the real read shown above.
    } catch (_) {
      return null;
    }
  }

  /// Syncs TextEditingControllers with values computed by the notifier.
  void _applyPopulatedValues(PopulatedControllerValues v) {
    investContCurrentValue.text = v.investCurrentText;
    equityContCurrentValue.text = v.equityCurrentText;
    savingsContCurrentValue.text = v.cashCurrentText;

    investContTargetValue.text = v.investTargetText;
    equityContTargetValue.text = v.equityTargetText;
    savingsContTargetValue.text = v.cashTargetText;

    investTargetController.text = v.investTargetText;
    equityTargetController.text = v.equityTargetText;
    savingsTargetController.text = v.cashTargetText;
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

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> _saveTargets() async {
    FocusScope.of(context).requestFocus(FocusNode());

    // Show loading dialog — identical to original.
    _showWaitingDialog();

    final result = await ref.read(editAssetProvider.notifier).saveTargets(
          investTargetText: investTargetController.text,
          equityTargetText: equityTargetController.text,
          cashTargetText: savingsTargetController.text,
          investCurrentText: investContCurrentValue.text,
          equityCurrentText: equityContCurrentValue.text,
          cashCurrentText: savingsContCurrentValue.text,
        );

    if (!mounted) return;
    if (Navigator.canPop(context)) Navigator.pop(context); // dismiss loader

    if (result.isAuthError) {
      _showInfoDialog('Error', 'Authentication token not found');
      return;
    }

    if (result.isServerError) {
      _showInfoDialog('Status', result.errorMessage ?? 'Something went wrong');
      return;
    }

    if (result.isSuccess) {
      // Re-populate controllers with fresh server data.
      _applyPopulatedValues(result.populated!);

      await _handleSuccess();

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const SuccessModal(
          message: 'Your target position has been successfully saved.',
        ),
      );
    }
  }

  Future<void> _handleSuccess() async {
    final result =
        await ref.read(editAssetProvider.notifier).handleSuccess();

    if (!mounted) return;

    if (result.isSuccess) {
      return;
    }

    if (result.errorMessage != null) {
      _showError(result.errorMessage!);
    }
  }

  // ── Dialog helpers (identical to original) ────────────────────────────────

  void _showWaitingDialog() {
    // Mirrors dialogBox.waiting(context, "Loading")
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String msg) {
    Fluttertoast.showToast(
      backgroundColor: AppColors.expenditureColor,
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Watch only the fields actually used in the build tree.
    final isDirty = ref.watch(editAssetProvider.select((s) => s.isDirty));
    final investmentDisplay =
        ref.watch(editAssetProvider.select((s) => s.investmentDisplay));
    final homeEquityDisplay =
        ref.watch(editAssetProvider.select((s) => s.homeEquityDisplay));
    final cashDisplay =
        ref.watch(editAssetProvider.select((s) => s.cashDisplay));

    // currency still comes from Provider<Providers> until that is migrated.
    // Replace with a Riverpod provider when ready.
    // final currency = ref.watch(snapshotCurrencyProvider);
    const currency = '\$'; // ← swap out for your real provider read

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
                  if (isDirty)
                    GestureDetector(
                      onTap: _saveTargets,
                      child: Text(
                        'Save',
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
                          'Asset',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Edit your target positions',
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
                    label: 'Investments',
                    currentValue: '$currency$investmentDisplay',
                    targetController: investTargetController,
                    currency: currency,
                    focusNode: _investFocusNode,
                    showBorder: _investFocusNode.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  /// Home Equity Card
                  AssetCard(
                    label: 'Home Equity',
                    currentValue: '$currency$homeEquityDisplay',
                    targetController: equityTargetController,
                    currency: currency,
                    focusNode: _equityFocusNode,
                    showBorder: _equityFocusNode.hasFocus,
                  ),

                  SizedBox(height: 40.h),

                  /// Cash Card
                  AssetCard(
                    label: 'Cash',
                    currentValue: '$currency$cashDisplay',
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
}

// ─── AssetCard (unchanged) ────────────────────────────────────────────────────

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
          Text(
            'Current',
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
          const Text('Target', style: TextStyle(color: Colors.grey)),
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

// ─── FormattedTextController (unchanged) ─────────────────────────────────────

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