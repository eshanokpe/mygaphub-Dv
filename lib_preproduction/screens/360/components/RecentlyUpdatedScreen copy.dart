import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentlyUpdatedScreen extends StatelessWidget {
  const RecentlyUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          const SizedBox(height: 20),

          const AccountTile(
            imagePath: 'assets/wheel_segments/cash_icon.png',
            title: "Cash",
            subtitle: "Multiple Accounts",
            amount: "£777.53",
          ),
          const AccountTile(
            imagePath: 'assets/wheel_segments/income_icon.png',
            title: "Income",
            subtitle: "Multiple Accounts",
            amount: "£777.53",
          ),
          const AccountTile(
            imagePath: 'assets/wheel_segments/mortgage_icon.png',
            title: "Mortgage",
            subtitle: "Single Account",
            amount: "£777.53",
          ),

          const Spacer(),

          GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  "Add Account",
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16.sp,
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
}

class AccountTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subtitle;
  final String amount;

  const AccountTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Image.asset(imagePath),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }
}
