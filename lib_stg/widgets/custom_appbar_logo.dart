import 'package:flutter/material.dart';

class CustomAppBarLogo extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final VoidCallback? onActionPressed;
  final String? actionIconPath;
  final Color backgroundColor;
  final Color leadingIconColor;

  const CustomAppBarLogo({
    super.key,
    required this.title,
    this.onBackPressed,
    this.onActionPressed,
    this.actionIconPath,
    this.backgroundColor = Colors.white,
    this.leadingIconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    final screenheight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;
    const double paddingValue = 16.0;
    final double percentagePadding = paddingValue / screenWidth * 100;
    final double rightPadding = screenWidth * percentagePadding / 100;
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      leading: onBackPressed != null
          ? IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(Icons.arrow_back_ios, color: leadingIconColor),
              onPressed: onBackPressed,
            )
          : null,
      actions: [
        if (actionIconPath != null)
          Padding(
            padding: EdgeInsets.only(right: rightPadding),
            child: InkWell(
              onTap: onActionPressed,
              child: Image.asset(actionIconPath!, width: 30),
            ),
          ),
      ],
      title: Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
