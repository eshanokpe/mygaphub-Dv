import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AssetRowWithTap extends StatelessWidget {
  final String imagePath;
  final String title;
  final List<Map<String, dynamic>> subtitleParts;
  final String percentage;
  final String changeValue;
  final Color changeColor;
  final VoidCallback onTap;
  final bool trailing;

  const AssetRowWithTap({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitleParts,
    required this.percentage,
    required this.changeValue,
    required this.trailing,
    required this.onTap,
    this.changeColor = const Color(0xff009933), // Default green
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    fontFamily: 'Nunito',
                  ),
                ),
                Row(
                  children: subtitleParts.map((part) {
                    return Text(
                      part['text'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: part['fontWeight'] == true
                            ? FontWeight.bold
                            : FontWeight.w400,
                        color: part['color'] ?? Colors.black54,
                        fontFamily: 'Nunito',
                        decoration: part['underline'] == true
                            ? TextDecoration.underline
                            : TextDecoration.none,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          trailing
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      percentage,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      changeValue,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                        color: changeColor,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}
