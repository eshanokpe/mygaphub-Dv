import 'package:GapHub/screens/360/accounts/assets/provider/equity_provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:GapHub/screens/360/accounts/assets/provider/equity_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../cash/cashdetails.dart';
import '../../cash/provider/cash_provider.dart';
import '../../investment/investdash.dart';
import '../../investment/provider/investment_provider.dart';
import '../../retirement/presentation/retiredash.dart';
import '../../retirement/provider/pension_sum_provider.dart';
import '../presentation/equitydetails.dart';
import 'add_investmentPopup.dart';

class _AssetItemRow extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subTitle;
  final dynamic amount;
  final String currencySymbol;
  final VoidCallback? onTap;

  const _AssetItemRow({
    required this.imagePath,
    required this.title,
    required this.subTitle,
    required this.amount,
    this.currencySymbol = '£',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {},
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 46.w,
            height: 46.h,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(8.w),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subTitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w300,
                    color: const Color(0xFF808080),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AssetAmountText(currencySymbol: currencySymbol, amount: amount),
              SizedBox(width: 4.w),
              Icon(
                Icons.chevron_right,
                size: 20.w,
                color: const Color(0xFFBFBFBF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AssetCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subTitle;
  final dynamic amount;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subTitle,
    required this.amount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String currency = context.watch<Providers>().snapshotmodel.currency;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: _AssetItemRow(
        imagePath: imagePath,
        title: title,
        subTitle: subTitle,
        amount: amount,
        currencySymbol: currency,
        onTap: onTap,
      ),
    );
  }
}

class GroupedAssetItem {
  final String imagePath;
  final String title;
  final String subTitle;
  final dynamic amount;
  final VoidCallback? onTap;

  const GroupedAssetItem({
    required this.imagePath,
    required this.title,
    required this.subTitle,
    required this.amount,
    this.onTap,
  });
}

class GroupedAssetsCard extends StatelessWidget {
  final List<GroupedAssetItem> items;
  final Widget? footer;

  const GroupedAssetsCard({super.key, required this.items, this.footer});

  @override
  Widget build(BuildContext context) {
    String currencySymbol = context.watch<Providers>().snapshotmodel.currency;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: _AssetItemRow(
                imagePath: items[i].imagePath,
                title: items[i].title,
                subTitle: items[i].subTitle,
                amount: items[i].amount,
                currencySymbol: currencySymbol,
                onTap: items[i].onTap,
              ),
            ),
            if (i != items.length - 1)
              Divider(
                height: 1.h,
                thickness: 1,
                color: const Color(0xFFF3F3F3),
              ),
          ],
          if (footer != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: Divider(
                height: 1.h,
                thickness: 1,
                color: const Color(0xFFE3E3E3),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 14.h),
              child: footer,
            ),
          ],
        ],
      ),
    );
  }
}

class AssetAmountText extends StatelessWidget {
  final String currencySymbol;
  final dynamic amount;

  const AssetAmountText({
    super.key,
    required this.currencySymbol,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final num numValue = double.tryParse(amount.toString()) ?? 0;
    final formatted = numValue.toStringAsFixed(2);
    final parts = formatted.split('.');
    final whole = '$currencySymbol${_formatNumber(parts[0])}';
    final decimal = '.${parts[1]}';

    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: whole,
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          TextSpan(
            text: decimal,
            style: GoogleFonts.nunitoSans(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF9A9A9A),
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(String? valueStr) {
    if (valueStr == null || valueStr.isEmpty) return '0';
    final num numValue = num.tryParse(valueStr) ?? 0;
    return NumberFormat('#,###').format(numValue);
  }
}

/// Grey pill toggle, no icon, white text when selected.
class AssetToggleChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool secondBg;

  const AssetToggleChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.secondBg = false,
  });

  @override
  Widget build(BuildContext context) {
    final LinearGradient background = isSelected
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffF6981E), Color(0xFF825212)],
          )
        : const LinearGradient(colors: [Color(0xffD2D2D2), Color(0xffD2D2D2)]);
    final LinearGradient background2 = isSelected
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xff174E18), Color(0xFF0F2B10)],
          )
        : const LinearGradient(colors: [Color(0xffD2D2D2), Color(0xffD2D2D2)]);

    final Color foreground = isSelected ? Colors.white : Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          gradient: secondBg ? background2 : background,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08101828),
              offset: Offset(0, 4),
              blurRadius: 6,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Color(0x14101828),
              offset: Offset(0, 12),
              blurRadius: 16,
              spreadRadius: 7,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            isSelected
                ? Container(
                    width: 20.w,
                    height: 20.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 14.sp,
                      color: const Color(0xFF1B3B1E),
                    ),
                  )
                : Container(),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section label, e.g. "CURRENT ASSETS".
class AssetSectionLabel extends StatelessWidget {
  final String text;

  const AssetSectionLabel({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 12.h),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.nunitoSans(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
          color: const Color(0xFF6B6B6B),
        ),
      ),
    );
  }
}

/// Toggle row controlling whether Pension / Home Equity are included
/// in the total assets sum. State is owned by the parent (Assetdetails).
class IncludeInTotalAssetsSection extends StatelessWidget {
  final bool includePension;
  final bool includeHomeEquity;
  final VoidCallback onPensionTap;
  final VoidCallback onHomeEquityTap;

  const IncludeInTotalAssetsSection({
    super.key,
    required this.includePension,
    required this.includeHomeEquity,
    required this.onPensionTap,
    required this.onHomeEquityTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Include In Total Assets',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9A9A9A),
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12.w,
          runSpacing: 10.h,
          children: [
            AssetToggleChip(
              label: 'Pension',
              isSelected: includePension,
              onTap: onPensionTap,
            ),
            AssetToggleChip(
              secondBg: true,
              label: 'Home Equity',
              isSelected: includeHomeEquity,
              onTap: onHomeEquityTap,
            ),
          ],
        ),
      ],
    );
  }
}

class AssetsContent extends ConsumerWidget {
  final List seveng;
  final List bespokes;
  final bool includePension;
  final bool includeHomeEquity;
  final VoidCallback onPensionTap;
  final VoidCallback onHomeEquityTap;

  const AssetsContent({
    super.key,
    required this.seveng,
    required this.bespokes,
    required this.includePension,
    required this.includeHomeEquity,
    required this.onPensionTap,
    required this.onHomeEquityTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Watch ALL providers directly
    final investmentState = ref.watch(investmentProvider);
    final equityState = ref.watch(equityProvider);
    final cashState = ref.watch(cashProvider);
    final pensionState = ref.watch(pensionProvider);

    // ✅ Extract sums safely with loading checks
    final invSum = investmentState.loading
        ? 0
        : (investmentState.investmentSum ?? 0);
    final equitySum = equityState.loading
        ? 0
        : (equityState.equityDetail?['sum'] ?? 0);
    final cashSum = cashState.loading ? 0 : (cashState.cashDetail?["sum"] ?? 0);
    final pensionSum = pensionState.loading
        ? 0
        : (pensionState.pensionDetail?["sum"] ?? 0);

    // Keep legacy provider ONLY for currency and raw lists if needed for navigation
    final providers = context.watch<Providers>();
    final currency = providers.snapshotmodel.currency;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AssetSectionLabel(text: 'Current Assets'),

          AssetCard(
            imagePath: 'assets/wheel_segments/investment_icon.png',
            title: 'Investments',
            subTitle: investmentState.loading ? 'Updating...' : 'Portfolio',
            amount: invSum,
            onTap: () {
              print("braidTable:${investmentState.braidTable}");
              // Navigator.push(;
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => Investdash(
              //       sums: invSum,
              //       braidTable: investmentState.braidTable,
              //     ),
              //   ),
              // );
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(56.0),
                    topRight: Radius.circular(56.0),
                  ),
                ),
                builder: (context) => FractionallySizedBox(
                  heightFactor: 1.2,
                  child: AddInvestmentPopup(
                    title: "Investment Total",
                    sums: invSum,
                    braidTable: investmentState.braidTable,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 12.h),

          AssetCard(
            imagePath: 'assets/wheel_segments/cash_icon.png',
            title: 'Cash',
            subTitle: cashState.loading ? 'Updating...' : '360',
            amount: cashSum,
            onTap: () {
              // Pass raw data from provider if Cashdetails needs it
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Cashdetails(
                    cashState.cashData,
                    cashState.cashDetail,
                    seveng,
                    bespokes,
                  ),
                ),
              );
            },
          ),

          SizedBox(height: 20.h),
          const AssetSectionLabel(text: 'Non-Current Assets'),

          GroupedAssetsCard(
            items: [
              GroupedAssetItem(
                imagePath: 'assets/wheel_segments/retirement_icon.png',
                title: 'Pension',
                subTitle: pensionState.loading ? 'Updating...' : '360',
                amount: pensionSum,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Retiredash()),
                  );
                },
              ),
              GroupedAssetItem(
                imagePath: 'assets/wheel_segments/home_equity_icon.png',
                title: 'Home Equity',
                subTitle: equityState.loading ? 'Updating...' : '360',
                amount: equitySum,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Equitydetails(),
                    ),
                  );
                  ref.read(equityProvider.notifier).refreshEquity();
                },
              ),
            ],
            footer: IncludeInTotalAssetsSection(
              includePension: includePension,
              includeHomeEquity: includeHomeEquity,
              onPensionTap: onPensionTap,
              onHomeEquityTap: onHomeEquityTap,
            ),
          ),
        ],
      ),
    );
  }
}
