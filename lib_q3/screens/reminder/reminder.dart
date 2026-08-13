import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'addreminder.dart';
import 'viewReminder.dart';
import 'widget/customBottomSheetReminder.dart';
import 'widget/no_reminder_found.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Fetch reminders when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var currency = context.read<Providers>().snapshotmodel.currency;

      Provider.of<ReminderProvider>(
        context,
        listen: false,
      ).fetchReminders(currency);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh when returning to the app
      var currency = context.read<Providers>().snapshotmodel.currency;
      Provider.of<ReminderProvider>(
        context,
        listen: false,
      ).fetchReminders(currency);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    var currency = context.watch<Providers>().snapshotmodel.currency;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Reminder',
          style: GoogleFonts.nunitoSans(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (reminderProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (reminderProvider.error != null)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 20.w),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          reminderProvider.error!,
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 18.w),
                        onPressed: () => reminderProvider.clearError(),
                      ),
                    ],
                  ),
                )
              else if (reminderProvider.reminders.isEmpty)
                const NoReminderFound()
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: reminderProvider.reminders.length,
                  separatorBuilder: (_, __) =>
                      Divider(color: Colors.grey.shade300, height: 25.h),
                  itemBuilder: (context, index) {
                    final reminder = reminderProvider.reminders[index];
                    final isExpired = _isReminderExpired(reminder);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
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
                                return CustomBottomSheetReminder(
                                  title:
                                      'Did you actually complete this reminder?',
                                  name: reminder.name,
                                  note: reminder.note!,
                                  reminderId: reminder.id,
                                  amount: reminder.amount!,
                                  date: DateTime.parse(reminder.date),
                                  time: _parseTimeString(reminder.time),
                                  alert: reminder.dueDays,
                                  reminderMode: 'archive',
                                  onCompleted: () {
                                    // This callback will be called when reminder is successfully completed
                                  },
                                );
                              },
                            );
                          },
                          child: Icon(
                            Icons.circle_outlined,
                            size: 22.sp,
                            color: isExpired
                                ? Colors.grey.shade400
                                : Colors.grey.shade400,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewReminder(
                                    reminderId: reminder.id,
                                    reminder: reminder,
                                    reminderMode: 'NoArchive',
                                  ),
                                ),
                              );

                              if (result == true) {
                                Provider.of<ReminderProvider>(
                                  context,
                                  listen: false,
                                ).fetchReminders(currency);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        reminder.name.isNotEmpty
                                            ? '${reminder.name[0].toUpperCase()}${reminder.name.substring(1)}'
                                            : '',
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                        softWrap: true,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        _formatDate(reminder.date),
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.w400,
                                          color: isExpired
                                              ? Colors.grey
                                              : AppColors.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff7f7f7),
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: const Color(0xffEEEEEE),
                                    ),
                                  ),
                                  child: Text(
                                    '$currency${_formatAmount(reminder.amount!)}',
                                    style: GoogleFonts.nunitoSans(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black,
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
                ),

              // Add this to your ReminderScreen build method, near the bottom
              if (reminderProvider.reminders.isNotEmpty) ...[
                SizedBox(height: 24.h),
                // TEST BUTTON - Remove this in production
                // Center(
                //   child: ElevatedButton(
                //     onPressed: () {
                //       Provider.of<ReminderProvider>(context, listen: false)
                //           .testScheduledNotification();
                //     },
                //     child: Text(
                //       'Test Push Notification',
                //       style: GoogleFonts.nunitoSans(
                //         fontSize: 14.sp,
                //         fontWeight: FontWeight.w500,
                //         color: Colors.white,
                //       ),
                //     ),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: Colors.blue,
                //       minimumSize: Size(260.w, 50.h),
                //       shape: RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(30.r),
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(height: 10.h),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      navigateWithSlideTransition(
                        context: context,
                        destinationScreen: const AddReminder(),
                        transitionDuration: const Duration(milliseconds: 200),
                      );
                    },
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: Text(
                      'Set a new reminder',
                      style: GoogleFonts.nunitoSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffC92B2B),
                      minimumSize: Size(260.w, 50.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30.h),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Check if reminder date and time have expired
  bool _isReminderExpired(ReminderModel reminder) {
    try {
      final date = DateTime.parse(reminder.date);
      final timeParts = reminder.time.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts.length > 1 ? timeParts[1] : '0');
      final reminderDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        hour,
        minute,
      );
      return reminderDateTime.isBefore(DateTime.now());
    } catch (_) {
      return reminder.isPast;
    }
  }
  // bool _isReminderExpired(ReminderModel reminder) {
  //   try {
  //     // Parse the date from reminder.date
  //     final dateParts = reminder.date.split('-');
  //     final timeParts = (reminder.time).split(':');

  //     final reminderDateTime = DateTime(
  //       int.parse(dateParts[0]), // year
  //       int.parse(dateParts[1]), // month
  //       int.parse(dateParts[2]), // day
  //       int.parse(timeParts[0]), // hour
  //       int.parse(timeParts[1]), // minute
  //     );

  //     final now = DateTime.now();

  //     // Check if reminder date/time is before now
  //     return reminderDateTime.isBefore(now);
  //   } catch (e) {
  //     // If parsing fails, check if is_past field is available
  //     return reminder.isPast;
  //   }
  // }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('EEEE, MMMM dd yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  String _formatAmount(String amount) {
    try {
      final number = double.parse(amount);
      return NumberFormat('#,##0.00').format(number);
    } catch (e) {
      return amount;
    }
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}
