import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../edit_protectionItem.dart';
import 'protection_item_model.dart';
import 'protection_item_provider.dart';
import 'widget/summaryCard.dart';
import '../../../widget/topBar.dart';

class Protectionitem extends ConsumerStatefulWidget {
  final Map<String, dynamic> item;
  final String imagePath;
  final List<String> gradientColors;
  final bool archived;

  const Protectionitem({
    super.key,
    required this.item,
    required this.imagePath,
    required this.gradientColors,
    this.archived = false,
  });

  @override
  ConsumerState<Protectionitem> createState() => _ProtectionitemState();
}

class _ProtectionitemState extends ConsumerState<Protectionitem> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(protectionItemProvider.notifier).load(widget.item);
    });
  }

  List<Color> get _gradientColors =>
      widget.gradientColors.map((s) => Color(int.parse(s))).toList();

  @override
  Widget build(BuildContext context) {
    final asyncItem = ref.watch(protectionItemProvider);
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: const Color(0xffffffff),
      body: SafeArea(
        child: Column(
          children: [
            TopBar(
              onBack: () => Navigator.pop(context),
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProtectionItem(),
                  ),
                );
              },
            ),

            Expanded(
              child: asyncItem.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    'Something went wrong.\n$e',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                data: (item) => _ProtectionItemBody(
                  item: item,
                  currency: currency,
                  gradientColors: _gradientColors,
                  imagePath: widget.imagePath,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Body ──────────────────────────────────────────────────────────────────────

class _ProtectionItemBody extends StatelessWidget {
  final ProtectionItemModel item;
  final String currency;
  final List<Color> gradientColors;
  final String imagePath;

  const _ProtectionItemBody({
    required this.gradientColors,
    required this.imagePath,
    required this.item,
    required this.currency,
  });

  /// ✅ Extract only the symbol from full format like "$ USD", "₦ NGN"
  String _getCurrencySymbol(String fullCurrency) {
    final trimmed = fullCurrency.trim();
    final parts = trimmed.split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  String _formatNumber(String? valueStr) {
    if (valueStr == null || valueStr.isEmpty) return '0';
    final numValue = num.tryParse(valueStr) ?? 0;
    return NumberFormat('#,###').format(numValue);
  }

  @override
  Widget build(BuildContext context) {
    // Get clean symbol from item's currency
    final currencySymbol = _getCurrencySymbol(item.currency ?? '');

    return SingleChildScrollView(
      padding: EdgeInsets.all(12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryCard(imagePath: imagePath, item: item),

          SizedBox(height: 4.h),

          const _SectionLabel('Sum Assured'),
          _AmountRow(
            currencySymbol: currencySymbol,
            whole: _formatNumber(item.sumAssuredWhole),
            decimal: item.sumAssuredDecimal,
          ),

          const _SectionLabel('Premium'),
          _AmountRow(
            currencySymbol: currencySymbol,
            whole: _formatNumber(item.premiumWhole),
            decimal: item.premiumDecimal,
            suffix:
                'per ${item.payFrequency.toLowerCase() == 'annually' ? 'Year' : 'Month'}',
          ),

          if (item.bank != null && item.bank!.isNotEmpty) ...[
            const _SectionLabel('Bank'),
            _FieldBox(item.bank!),
          ],

          const _SectionLabel('Payment Type'),
          _FieldBox(item.paymentTypeLabel),

          const _SectionLabel('Cover Start'),
          _FieldBox(item.formattedCoverStart),

          const _SectionLabel('Cover End'),
          _FieldBox(item.formattedCoverEnd),

          if (item.document != null && item.document!.isNotEmpty) ...[
            const _SectionLabel('Uploaded Document'),
            _DocumentRow(
              name: item.documentFileName,
              documentUrl: item.documentUrl,
            ),
          ],
          SizedBox(height: 50.h),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProtectionItem(),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/wheel_segments/pencil_alt_red.png',
                  width: 20.w,
                  height: 20.w,
                  color: AppColors.primaryColor,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Edit Information',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h, bottom: 6.h),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: const Color(0xff888888),
        ),
      ),
    );
  }
}

// ✅ Updated _AmountRow to use symbol only
class _AmountRow extends StatelessWidget {
  final String currencySymbol;
  final String whole;
  final String decimal;
  final String? suffix;

  const _AmountRow({
    required this.currencySymbol,
    required this.whole,
    required this.decimal,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$currencySymbol$whole',
                style: GoogleFonts.nunitoSans(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              TextSpan(
                text: '.$decimal',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff888888),
                ),
              ),
            ],
          ),
        ),
        if (suffix != null) ...[
          SizedBox(width: 6.w),
          Text(
            suffix!,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              color: const Color(0xff888888),
            ),
          ),
        ],
      ],
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String value;

  const _FieldBox(this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xffF7F7F7),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
      ),
      child: Text(
        value,
        style: GoogleFonts.nunitoSans(fontSize: 15.sp, color: Colors.black),
      ),
    );
  }
}

class _DocumentRow extends ConsumerWidget {
  final String name;
  final String? documentUrl;

  const _DocumentRow({required this.name, this.documentUrl});

  Future<void> _openDocument(BuildContext context) async {
    final url = documentUrl;
    if (url == null) return;

    final uri = Uri.parse(url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open document')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error opening document: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sizeAsync = documentUrl != null
        ? ref.watch(documentSizeProvider(documentUrl!))
        : const AsyncValue.data('PDF Document');

    return InkWell(
      onTap: () => _openDocument(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xffF7F7F7),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xffEEEEEE)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/images/pdf1.png',
                width: 30.w,
                height: 30.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  sizeAsync.when(
                    loading: () => Text(
                      'Calculating...',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: const Color(0xff888888),
                      ),
                    ),
                    error: (_, __) => Text(
                      'PDF Document',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: const Color(0xff888888),
                      ),
                    ),
                    data: (size) => Text(
                      size,
                      style: GoogleFonts.nunitoSans(
                        fontSize: 12.sp,
                        color: const Color(0xff888888),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: const Color(0xffAAAAAA),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
