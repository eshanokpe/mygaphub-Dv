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
import 'widget/calendarWidget.dart';
import 'widget/timePickerWidget.dart';

class AddReminder extends StatefulWidget {
  const AddReminder({super.key});

  @override
  State<AddReminder> createState() => _AddReminderState();
}

class _AddReminderState extends State<AddReminder> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isDateExpanded = false;
  bool _isTimeExpanded = false;
  bool _isSubmitting = false;
  String _selectedAlert = "Default (5 minutes)"; // Add this

  // Add this list of alert options
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
    _titleController.addListener(() => setState(() {}));
    _noteController.addListener(() => setState(() {}));
    _amountController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    var currency = context.watch<Providers>().snapshotmodel.currency;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return PopScope(
      canPop: !_isFormCompleteDialog,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isFormCompleteDialog) {
          _showDiscardConfirmation(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              print("_isFormCompleteDialog:$_isFormCompleteDialog");
              if (_isFormCompleteDialog) {
                _onBackPressed(context);
              } else {
                Navigator.of(context).pop();
              }
            },
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
                  Text(
                    "Reminder",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  // SizedBox(height: 4.h),
                  Text(
                    "Set up a new reminder",
                    style: GoogleFonts.nunitoSans(
                      fontSize: 16.sp,
                      color: AppColors.grayColor,
                    ),
                  ),
                  const SizedBox(height: 25),

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
                        // ✅ Horizontal line between Title and Note
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

                  // Date Field with Expandable Calendar
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

                  // Time Field with Expandable Time Picker
                  Column(
                    children: [
                      _ReminderTile(
                        image: 'assets/images/Time.png',
                        title: "Time",
                        subtitle: _selectedTime != null
                            ? _formatTime(_selectedTime!) // Use custom format
                            : "No time set",
                        subtitleColor: _selectedTime != null
                            ? Colors
                                  .red // Red color when time is set
                            : AppColors
                                  .grayColor, // Default color when no time set
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
                        // SizedBox(height: 10.h),
                      ],
                    ],
                  ),
                  SizedBox(height: 16.sp),

                  // Alert Field with DropdownButton
                  Container(
                    padding: EdgeInsets.only(left: 15.w, top: 8.h, right: 0),
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
                              Builder(
                                builder: (context) {
                                  return Transform.translate(
                                    offset: const Offset(-20, 0),
                                    child: PopupMenuButton<String>(
                                      itemBuilder: (BuildContext context) =>
                                          _alertOptions.map((String value) {
                                            final int index = _alertOptions
                                                .indexOf(value);
                                            return PopupMenuItem<String>(
                                              padding: EdgeInsets.zero,
                                              value: value,
                                              child: Container(
                                                width: double.infinity,
                                                decoration: BoxDecoration(
                                                  border:
                                                      index <
                                                          _alertOptions.length -
                                                              1
                                                      ? Border(
                                                          bottom: BorderSide(
                                                            color: const Color(
                                                              0xff808080,
                                                            ).withOpacity(0.5),
                                                            width: 1.0,
                                                          ),
                                                        )
                                                      : null,
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    vertical: 12.h,
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 8.w,
                                                        ),
                                                    child: Text(
                                                      value,
                                                      style: GoogleFonts.nunitoSans(
                                                        fontSize: 14.sp,
                                                        color:
                                                            value ==
                                                                _selectedAlert
                                                            ? AppColors
                                                                  .primaryColor
                                                            : Colors.black,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                      onSelected: (String newValue) {
                                        setState(() {
                                          _selectedAlert = newValue;
                                        });
                                      },
                                      // Add these properties for styling
                                      color: const Color(
                                        0xffF7F7F7,
                                      ), // White background
                                      elevation: 0, // Shadow
                                      shape: RoundedRectangleBorder(
                                        // Border radius
                                        borderRadius: BorderRadius.circular(15),
                                        side: BorderSide(
                                          // Add border color here
                                          color: const Color(0xff808080)
                                              .withOpacity(
                                                0.2,
                                              ), // Your desired border color
                                          width: 1.0,
                                        ),
                                      ),
                                      constraints: BoxConstraints(
                                        minWidth: 230
                                            .w, // Adjust this value as needed
                                        maxWidth: 300
                                            .w, // Adjust this value as needed
                                      ),
                                      // Try different offset strategies:
                                      offset: Offset(
                                        20,
                                        -(42.h * _alertOptions.length + 60),
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          left: 15.h,
                                          top: 0.w,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedAlert,
                                                style: GoogleFonts.nunitoSans(
                                                  fontSize: 14.sp,
                                                  color:
                                                      _selectedAlert.isNotEmpty
                                                      ? AppColors.primaryColor
                                                      : Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  Icons
                                                      .keyboard_arrow_up_rounded,
                                                  color: Colors.grey,
                                                ),
                                                Transform.translate(
                                                  offset: const Offset(0, -14),
                                                  child: const Icon(
                                                    Icons
                                                        .keyboard_arrow_down_rounded,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                  SizedBox(height: 40.h),
                  if (reminderProvider.isLoading)
                    Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  else if (_isFormComplete && !_isSubmitting)
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
                          'Create Reminder',
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

  bool get _isFormCompleteDialog {
    return _titleController.text.trim().isNotEmpty ||
        _noteController.text.trim().isNotEmpty ||
        _amountController.text.trim().isNotEmpty ||
        _selectedDate != null ||
        _selectedTime != null;
  }

  bool get _isFormComplete {
    return _titleController.text.trim().isNotEmpty &&
        _noteController.text.trim().isNotEmpty &&
        // _amountController.text.trim().isNotEmpty &&
        _selectedDate != null &&
        _selectedTime != null &&
        _selectedAlert.isNotEmpty;
  }

  void _toggleDateExpansion() {
    setState(() {
      _isDateExpanded = !_isDateExpanded;
      // Close time picker if date is expanded
      if (_isDateExpanded) {
        _isTimeExpanded = false;
      }
    });
  }

  void _toggleTimeExpansion() {
    setState(() {
      _isTimeExpanded = !_isTimeExpanded;
      // Close date picker if time is expanded
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
    final hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod; // Convert 0 to 12 for 12-hour format
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'am' : 'pm';

    return '$hour:$minute $period';
  }

  Future<void> _validateAndSubmit() async {
    // Prevent multiple submissions
    if (_isSubmitting) return;

    _isSubmitting = true;

    final reminderProvider = Provider.of<ReminderProvider>(
      context,
      listen: false,
    );
    FocusScope.of(context).unfocus();

    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      _showErrorDialog('Please enter a title for the reminder');
      _isSubmitting = false;
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      _showErrorDialog('Please select both date and time for the reminder');
      _isSubmitting = false;
      return;
    }

    try {
      var currency = context.read<Providers>().snapshotmodel.currency;

      final success = await reminderProvider.createReminder(
        title: _titleController.text.trim(),
        note: _noteController.text.trim(),
        amount: _amountController.text.trim(),
        date: _selectedDate,
        time: _selectedTime,
        alert: _selectedAlert,
        currency: currency,
      );

      if (!mounted) {
        _isSubmitting = false;
        return;
      }

      if (success) {
        var currency = context.read<Providers>().snapshotmodel.currency;

        await Future.delayed(const Duration(seconds: 2));

        final reminderProvider = Provider.of<ReminderProvider>(
          context,
          listen: false,
        );
        await reminderProvider.fetchReminders(currency);

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Reminder created successfully!',
                style: GoogleFonts.nunitoSans(),
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error submitting: $e');
    } finally {
      _isSubmitting = false;
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
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(14),
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

  void _onBackPressed(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      _showCupertinoDiscardDialog(context);
    } else {
      _showMaterialDiscardDialog(context);
    }
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

class ThousandSeparatedDecimalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text;

    if (newText.isEmpty) {
      return newValue;
    }

    // 1. Filter to allow only digits and at most one decimal point.
    String filtered = '';
    bool decimalFound = false;
    for (int i = 0; i < newText.length; i++) {
      if (RegExp(r'\d').hasMatch(newText[i])) {
        filtered += newText[i];
      } else if (newText[i] == '.' && !decimalFound) {
        filtered += newText[i];
        decimalFound = true;
      }
    }

    // 2. Split into integer and decimal parts.
    List<String> parts = filtered.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // 3. Limit decimal part to 2 digits.
    if (decimalPart.length > 2) {
      decimalPart = decimalPart.substring(0, 2);
    }

    // 4. Sanitize and Format integer part with commas.
    String formattedIntegerPart = "";
    if (integerPart.isNotEmpty) {
      integerPart = BigInt.parse(
        integerPart,
      ).toString(); // Handles leading zeros like "007" -> "7", "0" -> "0"
      int len = integerPart.length;
      for (int i = 0; i < len; i++) {
        formattedIntegerPart += integerPart[i];
        if ((len - 1 - i) % 3 == 0 && (len - 1 - i) != 0) {
          formattedIntegerPart += ',';
        }
      }
    } else if (filtered.contains('.')) {
      // Input was like ".5"
      formattedIntegerPart = "0";
    }

    // 5. Reconstruct the text.
    String resultText = formattedIntegerPart;
    if (filtered.contains('.')) {
      // If original filtered text had a decimal
      resultText += '.$decimalPart';
    }

    // 6. Adjust cursor position (basic adjustment).
    int cursorPosition =
        newValue.selection.end + (resultText.length - newText.length);
    cursorPosition = cursorPosition.clamp(0, resultText.length);

    return TextEditingValue(
      text: resultText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }
}
