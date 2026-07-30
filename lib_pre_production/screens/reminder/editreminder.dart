// edit_reminder.dart
import 'package:GapHub/models/remindermodel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/provider/reminderProvider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'addreminder.dart';
import 'widget/calendarWidget.dart';
import 'widget/timePickerWidget.dart';

class EditReminder extends StatefulWidget {
  final ReminderModel? reminder;

  const EditReminder({super.key, required this.reminder});

  @override
  State<EditReminder> createState() => _EditReminderState();
}

class _EditReminderState extends State<EditReminder> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isDateExpanded = false;
  bool _isTimeExpanded = false;
  String _selectedAlert = "Default (5 minutes)";
  // Track if changes were made
  final bool _hasChanges = false;

  final List<String> _alertOptions = [
    "Default (5 minutes)",
    "10 minutes before",
    "30 minutes before",
    "1 hour before",
    "2 hours before",
    "1 day before",
    "2 days before",
  ];
  @override
  void initState() {
    super.initState();
    // Initialize with existing reminder data
    _titleController.text = widget.reminder!.name;
    _noteController.text = widget.reminder!.note ?? '';
    _amountController.text = widget.reminder!.amount.toString();
    _selectedDate = DateTime.parse(widget.reminder!.date);
    _selectedTime = _parseTimeString(widget.reminder!.time ?? "00:00");
    _selectedAlert = widget.reminder!.alertHumanReadable!;
    print("Initialized Alert: $_selectedAlert");
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    var currency = context.watch<Providers>().snapshotmodel.currency;

    return WillPopScope(
      onWillPop: () async {
        if (_hasChanges) {
          _showDiscardConfirmation(context);
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => _onBackPressed(context),
          ),
          title: Text(
            "Edit Reminder",
            style: GoogleFonts.nunitoSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Title and Note Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xffEEEEEE),
                        width: 1.0,
                      ),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        TextField(
                          controller: _titleController,
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.sp,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Title",
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                              color: Color(
                                AppColors.grayColor.value,
                              ).withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                        const Divider(
                          color: Color(0xffE0E0E0),
                          thickness: 1.0,
                          height: 1,
                        ),
                        TextField(
                          controller: _noteController,
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w400,
                            fontSize: 15.sp,
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "Note",
                            hintStyle: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 15.sp,
                              color: Color(
                                AppColors.grayColor.value,
                              ).withOpacity(0.6),
                            ),
                            border: InputBorder.none,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 15.sp),

                  // Amount Input
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xffEEEEEE),
                        width: 1.0,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: Row(
                      children: [
                        Text(
                          currency,
                          style: GoogleFonts.nunitoSans(
                            fontWeight: FontWeight.w600,
                            fontSize: 24.sp,
                            color: const Color(0xff010101),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              ThousandSeparatedDecimalFormatter(),
                            ],
                            style: GoogleFonts.nunitoSans(
                              fontWeight: FontWeight.w400,
                              fontSize: 24.sp,
                              color: Colors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: "0.00",
                              hintStyle: GoogleFonts.nunitoSans(
                                fontWeight: FontWeight.w400,
                                fontSize: 24.sp,
                                color: const Color(0xffafafaf),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Date Field
                  Column(
                    children: [
                      _ReminderTile(
                        image: 'assets/images/Calendar.png',
                        title: "Date",
                        subtitle: _selectedDate != null
                            ? DateFormat(
                                'EEEE, MMMM dd, yyyy',
                              ).format(_selectedDate!)
                            : "No set date",
                        subtitleColor: _selectedDate != null
                            ? AppColors.primaryColor
                            : AppColors.grayColor,
                        onTap: _toggleDateExpansion,
                        isExpanded: _isDateExpanded,
                      ),
                      if (_isDateExpanded) ...[
                        CalendarWidget(
                          selectedDate: _selectedDate,
                          onDateSelected: (DateTime date) {
                            setState(() {
                              _selectedDate = date;
                            });
                          },
                          isExpanded: _isDateExpanded,
                        ),
                        SizedBox(height: 10.h),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.sp),

                  // Time Field
                  Column(
                    children: [
                      _ReminderTile(
                        image: 'assets/images/Time.png',
                        title: "Time",
                        subtitle: _selectedTime != null
                            ? _formatTime(_selectedTime!)
                            : "No time set",
                        subtitleColor: _selectedTime != null
                            ? Colors.red
                            : AppColors.grayColor,
                        onTap: _toggleTimeExpansion,
                        isExpanded: _isTimeExpanded,
                      ),
                      if (_isTimeExpanded) ...[
                        TimePickerWidget(
                          selectedTime: _selectedTime,
                          onTimeSelected: (TimeOfDay time) {
                            setState(() {
                              _selectedTime = time;
                            });
                          },
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.sp),

                  // Alert Field
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 15.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: const Color(0xffEEEEEE),
                        width: 1.0,
                      ),
                    ),
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
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Transform.translate(
                                offset: const Offset(0, 12),
                                child: Text(
                                  "Alert",
                                  style: GoogleFonts.nunitoSans(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Transform.translate(
                                offset: const Offset(0, 0),
                                child: DropdownButton<String>(
                                  value: _selectedAlert,
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  icon: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.keyboard_arrow_up_rounded,
                                        color: Colors.grey,
                                      ),
                                      Transform.translate(
                                        offset: const Offset(0, -14),
                                        child: const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  alignment: Alignment.centerRight,
                                  items: _alertOptions.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: GoogleFonts.nunitoSans(
                                          fontSize: 14.sp,
                                          color: value == _selectedAlert
                                              ? AppColors.primaryColor
                                              : Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedAlert = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Error message display
                  if (reminderProvider.error != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      margin: EdgeInsets.only(top: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryColor),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error,
                            color: AppColors.primaryColor,
                            size: 20.w,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              reminderProvider.error!,
                              style: GoogleFonts.nunitoSans(
                                fontSize: 12.sp,
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.close, size: 14.w),
                            onPressed: () => reminderProvider.clearError(),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: 80.h),

                  if (reminderProvider.isLoading)
                    Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_isFormComplete)
                    SizedBox(
                      width: double.infinity,
                      height: 60.h,
                      child: ElevatedButton.icon(
                        onPressed: _validateAndSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 16.h,
                            horizontal: 32.w,
                          ),
                        ),
                        label: Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _isFormComplete {
    return _titleController.text.trim().isNotEmpty &&
        _noteController.text.trim().isNotEmpty &&
        _amountController.text.trim().isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null &&
        _selectedAlert.isNotEmpty;
  }

  void _toggleDateExpansion() {
    setState(() {
      _isDateExpanded = !_isDateExpanded;
      if (_isDateExpanded) {
        _isTimeExpanded = false;
      }
    });
  }

  void _toggleTimeExpansion() {
    setState(() {
      _isTimeExpanded = !_isTimeExpanded;
      if (_isTimeExpanded) {
        _isDateExpanded = false;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'am' : 'pm';
    return '$hour:$minute $period';
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  // Validation and submission method for editing
  Future<void> _validateAndSubmit() async {
    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    FocusScope.of(context).unfocus();

    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a title for the reminder');
      return;
    }

    if (_amountController.text.trim().isEmpty) {
      _showErrorDialog('Please enter an amount');
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showErrorDialog('Please select both date and time for the reminder');
      return;
    }
    var currency = context.read<Providers>().snapshotmodel.currency;

    final success = await reminderProvider.updateReminder(
      id: widget.reminder!.id,
      title: _titleController.text.trim(),
      note: _noteController.text.trim(),
      amount: _amountController.text.trim(),
      date: _selectedDate!,
      time: _selectedTime!,
      alert: _selectedAlert,
      currency: currency,
    );
    Provider.of<ReminderProvider>(
      context,
      listen: false,
    ).fetchReminders(currency);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reminder updated successfully!',
            style: GoogleFonts.nunitoSans(),
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
      Navigator.pop(context, true);
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Validation Error',
          style: GoogleFonts.nunitoSans(fontWeight: FontWeight.bold),
        ),
        content: Text(message, style: GoogleFonts.nunitoSans()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: GoogleFonts.nunitoSans()),
          ),
        ],
      ),
    );
  }

  void _onBackPressed(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      _showMaterialDiscardDialog(context);
    } else {
      _showMaterialDiscardDialog(context);
    }
  }

  Future<void> _showDiscardConfirmation(BuildContext context) async {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return _showCupertinoDiscardDialog(context);
    } else {
      return _showMaterialDiscardDialog(context);
    }
  }

  void _showCupertinoDiscardDialog(BuildContext context) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        padding: EdgeInsets.only(bottom: 50.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: const Color(0xCCFFFFFF),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
                border: Border.all(
                  color: const Color(0x3D181818), // rgba(24, 24, 24, 0.24)
                  width: 1.0,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context); // Close the action sheet
                    Navigator.pop(context); // Navigate back
                  },
                  child: Center(
                    child: Text(
                      'Discard Changes',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w400,
                        color: const Color(0xffFF3B2F),
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(horizontal: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context); // Just close the action sheet
                  },
                  child: Center(
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.nunitoSans(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff0F77F0),
                        fontSize: 20.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMaterialDiscardDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(height: 10.h),
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Center(
                  child: Container(
                    height: 5.h,
                    width: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xff79747E),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15.h),

              // Discard Button - Left Aligned
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                title: Text(
                  'Discard Changes',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xffDC362E),
                  ),
                  textAlign: TextAlign.left,
                ),
                onTap: () {
                  Navigator.pop(context); // Close bottom sheet
                  Navigator.pop(context); // Navigate back
                },
              ),
              SizedBox(height: 10.h),
              // Cancel Button - Left Aligned
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                title: Text(
                  'Cancel',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xff000000),
                  ),
                  textAlign: TextAlign.left,
                ),
                onTap: () {
                  Navigator.pop(context); // Just close bottom sheet
                },
              ),
              SizedBox(height: 16.h),
            ],
          ),
        );
      },
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? subtitleColor;
  final bool isExpanded;

  const _ReminderTile({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.subtitleColor,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7F7),
          // borderRadius: BorderRadius.circular(15),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isExpanded
                ? const Radius.circular(0)
                : const Radius.circular(15),
            bottomRight: isExpanded
                ? const Radius.circular(0)
                : const Radius.circular(15),
          ),
          border: Border.all(color: const Color(0xffEEEEEE), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xffE4E4E4), width: 0.5),
              ),
              child: Center(child: Image.asset(image, width: 28.w)),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.nunitoSans(
                      fontSize: 14.sp,
                      color: subtitleColor ?? AppColors.grayColor,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isExpanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
