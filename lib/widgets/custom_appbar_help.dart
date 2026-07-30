import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../screens/helpWidget/help_widget.dart';

class CustomAppBarHelp extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBarHelp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: EdgeInsets.only(left: 15.w),
        child: Image.asset('assets/logo.png', width: 32.w, height: 32.h),
      ),
      actions: const [HelpWidget()],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
