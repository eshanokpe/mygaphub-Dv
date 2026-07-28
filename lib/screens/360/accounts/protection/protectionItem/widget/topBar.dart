// ── Widgets ───────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onEdit;

  const TopBar({super.key, required this.onBack, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
            onPressed: onBack,
          ),
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(8.r), // gives nice ripple feedback
            splashColor: Colors.grey.shade200, // optional soft ripple
            child: Container(
              padding: EdgeInsets.all(8.w), // ⬅️ increases tap area significantly
              width: 38.w,
              height: 38.w,
              child: Image.asset(
                'assets/wheel_segments/pencil_alt_black.png',
                width: 38.w,
                height: 38.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
