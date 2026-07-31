// widgets/side_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/wheel_side_card.dart';
import '../providers/carousel_provider.dart';

class SideCardWidget extends ConsumerWidget {
  final WheelItemSideCard item;
  final int index;
  final bool isLeft;

  const SideCardWidget({
    super.key,
    required this.item,
    required this.index,
    required this.isLeft,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(carouselProvider.notifier).selectIndex(index),
      child: Center(
        child: SizedBox(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              // border: Border.all(
              //   color: Colors.white.withOpacity(0.9),
              //   width: 1.5.w,
              // ),
              image: DecorationImage(
                image: AssetImage(item.imagePath),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ),
    );
  }
}