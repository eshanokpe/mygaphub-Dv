import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'editreminder.dart';
import 'widget/customBottomSheetReminder.dart';

class ViewReminder extends StatefulWidget {
  final int? reminderId;
  final ReminderModel? reminder;
  final String? reminderMode;

  const ViewReminder({
    super.key,
    this.reminderId,
    this.reminder,
    this.reminderMode,
  });

  @override
  State<ViewReminder> createState() => _ViewReminderState();
}

class _ViewReminderState extends State<ViewReminder> {
  late ReminderModel? _reminder;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReminder();
  }

  Future<void> _loadReminder() async {
    // If reminder is already passed, use it
    if (widget.reminder != null) {
      _reminder = widget.reminder;
      _isLoading = false;
      setState(() {});
      return;
    }

    // If only ID is provided, fetch from API
    if (widget.reminderId != null) {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      try {
        _reminder = await provider.fetchReminderById(widget.reminderId!);
        _error = provider.error;
      } catch (e) {
        _error = 'Failed to load reminder: $e';
      }
    } else {
      _error = 'No reminder ID provided';
    }

    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var currency = context.watch<Providers>().snapshotmodel.currency;

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Show error state
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red, size: 48.w),
                SizedBox(height: 16.h),
                Text(
                  _error!,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Go Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show reminder not found state
    if (_reminder == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.orange, size: 48.w),
              SizedBox(height: 16.h),
              Text(
                'Reminder not found',
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show reminder details (main UI)
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          _reminder!.name.isNotEmpty
              ? '${_reminder!.name[0].toUpperCase()}${_reminder!.name.substring(1)}'
              : '',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Consumer<ReminderProvider>(
            builder: (context, reminderProvider, child) {
              return Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: InkWell(
                  onTap: () =>
                      _showDeleteConfirmationDialog(context, reminderProvider),
                  child: Image.asset(
                    'assets/images/Icon.png',
                    width: 18.w,
                    color: AppColors.primaryColor,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.sp),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffEEEEEE), width: 1.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        child: Text(
                          _reminder!.name.isNotEmpty
                              ? '${_reminder!.name[0].toUpperCase()}${_reminder!.name.substring(1)}'
                              : '',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    color: Color(0xffE0E0E0),
                    thickness: 1.0,
                    height: 1,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          child: Text(
                            _reminder!.note ?? '',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 15.sp),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffEEEEEE), width: 1.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
              child: Row(
                children: [
                  Text(
                    '$currency${NumberFormat('#,##0.00').format(double.tryParse(_reminder!.amount.toString()) ?? 0)}',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffEEEEEE), width: 1.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.h),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xffE4E4E4),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/Calendar.png',
                        width: 28.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.sp),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          DateFormat(
                            'EEEE, MMMM d yyyy',
                          ).format(DateTime.parse(_reminder!.date)),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffEEEEEE), width: 1.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.h),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xffE4E4E4),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Image.asset('assets/images/Time.png', width: 28.w),
                    ),
                  ),
                  SizedBox(width: 10.sp),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          _reminder!.time.isNotEmpty
                              ? _formatTime(_parseTimeString(_reminder!.time))
                              : 'No time set',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xffEEEEEE), width: 1.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 18.h),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xffE4E4E4),
                        width: 0.5,
                      ),
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/Alert2.png',
                        width: 28.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.sp),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alert',
                          style: GoogleFonts.nunitoSans(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        Text(
                          (_reminder!.alertHumanReadable ?? ''),
                          style: GoogleFonts.nunitoSans(
                            fontSize: 14.sp,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                widget.reminderMode == 'archive'
                    ? const SizedBox()
                    : Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          height: 60.h,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditReminder(reminder: _reminder!),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.black,
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                                side: const BorderSide(
                                  color: Color(0xffc8cecc),
                                  width: 1.0,
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: 16.h,
                                horizontal: 32.w,
                              ),
                            ),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                SizedBox(width: 16.h),
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 60.h,
                    child: ElevatedButton(
                      onPressed: () {
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
                              title: 'Did you actually complete this reminder?',
                              name: _reminder!.name,
                              note: _reminder!.note ?? '',
                              reminderId: _reminder!.id,
                              amount: _reminder!.amount ?? '',
                              date: DateTime.parse(_reminder!.date),
                              time: _parseTimeString(
                                _reminder!.time ?? "00:00",
                              ),
                              alert: _reminder!.dueDays,
                              reminderMode: widget.reminderMode,
                              onCompleted: () {
                                Navigator.pop(context);
                              },
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        foregroundColor: Colors.white,
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        side: const BorderSide(color: Color(0x0ffc8ecc)),
                        padding: EdgeInsets.symmetric(
                          vertical: 16.h,
                          horizontal: 32.w,
                        ),
                      ),
                      child: Text(
                        'Complete',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'am' : 'pm';

    return '$hour:$minute $period';
  }

  TimeOfDay _parseTimeString(String timeStr) {
    try {
      // Handle empty or null
      if (timeStr.isEmpty) return TimeOfDay.now();

      // Handle format with seconds (HH:MM:SS)
      if (timeStr.contains(':')) {
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          int hour = int.tryParse(parts[0]) ?? 0;
          int minute = int.tryParse(parts[1]) ?? 0;

          // Validate hour and minute ranges
          hour = hour.clamp(0, 23);
          minute = minute.clamp(0, 59);

          return TimeOfDay(hour: hour, minute: minute);
        }
      }

      // Try to parse as DateTime if it's a full datetime string
      try {
        final dateTime = DateTime.parse(timeStr);
        return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {
        // Not a valid datetime format
      }

      // If all else fails, return current time or default
      return TimeOfDay.now();
    } catch (e) {
      print('Error parsing time: $e');
      return const TimeOfDay(hour: 0, minute: 0);
    }
  }

  String _getAlertHumanReadable(int dueDays) {
    switch (dueDays) {
      case 0:
        return "Default";
      case 1:
        return "1 day before";
      case 2:
        return "2 days before";
      case 3:
        return "3 days before";
      case 4:
        return "4 days before";
      case 5:
        return "5 days before";
      case 6:
        return "6 days before";
      case 7:
        return "1 week before";
      case 14:
        return "2 weeks before";
      case 30:
        return "1 month before";
      default:
        return "$dueDays days before";
    }
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    ReminderProvider provider,
  ) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      _showCupertinoDeleteDialog(context, provider);
    } else {
      _showMaterialDeleteDialog(context, provider);
    }
  }

  void _showCupertinoDeleteDialog(
    BuildContext context,
    ReminderProvider provider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Transform.scale(
        scale: 1.2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: CupertinoAlertDialog(
            title: Text(
              'Are you sure?',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w600,
                fontSize: 17.sp,
              ),
            ),
            content: Text(
              'Please confirm that you\'d like to delete this reminder',
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w400,
                fontSize: 12.sp,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.nunitoSans(
                    color: const Color(0xff0F77F0),
                    fontWeight: FontWeight.w600,
                    fontSize: 17.sp,
                  ),
                ),
              ),
              CupertinoDialogAction(
                onPressed: () async {
                  final success = await provider.deleteReminder(_reminder!.id);
                  Navigator.pop(context);
                  Navigator.pop(context, true);
                  if (success && context.mounted) {
                    _showCupertinoSnackBar(
                      context,
                      'Reminder deleted successfully',
                      isError: false,
                    );
                  } else if (context.mounted) {
                    _showCupertinoSnackBar(
                      context,
                      provider.error ?? 'Failed to delete reminder',
                      isError: true,
                    );
                  }
                },
                isDestructiveAction: true,
                child: Text(
                  'Delete',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff0F77F0),
                    fontSize: 17.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMaterialDeleteDialog(
    BuildContext context,
    ReminderProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xffF7F7F7),
        title: Text(
          'Are you sure?',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w600,
            fontSize: 17.sp,
          ),
        ),
        content: Text(
          'Please confirm that you\'d like to delete this reminder',
          style: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w400,
            fontSize: 13.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.nunitoSans(
                color: const Color(0xff5856D6),
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              final success = await provider.deleteReminder(_reminder!.id);
              Navigator.pop(context);
              Navigator.pop(context, true);
              if (success && context.mounted) {
                _showCupertinoSnackBar(
                  context,
                  'Reminder deleted successfully',
                  isError: false,
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      provider.error ?? 'Failed to delete reminder',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(
              'Delete',
              style: GoogleFonts.nunitoSans(
                color: const Color(0xff5856D6),
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCupertinoSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    Fluttertoast.showToast(
      backgroundColor: Colors.green,
      textColor: Colors.white,
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
