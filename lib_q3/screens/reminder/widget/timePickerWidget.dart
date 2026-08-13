import 'package:GapHub/utils/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TimePickerWidget extends StatefulWidget {
  final TimeOfDay? selectedTime;
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerWidget({
    super.key,
    required this.selectedTime,
    required this.onTimeSelected,
  });

  @override
  State<TimePickerWidget> createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  bool _hasTriggered = false;

  @override
  void initState() {
    super.initState();
    // Trigger the time picker once when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasTriggered) {
        _hasTriggered = true;
        // Check platform here instead of in initState
        if (Theme.of(context).platform != TargetPlatform.iOS) {
          _showMaterialTimePicker(context);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use Cupertino for iOS, Material for Android
    return Theme.of(context).platform == TargetPlatform.iOS
        ? _buildCupertinoTimePicker()
        : _buildMaterialTimePicker();
    // return    _buildMaterialTimePicker();
  }

  Widget _buildCupertinoTimePicker() {
    final now = DateTime.now();
    final initialDateTime = widget.selectedTime != null
        ? DateTime(
            now.year,
            now.month,
            now.day,
            widget.selectedTime!.hour,
            widget.selectedTime!.minute,
          )
        : now;

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
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          // Cupertino Style Time Picker
          SizedBox(
            height: 200.h,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: Brightness.light,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: GoogleFonts.nunitoSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                  pickerTextStyle: GoogleFonts.nunitoSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                initialDateTime: initialDateTime,
                onDateTimeChanged: (DateTime newDateTime) {
                  widget.onTimeSelected(TimeOfDay.fromDateTime(newDateTime));
                },
                use24hFormat: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialTimePicker() {
    return SizedBox(height: 0, width: 0);
  }

  Future<void> _showMaterialTimePicker(BuildContext context) async {
    print('Showing time picker...');
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: widget.selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        const locale = Locale('en', 'US'); // Forces AM/PM format

        return Theme(
          data: _buildShrineTheme().copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: const Color(0xffECE6F0),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),

              // Dial appearance (clock face)
              dialBackgroundColor: const Color(0xFFE6E0E9),
              dialHandColor: const Color(0xff6750A4),
              dialTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return Colors.black87;
              }),

              // Hour & minute text fields
              hourMinuteTextColor: const Color(0xff6750A4),
              hourMinuteShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              hourMinuteTextStyle: GoogleFonts.roboto(
                fontSize: 57.sp,
                fontWeight: FontWeight.w400,
                color: Colors.red,
              ),

              // 🟦 AM/PM Toggle styling (important for 12-hour style)
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xffFFD8E4); // selected background
                }
                return Colors.transparent; // unselected background
              }),
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xff633B48); // selected text
                }
                return const Color(0xff49454F); // unselected text
              }),
              dayPeriodTextStyle: GoogleFonts.roboto(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
              dayPeriodShape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              dayPeriodBorderSide: WidgetStateBorderSide.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const BorderSide(color: Color(0xff79747E), width: 1.5);
                }
                return const BorderSide(color: Color(0xff79747E), width: 1);
              }),

              // Header (top label like “SELECT TIME”)
              helpTextStyle: GoogleFonts.roboto(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),

              entryModeIconColor: const Color(0xff49454F),
            ),
          ),
          child: Localizations.override(
            context: context,
            locale: locale,
            child: MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(alwaysUse24HourFormat: false),
              child: child!,
            ),
          ),
        );
      },
    );

    print('Time picker closed. Picked time: $pickedTime');

    _hasTriggered = false; // reset trigger flag

    if (pickedTime != null) {
      widget.onTimeSelected(pickedTime);
    }
  }
}

ThemeData _buildShrineTheme() {
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    // colorScheme: const ColorScheme(
    //   primary: Color(0xFF6750A4),
    //   primaryContainer: Color(0xFFEADDFF),
    //   secondary: shrinePink50,
    //   surface: Color(0xffE6E0E9),
    //   onSurface: Colors.black,
    //   onSecondaryContainer: Color(  0xFF49454F),
    //   // background: shrineBackgroundWhite,
    //   error: shrineErrorRed,
    //   onPrimary: Color(0xff4F378A),
    //   onSecondary: Colors.black,
    //   onError: Color(0xffE6E0E9),
    //   brightness: Brightness.light,
    // ),
    scaffoldBackgroundColor: shrineBackgroundWhite,
    textTheme: _buildShrineTextTheme(base.textTheme),
  );
}

TextTheme _buildShrineTextTheme(TextTheme base) {
  return base.apply(
    fontFamily: 'Rubik',
    displayColor: Colors.black,
    bodyColor: const Color(0xff49454F),
  );
}

const Color shrinePink50 = Color(0xFFE6E0E9);
const Color shrineErrorRed = Color(0xFFC5032B);
const Color shrineBackgroundWhite = Colors.red;

extension TimeOfDayExtension on TimeOfDay {
  int get hourOfPeriod {
    return hour % 12 == 0 ? 12 : hour % 12;
  }
}
