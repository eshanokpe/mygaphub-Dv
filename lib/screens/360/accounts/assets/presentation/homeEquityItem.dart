import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../widget/topBar.dart';
import '../provider/homeEquityItemModel.dart';
import 'editHomeEquityItem.dart';

final homeEquityItemProvider =
    Provider.family<HomeEquityItemModel, Map<String, dynamic>>((ref, item) {
      return HomeEquityItemModel.fromMap(item);
    });

class HomeEquityItem extends ConsumerWidget {
  final Map<String, dynamic> item;
  final String imagePath;
  final bool archived;

  const HomeEquityItem({
    super.key,
    required this.item,
    required this.imagePath,
    this.archived = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final model = ref.watch(homeEquityItemProvider(item));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: TopBar(
                onBack: () => Navigator.pop(context),
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ✅ FIX 1: Pass the raw Map, remove 'const'
                      builder: (context) => EditHomeEquityItem(item: item),
                    ),
                  );
                },
              ),
            ),
            Expanded(
              // ✅ FIX 2: Pass the raw Map down to _HomeEquityItemBody
              child: _HomeEquityItemBody(
                item: model,
                imagePath: imagePath,
                originalMap: item,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeEquityItemBody extends StatelessWidget {
  final HomeEquityItemModel item;
  final String imagePath;
  final Map<String, dynamic> originalMap; // ✅ ADDED

  const _HomeEquityItemBody({
    required this.item,
    required this.imagePath,
    required this.originalMap, // ✅ ADDED
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryCard(item: item, imagePath: imagePath),
          SizedBox(height: 16.h),
          _DetailsCard(item: item),

          if (item.document != null && item.document!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            _DocumentRow(
              name: item.documentFileName,
              documentUrl: item.documentUrl,
            ),
          ],

          SizedBox(height: 40.h),

          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  // ✅ FIX 3: Use originalMap directly — no .toMap() needed!
                  builder: (context) => EditHomeEquityItem(item: originalMap),
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
                SizedBox(width: 6.w),
                Text(
                  'Edit Information',
                  style: GoogleFonts.nunitoSans(
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

// ── Summary card: avatar, badge, title, subtitle ────────────────────────

class _SummaryCard extends StatelessWidget {
  final HomeEquityItemModel item;
  final String imagePath;

  const _SummaryCard({required this.item, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: Colors.white,
                child: ClipOval(
                  child: Image.asset(
                    imagePath,
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.home_outlined, size: 24.sp),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF174E18), Color(0xff0F2B10)],
                    stops: [0.0, 5.8],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Home Equity',
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            item.propertyName ?? 'Property',
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            item.cityCountryLine,
            style: GoogleFonts.nunitoSans(
              fontSize: 13.sp,
              color: const Color(0xff888888),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Details card: address, market value, ownership %, date acquired ────

class _DetailsCard extends StatelessWidget {
  final HomeEquityItemModel item;

  const _DetailsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xffEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(
            label: 'Home Address',
            value: item.fullAddress,
            valueFontSize: 15.sp,
          ),
          _Divider(),
          _DetailRow(
            label: 'Current market value of your home',
            valueWidget: RichText(
              text: TextSpan(children: _splitAmount(item.formattedMarketValue)),
            ),
          ),
          _Divider(),
          _DetailRow(
            label: 'Ownership Percentage',
            value: item.ownershipPercentage != null
                ? '${item.ownershipPercentage}%'
                : '-',
            valueFontSize: 24.sp,
            valueWeight: FontWeight.w700,
          ),
          _Divider(),
          _DetailRow(
            label: 'Date Acquired',
            value: item.formattedDateAcquired,
            valueFontSize: 16.sp,
            valueWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  List<TextSpan> _splitAmount(String formatted) {
    final parts = formatted.split('.');
    return [
      TextSpan(
        text: '£${parts[0]}',
        style: GoogleFonts.nunitoSans(
          fontSize: 24.sp,
          fontWeight: FontWeight.w700,
          color: Colors.black,
        ),
      ),
      TextSpan(
        text: '.${parts.length > 1 ? parts[1] : '00'}',
        style: GoogleFonts.nunitoSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: const Color(0xff888888),
        ),
      ),
    ];
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final double? valueFontSize;
  final FontWeight? valueWeight;

  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.valueFontSize,
    this.valueWeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.nunitoSans(
              fontSize: 12.sp,
              color: const Color(0xff9A9A9A),
            ),
          ),
          SizedBox(height: 6.h),
          valueWidget ??
              Text(
                value ?? '-',
                style: GoogleFonts.nunitoSans(
                  fontSize: valueFontSize ?? 16.sp,
                  fontWeight: valueWeight ?? FontWeight.w600,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, color: const Color(0xffF0F0F0));
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
    return InkWell(
      onTap: () => _openDocument(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30.w,
              height: 30.w,
              child: Image.asset(
                'assets/images/pdf1.png',
                width: 30.w,
                height: 30.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.nunitoSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
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
