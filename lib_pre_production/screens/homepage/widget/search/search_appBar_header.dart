import 'dart:async';
import 'dart:convert';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:GapHub/screens/more/notifications/notification.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:GapHub/screens/reminder/reminder.dart';

import 'search_content.dart';

class SearchWidgetAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final GlobalKey? sliderKey;

  const SearchWidgetAppBar({super.key, this.sliderKey});
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;
    var currency = context.watch<Providers>().snapshotmodel.currency;

    final screenWidth = orientation == Orientation.portrait
        ? MediaQuery.of(context).size.width
        : MediaQuery.of(context).size.height;

    return AppBar(
      backgroundColor: Colors.white,
      title: const Text('', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.only(left: 16.w),
        child: InkWell(
          onTap: () {
            Scrollable.ensureVisible(sliderKey!.currentContext!);
          },
          child: SvgPicture.asset('assets/images/play2.svg', width: 10.w),
        ),
      ),
      actions: const [
        // _buildSearchIcon(context, screenWidth),
        // _buildReminderIcon(context, screenWidth, currency),
        // _buildNotificationIcon(context, screenWidth),
        AvatarImage(),
      ],
    );
  }

  Widget _buildSearchIcon(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SearchContent()),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * .02),
        child: Image.asset(
          'assets/icons/infor.png',
          width: screenWidth * .05,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildReminderIcon(
    BuildContext context,
    double screenWidth,
    String currency,
  ) {
    return InkWell(
      onTap: () async {
        final reminderProvider = Provider.of<ReminderProvider>(
          context,
          listen: false,
        );
        reminderProvider.fetchReminders(currency);
        navigateWithSlideTransition(
          context: context,
          destinationScreen: const ReminderScreen(),
          transitionDuration: const Duration(milliseconds: 200),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * .02),
        child: Image.asset(
          'assets/images/alarm.png',
          width: screenWidth * .06,
          color: const Color.fromARGB(255, 27, 15, 15),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context, double screenWidth) {
    return InkWell(
      onTap: () async {
        try {
          dialogBox.waiting(context, 'Loading');
          final prefs = await SharedPreferences.getInstance();
          var token = prefs.getString('tokenDB');
          var url = Uri.parse("$baseUrl/app/notifications");
          var response = await http.get(
            url,
            headers: {"Authorization": 'Bearer $token'},
          );

          if (response.statusCode == 200) {
            Map body = jsonDecode(response.body);
            context.read<Providers>().setNotification(body['data']);
            Navigator.pop(context);
            navigateWithSlideTransition(
              context: context,
              destinationScreen: const NotificationsScreen(),
              transitionDuration: const Duration(milliseconds: 200),
            );
          } else {
            Navigator.pop(context);
            dialogBox.information(context, 'Error', 'Internet Error');
          }
        } catch (e) {
          Navigator.pop(context);
          dialogBox.information(context, 'Error', 'An error occurred');
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * .02),
        child: Image.asset(
          'assets/images/bell_notification.png',
          width: screenWidth * .05,
          color: Colors.black,
        ),
      ),
    );
  }
}
