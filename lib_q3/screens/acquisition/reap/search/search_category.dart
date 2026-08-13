import 'package:GapHub/provider/acquisiProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/acquisitionProvider.dart';

class SearchCategory extends StatelessWidget {
  const SearchCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final acquisitionProvider = context.watch<AcquisiProvider>();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(acquisitionProvider.items.length, (index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 8, 8),
            child: GestureDetector(
              onTap: () {
                acquisitionProvider.onCategoryChanged(
                  acquisitionProvider.items[index],
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: acquisitionProvider.isSelected[index]
                      ? Colors.black
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xffe5e5e5),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      acquisitionProvider.items[index],
                      style: TextStyle(
                        color: acquisitionProvider.isSelected[index]
                            ? Colors.white
                            : Colors.black,
                        fontSize: 14.sp,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(width: 5),
                    if (acquisitionProvider.isSelected[index])
                      const Icon(Icons.check, color: Colors.white, size: 15),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
