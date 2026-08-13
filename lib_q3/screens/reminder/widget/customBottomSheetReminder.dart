import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/calulate_padding.dart';
import 'package:GapHub/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/provider/reminderProvider.dart';

class CustomBottomSheetReminder extends StatelessWidget {
  final String title;
  final String name;
  final String note;
  final int reminderId;
  final String amount;
  final DateTime? date;
  final TimeOfDay? time;
  final int alert;
  final VoidCallback onCompleted;
  final String? reminderMode;

  const CustomBottomSheetReminder({
    super.key,
    required this.title,
    required this.name,
    required this.note,
    required this.reminderId,
    required this.amount,
    required this.date,
    required this.time,
    required this.alert,
    required this.onCompleted,
    this.reminderMode,
  });

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );

    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.0),
          topRight: Radius.circular(24.0),
        ),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 10.h, 24.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 10.h),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      height: 5.h,
                      width: 45.w,
                      decoration: BoxDecoration(
                        color: const Color(0xffcdcdcd),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35.w),
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Consumer<ReminderProvider>(
                  builder: (context, provider, child) {
                    return CustomButton(
                      text: provider.isLoading ? 'Completing...' : 'Yes I did',
                      fontSize: 16.sp,
                      borderRadius: 30,
                      icon: null,
                      iconColor: AppColors.primaryColor,
                      borderColor: AppColors.primaryColor,
                      onPressed: provider.isLoading
                          ? null
                          : () async {
                              final success = await provider.deleteReminder(
                                reminderId,
                              );
                              // final success = await provider.markReminderAsComplete(
                              //   reminderId,name, note, amount,date,time,alert
                              //   );
                              if (success && context.mounted) {
                                print("reminderMode: $reminderMode");
                                if (reminderMode == 'archive') {
                                  // Navigator.pop(context);
                                  Navigator.pop(context);
                                } else {
                                  print("No reminderMode: $reminderMode");
                                  // Otherwise, refresh the active reminders list
                                  Navigator.pop(context);
                                }

                                onCompleted(); // Call the callback
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Reminder marked as complete!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else if (context.mounted) {
                                Navigator.pop(context); // Close bottom sheet
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      provider.error ??
                                          'Failed to complete reminder',
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                      color: AppColors.primaryColor,
                      textColor: AppColors.contentColorWhite,
                    );
                  },
                ),
                SizedBox(height: 10.h),
                CustomButton(
                  text: 'Not yet',
                  fontSize: 16.sp,
                  borderRadius: 30,
                  icon: null,
                  iconColor: AppColors.primaryColor,
                  borderColor: const Color(0xffC8CECC),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.white,
                  textColor: AppColors.blackColor,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
