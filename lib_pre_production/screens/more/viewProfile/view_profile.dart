import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/utils/constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../settings/avatarPickerButton.dart';
import 'deleteAccount/delete_account.dart';
import 'edit_country_profile.dart';
import 'edit_dateofbirth_profile.dart';
import 'edit_name_profile.dart';
import 'edit_phone_profile.dart';

class ViewProfile extends StatefulWidget {
  const ViewProfile({super.key});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  int _imageRefreshVersion = 0;

  String _processImageUrl(String? rawUrl) {
    print("rawUrl:$rawUrl");
    if (rawUrl == '$imgPrefix/storage/avatar/default.png') {
      return 'assets/settings/avatar1.png'; // local asset path
    }
    if (rawUrl == null) {
      return 'assets/settings/avatar1.png'; // local asset path
    }
    if (rawUrl == '$imgPrefix/assets/storage/avatar/Avatar_Male 1.png') {
      return 'assets/settings/avatar.png';
    }

    if (rawUrl.contains('/user/')) {
      return rawUrl.replaceFirst('//app/', '/');
    } else if (rawUrl.contains('/avatar/')) {
      return rawUrl.replaceFirst(
        "app.mygaphub.com/app/assets/storage/app",
        "app/assets/storage/",
      );
    }

    return 'assets/settings/avatar.png';
  }

  // Helper function to get flag emoji from country name
  String _getFlagEmoji(String countryName) {
    // Map of common country names to ISO country codes
    Map<String, String> countryCodes = {
      'United Kingdom': 'GB',
      'United States': 'US',
      'United States of America': 'US',
      'Nigeria': 'NG',
      'Ghana': 'GH',
      'Canada': 'CA',
      'Australia': 'AU',
      'Åland Islands': 'AX',
      'American Samoa': 'AS',
      'Anguilla': 'AI',
      'Antigua and Barbuda': 'AG',
      'Ascension Island': 'AC',
      'Aruba': 'AW',
      'Bahamas': 'BS',
      'Barbados': 'BB',
      'Germany': 'DE',
      'France': 'FR',
      'Faroe Islands': 'FO',
      'Fiji': 'FJ',
      'Italy': 'IT',
      'Spain': 'ES',
      'Brazil': 'BR',
      'India': 'IN',
      'China': 'CN',
      'Japan': 'JP',
      'South Africa': 'ZA',
      'Kenya': 'KE',
      'Egypt': 'EG',
      'Netherlands': 'NL',
      'Sweden': 'SE',
      'Norway': 'NO',
      'Denmark': 'DK',
      'Finland': 'FI',
      'Ireland': 'IE',
      'Portugal': 'PT',
      'Belgium': 'BE',
      'Switzerland': 'CH',
      'Austria': 'AT',
      'Poland': 'PL',
      'Russia': 'RU',
      'Mexico': 'MX',
      'Argentina': 'AR',
      'Chile': 'CL',
      'New Zealand': 'NZ',
      'Singapore': 'SG',
      'Malaysia': 'MY',
      'Indonesia': 'ID',
      'Philippines': 'PH',
      'South Korea': 'KR',
      'Thailand': 'TH',
      'Vietnam': 'VN',
      'UAE': 'AE',
      'Saudi Arabia': 'SA',
      'Turkey': 'TR',
      'Ukraine': 'UA',
      'Greece': 'GR',
      'Czech Republic': 'CZ',
      'Hungary': 'HU',
      'Romania': 'RO',
      'Bulgaria': 'BG',
      'Croatia': 'HR',
      'Serbia': 'RS',
      'Slovakia': 'SK',
      'Slovenia': 'SI',
      'Estonia': 'EE',
      'Latvia': 'LV',
      'Lithuania': 'LT',
      'Luxembourg': 'LU',
      'Malta': 'MT',
      'Cyprus': 'CY',
      'Iceland': 'IS',
      'Liechtenstein': 'LI',
      'Monaco': 'MC',
      'San Marino': 'SM',
      'Andorra': 'AD',
      'Albania': 'AL',
      'Bosnia and Herzegovina': 'BA',
      'Macedonia': 'MK',
      'Montenegro': 'ME',
      'Kosovo': 'XK',
      'Moldova': 'MD',
      'Belarus': 'BY',
      'Georgia': 'GE',
      'Armenia': 'AM',
      'Azerbaijan': 'AZ',
      'Kazakhstan': 'KZ',
      'Uzbekistan': 'UZ',
      'Turkmenistan': 'TM',
      'Tajikistan': 'TJ',
      'Kyrgyzstan': 'KG',
      'Israel': 'IL',
      'Jordan': 'JO',
      'Lebanon': 'LB',
      'Syria': 'SY',
      'Iraq': 'IQ',
      'Iran': 'IR',
      'Afghanistan': 'AF',
      'Pakistan': 'PK',
      'Bangladesh': 'BD',
      'Sri Lanka': 'LK',
      'Nepal': 'NP',
      'Bhutan': 'BT',
      'Maldives': 'MV',
      'Myanmar': 'MM',
      'Laos': 'LA',
      'Cambodia': 'KH',
      'Mongolia': 'MN',
      'Taiwan': 'TW',
      'Hong Kong': 'HK',
      'Macau': 'MO',
      'Qatar': 'QA',
      'Kuwait': 'KW',
      'Oman': 'OM',
      'Bahrain': 'BH',
      'Yemen': 'YE',
      'Morocco': 'MA',
      'Algeria': 'DZ',
      'Tunisia': 'TN',
      'Libya': 'LY',
      'Sudan': 'SD',
      'South Sudan': 'SS',
      'Ethiopia': 'ET',
      'Somalia': 'SO',
      'Uganda': 'UG',
      'Tanzania': 'TZ',
      'Rwanda': 'RW',
      'Burundi': 'BI',
      'Zambia': 'ZM',
      'Zimbabwe': 'ZW',
      'Mozambique': 'MZ',
      'Angola': 'AO',
      'Namibia': 'NA',
      'Botswana': 'BW',
      'Lesotho': 'LS',
      'Eswatini': 'SZ',
      'Madagascar': 'MG',
      'Mauritius': 'MU',
      'Seychelles': 'SC',
      'Cape Verde': 'CV',
      'Senegal': 'SN',
      'Gambia': 'GM',
      'Guinea': 'GN',
      'Sierra Leone': 'SL',
      'Liberia': 'LR',
      "Côte d'Ivoire": 'CI',
      'Togo': 'TG',
      'Benin': 'BJ',
      'Cameroon': 'CM',
      'Chad': 'TD',
      'Niger': 'NE',
      'Mali': 'ML',
      'Burkina Faso': 'BF',
      'Guinea-Bissau': 'GW',
      'Equatorial Guinea': 'GQ',
      'Gabon': 'GA',
      'Republic of the Congo': 'CG',
      'Democratic Republic of the Congo': 'CD',
      'Central African Republic': 'CF',
      'Eritrea': 'ER',
      'Djibouti': 'DJ',
      'Comoros': 'KM',
      'São Tomé and Príncipe': 'ST',
      'Christmas Island': 'CX',
      'Cocos [Keeling] Islands': 'CCK',
      'Colombia': 'CO',
      'Western Sahara': 'EH',
      'Marshall Islands': 'MH',
      'Martinique': 'MQ',
      'Mauritania': 'MR',
      'Mayotte': 'YT',
      'Micronesia': 'FM',
      'Samoa': 'WS',
      'South Georgia and the South Sandwich Islands': 'GS',
      'Svalbard and Jan mayen': 'SJ',
      'Turks and Caicos Islands': 'TC',
      'United Arab Emirates': 'AE',
      'Uruguay': 'UY',
      'Vanuatu': 'VU',
      'Vatican City': 'VAT',
      'Wallis and Futuna': 'WF',
      'Guinea Conakry': 'GN',
      'Guernsey': 'GG',
      'Guatemala': 'GTM',
      'Greenland': 'GL',
      'Grenada': 'GRD',
      'Guadeloupe': 'GP',
      'Gibraltar': 'GIB',
      'French Polynesia': 'PF',
      'French Guiana': 'GF',
      'Guam': 'GU',
      'Falkland Islands (Islas Malvinas)': 'FK',
      'El Salvador': 'SLV',
      'Ecuador': 'EC',
      'East Timor': 'TP',
      'Dominican Republic': 'DO',
      'Dominica': 'DM',
      'Curaçao': 'CW',
      'Cuba': 'CU',
      'Costa Rica': 'CR',
      'Cook Islands': 'CK',
      'Republic of Congo': 'CG',
      'Malawi': 'MW',
      'Brunei': 'BN',
      'Bolivia': 'BO',
      'British Indian Ocean Territory': 'IO',
      'British Virgin Islands': 'VG',
      'Cocos (Keeling) Islands': 'CC',
      'Cayman Islands': 'KY',
      'Caribbean Netherlands': 'BQ',
      'Bermuda': 'BM',
      'Belize': 'BZ',
      'Democratic Republic Congo': 'CD',
      'Guyana': 'GY',
      'Haiti': 'HT',
      'Democrac Republic Congo': 'CD',
      'Heard island and Mc Donald': 'HM',
      'Honduras': 'HN',
      'Isle of man': 'IM',
      'Jamaica': 'JM',
      'Jersey': 'JE',
      'Kiribati': 'KI',
      'North Macedonia': 'MK',
    };

    String countryCode =
        countryCodes[countryName] ?? 'GB'; // Default to GB if not found

    // Convert country code to flag emoji
    final int firstLetter = countryCode.codeUnitAt(0) - 0x41 + 0x1F1E6;
    final int secondLetter = countryCode.codeUnitAt(1) - 0x41 + 0x1F1E6;

    return String.fromCharCode(firstLetter) + String.fromCharCode(secondLetter);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<Providers>();
    print("details:${provider.details[3]}");
    final firstName = provider.details[0];
    final lastName = provider.details[1];
    final email = provider.details[2];
    final phone = provider.details[3];
    final dobRaw = provider.details[4];
    final countryRaw = provider.details[6];

    final registrationDateRaw = provider.details.length > 9
        ? provider.details[9]
        : null;

    String registrationDateText;

    if (registrationDateRaw != null &&
        registrationDateRaw.toString().isNotEmpty &&
        registrationDateRaw.toString() != 'null') {
      try {
        final parsedDate = DateTime.parse(registrationDateRaw.toString());
        registrationDateText =
            'Registered ${DateFormat('MMMM yyyy').format(parsedDate)}';
      } catch (e) {
        registrationDateText = 'Registered date not available';
      }
    } else {
      registrationDateText = 'Registered date not available';
    }
    print('Imageprovider:${provider.details[7]}');
    final imageUrl = _processImageUrl(provider.details[7]);
    print('ImageimageUrl:$imageUrl');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Edit Profile',
          style: GoogleFonts.nunitoSans(
            color: Colors.black,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 100.w,
                  height: 100.h,
                  padding: EdgeInsets.all(0.sp),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color.fromRGBO(
                        0,
                        0,
                        0,
                        0.08,
                      ), // Equivalent to rgba(0, 0, 0, 0.08)
                      width: 3,
                    ),
                  ),
                  child: ClipOval(child: _buildImage(imageUrl)),
                ),
                // Pass callback to AvatarPickerButton to refresh image
                AvatarPickerButton(
                  onImageUploaded: (newImageUrl) {
                    final provider = Provider.of<Providers>(
                      context,
                      listen: false,
                    );
                    provider.setDetailsList(newImageUrl ?? '', 7);
                    if (newImageUrl != null && newImageUrl.isNotEmpty) {
                      CachedNetworkImage.evictFromCache(newImageUrl);
                    }
                    setState(() => _imageRefreshVersion++);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              registrationDateText,
              style: GoogleFonts.nunitoSans(
                color: AppColors.grayColor,
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 16),

            // Profile info container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildEditableRow(context, "First Name", firstName, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNameScreen(
                          initialName: firstName,
                          isFirstName: true,
                        ),
                      ),
                    );
                  }),
                  _buildEditableRow(context, "Last Name", lastName, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditNameScreen(
                          initialName: lastName,
                          isFirstName: false,
                        ),
                      ),
                    );
                  }),
                  _buildEditableRow(
                    context,
                    "Email Address",
                    email,
                    null,
                    isEditable: false,
                  ),
                  (phone == 'N/A' || phone.isEmpty || phone == 'null')
                      ? _buildWarningRow(
                          context,
                          "WhatsApp/Mobile Number",
                          "Add WhatsApp/Mobile Number",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPhoneScreen(
                                  initialPhone: phone,
                                  isPhone: true,
                                ),
                              ),
                            );
                          },
                        )
                      : _buildEditableRow(
                          context,
                          "WhatsApp/Mobile Number",
                          phone,
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPhoneScreen(
                                  initialPhone: phone,
                                  isPhone: true,
                                ),
                              ),
                            );
                          },
                        ),
                  (dobRaw == 'N/A' || dobRaw.isEmpty || dobRaw == 'null')
                      ? _buildWarningRow(
                          context,
                          "Date of Birth",
                          "Add your DOB",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDateOfBirthScreen(
                                  initialDate: dobRaw,
                                  details: provider.details,
                                ),
                              ),
                            );
                          },
                        )
                      : _buildEditableRow(
                          context,
                          "Date of Birth",
                          DateFormat(
                            'd MMMM yyyy',
                          ).format(DateTime.parse(dobRaw)),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditDateOfBirthScreen(
                                  initialDate: dobRaw,
                                  details: provider.details,
                                ),
                              ),
                            );
                          },
                        ),
                  (countryRaw == 'N/A' ||
                          countryRaw.isEmpty ||
                          countryRaw == 'null')
                      ? _buildWarningRow(
                          context,
                          "Country of Residence",
                          "Add your country of residence",
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditCountryScreen(
                                  initialCountryCode: countryRaw,
                                  details: provider.details,
                                ),
                              ),
                            );
                          },
                        )
                      : _buildCountryRow(context, countryRaw, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditCountryScreen(
                                initialCountryCode: countryRaw,
                                details: provider.details,
                              ),
                            ),
                          );
                        }),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Delete account
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Delete Account',
                  style: GoogleFonts.nunitoSans(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),

                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.grayColor,
                ),
                onTap: () {
                  showDeleteAccountBottomSheet(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableRow(
    BuildContext context,
    String label,
    String value,
    VoidCallback? onPressed, {
    bool isEditable = true,
  }) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: GoogleFonts.nunitoSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.grayColor,
        ),
      ),
      subtitle: Text(
        value,
        style: GoogleFonts.nunitoSans(
          fontWeight: FontWeight.w700,
          fontSize: 15.sp,
        ),
      ),
      trailing: isEditable
          ? Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.grayColor,
            )
          : null,
      onTap: isEditable ? onPressed : null,
    );
  }

  Widget _buildCountryRow(
    BuildContext context,
    String countryName,
    VoidCallback onPressed,
  ) {
    String flagEmoji = _getFlagEmoji(countryName);

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(
        "Country of Residence",
        style: GoogleFonts.nunitoSans(
          fontSize: 13.sp,
          fontWeight: FontWeight.w400,
          color: AppColors.grayColor,
        ),
      ),
      subtitle: Row(
        children: [
          Text(flagEmoji, style: TextStyle(fontSize: 18.sp)),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              countryName,
              style: GoogleFonts.nunitoSans(
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: AppColors.grayColor,
      ),
      onTap: onPressed,
    );
  }

  Widget _buildWarningRow(
    BuildContext context,
    String label,
    String hint,
    VoidCallback? onPressed,
  ) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: GoogleFonts.nunitoSans(color: Colors.grey)),
      subtitle: Row(
        children: [
          Image.asset(
            'assets/settings/notice.png',
            height: 16.sp,
            width: 16.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            hint,
            style: GoogleFonts.nunitoSans(
              color: const Color(0xffb7b7b7),
              fontStyle: FontStyle.italic,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16.sp,
        color: AppColors.grayColor,
      ),
      onTap: () {
        onPressed?.call();
      },
    );
  }

  void showDeleteAccountBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          margin: EdgeInsets.only(top: 50.h),
          padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 20.w),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                margin: EdgeInsets.only(bottom: 16.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Are you sure you want to\ndelete your account?',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunitoSans(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  "No, I'm loving myGAPhub",
                  style: GoogleFonts.nunitoSans(
                    color: Colors.white,
                    fontSize: 16.sp,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AccountDeletionScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderColor),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32),
                  ),
                ),
                child: Text(
                  "Yes, I want to delete my account",
                  style: GoogleFonts.nunitoSans(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 64.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      // Local asset image
      return Image.asset(imageUrl, fit: BoxFit.contain);
    } else {
      // Network image
      final refreshedImageUrl = imageUrl.contains('?')
          ? '$imageUrl&v=$_imageRefreshVersion'
          : '$imageUrl?v=$_imageRefreshVersion';

      return CachedNetworkImage(
        key: ValueKey(refreshedImageUrl),
        imageUrl: refreshedImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[200],
          child: Icon(Icons.person, size: 50.sp, color: Colors.grey[500]),
        ),
      );
    }
  }
}
