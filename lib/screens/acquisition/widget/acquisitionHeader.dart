import 'package:GapHub/widgets/avatarImage.dart';
import 'package:GapHub/widgets/customBottomSheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBarAcquisition extends StatelessWidget
    implements PreferredSizeWidget {
  const CustomAppBarAcquisition({super.key});

  @override 
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Orientation orientation = MediaQuery.of(context).orientation;
    final screenHeight = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.height
        : MediaQuery.of(context).size.width;
    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    const paddingValue = 16.0;
    const topValue = 10.0;

    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(56.0),
                  topRight: Radius.circular(56.0),
                ),
              ),
              builder: (BuildContext context) {
                return const CustomBottomSheet(
                  title: 'Disclaimer',
                  content:
                      'The information provided in our asset acquisition content is intended solely for informational purposes. It should not be considered as financial advice, investment, recommendations, or a solicitation to buy or sell any financial products. Always conduct your own research and consult with a qualified financial advisor before making any investment decisions.',
                );
              },
            );
          },
          child: Image.asset('assets/icons/red_zone.png', width: 10.w),
        ),
      ),
      actions: const [AvatarImage()],
    );
  }
}
