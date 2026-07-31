import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CalendarWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isExpanded;

  const CalendarWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.isExpanded,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime? _currentMonth;
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    _currentMonth = widget.selectedDate ?? DateTime.now();
    // Auto-show date picker when widget is expanded (for Android)
    if (widget.isExpanded == true) {
      _triggerDatePicker();
    }
  }

  @override
  void didUpdateWidget(CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-show when widget becomes expanded and we haven't triggered yet
    if (widget.isExpanded && !oldWidget.isExpanded && !_hasTriggered) {
      _triggerDatePicker();
    }
  }

  void _triggerDatePicker() {
    print(" CalendarWidget initialized with isExpanded: ${widget.isExpanded}");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasTriggered && Theme.of(context).platform != TargetPlatform.iOS) {
        _hasTriggered = true;
        _showMaterialDatePicker(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use current calendar logic for iOS, Material date picker for Android
    // return _buildMaterialDatePicker();
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _buildCurrentCalendar()
        : _buildMaterialDatePicker();
  }

  Widget _buildCurrentCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(15),
          bottomRight: Radius.circular(15),
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
        border: Border.all(color: const Color(0xffEEEEEE), width: 1.0),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        children: [
          // Month/Year Header with Navigation
          _buildCalendarHeader(),
          // Calendar Grid
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildMaterialDatePicker() {
    return const SizedBox.shrink();
  }

  Future<void> _showMaterialDatePicker(BuildContext context) async {
    DateTime selectedDate = widget.selectedDate ?? DateTime.now();
    bool isCalendarView = true; // 🔁 track current view mode

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: const Color(0xFFECE6F0),
              insetPadding: EdgeInsets.symmetric(
                horizontal: 16.w, // 👈 reduce dialog margin
                vertical: 10.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 🟣 Header Section
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Select date",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff000000),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 📅 Selected Date Display
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('EEE, MMM d').format(selectedDate),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff1D1B20),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // 🔁 Toggle between calendar and manual input
                              setState(() {
                                isCalendarView = !isCalendarView;
                              });
                            },
                            child: Icon(
                              isCalendarView
                                  ? Icons.edit
                                  : Icons.calendar_month,
                              color: const Color(0xff000000),
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(),
                    const SizedBox(height: 8),

                    // 🔄 Switch between Calendar or Manual Input
                    if (isCalendarView)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Localizations.override(
                          context: context,
                          locale: const Locale(
                            'en',
                            'US',
                          ), // Week starts on Sunday
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              datePickerTheme: const DatePickerThemeData(
                                headerForegroundColor: Colors
                                    .black, // 👈 Makes month, year & arrows black
                                headerBackgroundColor: Colors.transparent,
                                dayForegroundColor: WidgetStatePropertyAll(
                                  Colors.black,
                                ),
                              ),
                              textTheme: const TextTheme(
                                bodyLarge: TextStyle(color: Colors.black),
                                bodyMedium: TextStyle(color: Colors.black),
                              ),
                              iconTheme: const IconThemeData(
                                color:
                                    Colors.black, // 👈 Ensures arrows are black
                              ),
                              colorScheme: const ColorScheme.light(
                                primary: Color(0xff6750A4),
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                            ),
                            child: SizedBox(
                              // height: 260,
                              child: CalendarDatePicker(
                                initialDate: selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                onDateChanged: (date) {
                                  setState(() {
                                    selectedDate = date;
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: TextEditingController(
                            text: DateFormat('yyyy-MM-dd').format(selectedDate),
                          ),
                          decoration: InputDecoration(
                            labelText: 'Enter date (yyyy-MM-dd)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          onSubmitted: (value) {
                            try {
                              final parsedDate = DateTime.parse(value);
                              setState(() {
                                selectedDate = parsedDate;
                              });
                            } catch (_) {}
                          },
                        ),
                      ),

                    // Footer Buttons
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25.w,
                        vertical: 0,
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Text(
                                  "Close",
                                  style: TextStyle(
                                    color: Color(0xff6750A4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      widget.onDateSelected(selectedDate);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("OK"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCalendarHeader() {
    final now = DateTime.now();
    final currentMonth = _currentMonth ?? now;

    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DateFormat('MMMM yyyy').format(currentMonth),
                style: GoogleFonts.nunitoSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              IconButton(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: BoxConstraints(minWidth: 24.w, minHeight: 24.h),
                icon: Icon(
                  Icons.chevron_right,
                  color: const Color(0xff007AFF),
                  size: 20.w,
                ),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      currentMonth.year,
                      currentMonth.month + 1,
                      1,
                    );
                  });
                },
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: const Color(0xff007AFF),
                  size: 20.w,
                ),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      currentMonth.year,
                      currentMonth.month - 1,
                      1,
                    );
                  });
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: const Color(0xff007AFF),
                  size: 20.w,
                ),
                onPressed: () {
                  setState(() {
                    _currentMonth = DateTime(
                      currentMonth.year,
                      currentMonth.month + 1,
                      1,
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final now = DateTime.now();
    final currentMonth = _currentMonth ?? now;
    final firstDay = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);

    // Adjust so week starts on Sunday (0)
    int startingWeekday = firstDay.weekday % 7;

    // Calculate total cells needed
    int totalDays = lastDay.day + startingWeekday;
    int totalWeeks = (totalDays / 7).ceil();

    return Column(
      children: [
        // Weekday headers (SUN → SAT)
        Row(
          children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map((
            day,
          ) {
            return Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  day.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xff3c3c43).withOpacity(0.3),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        // Calendar grid
        ...List.generate(totalWeeks, (weekIndex) {
          return Row(
            children: List.generate(7, (dayIndex) {
              int dayNumber = (weekIndex * 7) + dayIndex + 1 - startingWeekday;

              if (dayNumber < 1 || dayNumber > lastDay.day) {
                // Empty cell
                return Expanded(child: Container());
              }

              final dayDate = DateTime(
                currentMonth.year,
                currentMonth.month,
                dayNumber,
              );
              final isSelected =
                  widget.selectedDate != null &&
                  widget.selectedDate!.year == dayDate.year &&
                  widget.selectedDate!.month == dayDate.month &&
                  widget.selectedDate!.day == dayDate.day;
              final isToday =
                  now.year == dayDate.year &&
                  now.month == dayDate.month &&
                  now.day == dayDate.day;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    widget.onDateSelected(dayDate);
                  },
                  child: isSelected
                      ? Container(
                          margin: EdgeInsets.all(2.w),
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(
                                    0xffE5F0FF,
                                  ) // light blue for today
                                : Colors.transparent,
                            borderRadius: isSelected
                                ? BorderRadius.circular(10)
                                : null, // remove circle for selected
                          ),
                          child: Center(
                            child: Text(
                              dayNumber.toString(),
                              style: GoogleFonts.nunitoSans(
                                fontSize: 18.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(0xff007AFF)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          margin: EdgeInsets.all(2.w),
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: isToday
                                ? const Color(
                                    0xffE5F0FF,
                                  ) // light blue for today
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            borderRadius: isSelected
                                ? BorderRadius.circular(10)
                                : null, // remove circle for selected
                          ),
                          child: Center(
                            child: Text(
                              dayNumber.toString(),
                              style: GoogleFonts.nunitoSans(
                                fontSize: 18.sp,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : isToday
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: isSelected
                                    ? Colors.white
                                    : isToday
                                    ? const Color(0xff007AFF)
                                    : Colors.black,
                              ),
                            ),
                          ),
                        ),
                ),
              );
            }),
          );
        }),
      ],
    );
  }
}
