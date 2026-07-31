import 'package:GapHub/provider/notification_provider.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/avatarImage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:GapHub/screens/more/notifications/notification.dart';
import 'package:GapHub/utils/httpErrorDisplay.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/screens/reminder/reminder.dart';
import 'search/search_content.dart';

class HomePageHeader extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey? sliderKey;

  const HomePageHeader({super.key, this.sliderKey});
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
      surfaceTintColor: Colors.white,
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
          child: Image.asset(
            'assets/images/play.png',
            height: 36.h,
            width: 36.w,
          ),
        ),
      ),
      actions: [
        // _buildSearchIcon(context, screenWidth),
        _buildReminderIcon(context, screenWidth, currency),
        SizedBox(width: 5.w),
        _buildNotificationIcon(context, screenWidth),
        SizedBox(width: 5.w),
        const AvatarImage(),
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
          'assets/icons/homeseach.png',
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * .0),
            child: SvgPicture.asset(
              'assets/images/alarm.svg',
              height: 25.h,
              color: Colors.black,
            ),
          ),
          // Red dot (notification)
          Consumer<ReminderProvider>(
            builder: (context, reminderProvider, child) {
              if (reminderProvider.reminderCount > 0) {
                return Positioned(
                  top: 0,
                  right: 1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink(); // Hide icon if no archived reminders
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context, double screenWidth) {
    return Consumer<NotificationProvider>(
      builder: (context, provider, child) {
        final hasUnreadNotifications = provider.unreadCount > 0;

        return Stack(
          children: [
            InkWell(
              onTap: () async {
                try {
                  // Show loading dialog
                  dialogBox.waiting(context, 'Loading');

                  // Fetch notifications using provider instead of direct API call
                  await provider.fetchNotifications(refresh: true);

                  // Close loading dialog
                  Navigator.pop(context);

                  // Navigate to notifications screen
                  navigateWithSlideTransition(
                    // ignore: use_build_context_synchronously
                    context: context,
                    destinationScreen: const NotificationsScreen(),
                    transitionDuration: const Duration(milliseconds: 200),
                  );
                } catch (e) {
                  // Close loading dialog if still open
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  // Show error message
                  dialogBox.information(
                    context,
                    'Error',
                    'Failed to load notifications',
                  );
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * .02),
                child: Stack(
                  children: [
                    Image.asset(
                      'assets/images/bell_notification.png',
                      height: 25.h,
                      color: Colors.black,
                    ),

                    // OPTION A: Simple red dot (any notifications)
                    if (hasUnreadNotifications)
                      Positioned(
                        right: 0,
                        top: 1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
