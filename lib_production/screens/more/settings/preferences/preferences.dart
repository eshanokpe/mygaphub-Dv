import 'package:GapHub/models/preferencesModel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'marketingCommunication.dart';

class Preferences extends StatefulWidget {
  const Preferences({super.key});

  @override
  _PreferencesState createState() => _PreferencesState();
}

class _PreferencesState extends State<Preferences> {
  @override
  void initState() {
    super.initState();
    // Fetch settings when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PreferencesModel>(context, listen: false).fetchSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<PreferencesModel>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Preferences',
          style: GoogleFonts.nunitoSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PreferenceItem(
                title: 'Payment Reminders',
                subtitle:
                    'Alerts for upcoming or overdue bills and all payments',
                value: settings.paymentReminders,
                onChanged: (bool value) {
                  settings.updateSetting('payment_reminders', value);
                },
              ),
              PreferenceItem(
                title: 'Acquisition Opportunities',
                subtitle:
                    'Alerts for promising new asset acquisition opportunities that could be advantageous',
                value: settings.acquisitionOpportunities,
                onChanged: (bool value) {
                  settings.updateSetting('acquisition_opportunities', value);
                },
              ),
              PreferenceItem(
                title: 'News & Updates',
                subtitle:
                    'Receive emails and push notifications about exclusive offers we think you\'ll love',
                value: settings.newsUpdates,
                onChanged: (bool value) {
                  settings.updateSetting('news_updates', value);
                },
              ),
              PreferenceItem(
                title: 'Personal Strategy',
                subtitle:
                    'Key reminders for your personal strategies aimed at achieving your goals',
                value: settings.personalStrategy,
                onChanged: (bool value) {
                  settings.updateSetting('personal_strategy', value);
                },
              ),
              PreferenceItem(
                title: 'Personalised Insights',
                subtitle:
                    'Spending analysis, financial tips, or market updates',
                value: settings.personalizedInsights,
                onChanged: (bool value) {
                  settings.updateSetting('personalized_insights', value);
                },
              ),
              const Divider(
                color: Color(0xffeeeeee),
                thickness: 0.5,
                height: 32,
              ),
              PreferenceItem2(
                title: 'Marketing & Promotions',
                subtitle:
                    'Get personalised marketing, news, promotions, and offers from myGAPHub',
                value: settings.marketingPromotions,
                onChanged: (bool value) {
                  settings.updateSetting('marketing_promotions', value);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Marketing Communication',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: settings.marketingPromotions
                        ? Colors.black
                        : Colors.grey, // Greyed out when toggle is off
                  ),
                ),
                subtitle: Text(
                  settings.marketingDeliveryMethod == 'push'
                      ? 'Push Notifications'
                      : settings.marketingDeliveryMethod == 'email'
                      ? 'Email'
                      : settings.marketingDeliveryMethod == 'all'
                      ? 'All'
                      : 'None',
                  style: GoogleFonts.nunitoSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: settings.marketingPromotions
                        ? Colors.black87
                        : Colors.grey, // Greyed out too
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: settings.marketingPromotions
                      ? const Color(0xffa6a6a6)
                      : Colors.grey, // Dims the icon
                  size: 16.sp,
                ),
                onTap: settings.marketingPromotions
                    ? () => _showMarketingCommunicationBottomSheet(settings)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMarketingCommunicationBottomSheet(PreferencesModel settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(58.r), // Adjust radius as needed
        ),
      ),
      builder: (BuildContext context) {
        return MarketingCommunicationSheet(
          selectedOption: settings.marketingDeliveryMethod,
          onOptionSelected: (String option) {
            settings.updateMarketingDeliveryMethod(option);
            Navigator.pop(context); // Close bottom sheet after selection
          },
        );
      },
    );
  }
}

class PreferenceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PreferenceItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 0.w),
      title: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Text(
          subtitle,
          style: GoogleFonts.nunitoSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: GestureDetector(
        onTap: () {
          onChanged(!value); // Toggle the value
          print('value: ${!value}');
        },
        child: Container(
          width: 50, // Exact width
          height: 30, // Exact height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: value
                ? AppColors.primaryColor
                : const Color.fromARGB(31, 118, 118, 128),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: value ? 22 : 2, // Adjust based on your width
                top: 2,
                child: Container(
                  width: 26, // Thumb size
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Switch(
      //   value: value,
      //   onChanged: onChanged,
      //   activeColor: Colors.white, // Active color for switch
      //   activeTrackColor: AppColors.primaryColor,
      // ),
    );
  }
}

class PreferenceItem2 extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const PreferenceItem2({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GoogleFonts.nunitoSans(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Text(
          subtitle,
          style: GoogleFonts.nunitoSans(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      trailing: GestureDetector(
        onTap: () {
          onChanged(!value); // Toggle the value
          print('value: ${!value}');
        },
        child: Container(
          width: 50, // Exact width
          height: 30, // Exact height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: value
                ? AppColors.primaryColor
                : const Color.fromARGB(31, 118, 118, 128),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                left: value ? 22 : 2, // Adjust based on your width
                top: 2,
                child: Container(
                  width: 26, // Thumb size
                  height: 26,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ),
      //       trailing: Transform.scale(
      //         scale: 1.1, // Increase this for a larger toggle
      //         child: GFToggle(
      //           onChanged: (val) {
      //             onChanged(val!);
      //             print('value: $val');
      //           },
      //           disabledTrackColor: const Color.fromARGB(31, 118, 118, 128),
      //           enabledTrackColor: AppColors.primaryColor,
      //           value: value,
      //           type: GFToggleType.ios,
      //         ),
      //       ),
    );
  }
}
