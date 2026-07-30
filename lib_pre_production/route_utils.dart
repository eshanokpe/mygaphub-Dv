import 'package:flutter/material.dart';
import 'package:GapHub/screens/360/accounts/retirement/retirement.dart';
import 'package:GapHub/screens/360/threesixty.dart';
import 'package:GapHub/screens/acquisition/actionplan/actionplan.dart';
import 'package:GapHub/screens/acquisition/favourites.dart';
import 'package:GapHub/screens/acquisition/opportunities.dart';
import 'package:GapHub/screens/authentication/login/forgot_password/forgotpword.dart';
import 'package:GapHub/screens/authentication/login/login.dart';
import 'package:GapHub/screens/more/support/Support.dart';
import 'package:GapHub/screens/more/comingsoon.dart';
import 'package:GapHub/screens/more/feedbacks.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/screens/registration/verification.dart';
import 'package:GapHub/screens/reminder/reminder.dart';
import 'screens/360/accounts/assetsAcc/assets.dart';
import 'screens/360/accounts/assetsAcc/equity/homequity.dart';
import 'screens/360/accounts/expenditure/expenditure.dart';
import 'screens/360/accounts/income/income.dart';
import 'screens/360/accounts/investment/investdash.dart';
import 'screens/360/accounts/liabilities/liabilities.dart';
import 'screens/360/accounts/protection/protection.dart';
import 'screens/360/accounts/protection/protectiondetails.dart';
import 'screens/360/iLAB/ilab.dart';
import 'screens/360/iLAB/settarget.dart';
import 'widgets/bottomnav.dart';

final appRoutes = {
  "Dashboard": (BuildContext ctx) => const Dashboard(index: 0),
  'NewRetirementAccnt': (BuildContext ctx) => Retirement(),
  "Retirement": (BuildContext ctx) => Retirement(),
  'ForgotPassword': (BuildContext ctx) => const Forgotpword(),
  'Verification': (BuildContext ctx) => Verification(),
  'Reminder': (BuildContext ctx) => const ReminderScreen(),
  "Protection": (BuildContext ctx) => Protection(),
  'Threesixty': (BuildContext ctx) => const Threesixty(),
  'Income': (BuildContext ctx) => const Income(),
  'Assets': (BuildContext ctx) => Assets(),
  'Liabilities': (BuildContext ctx) => Liabilities(),
  'Investdash': (BuildContext ctx) => Investdash(),
  'Protectiondetails': (BuildContext ctx) => Protectiondetails(),
  'Expenditure': (BuildContext ctx) => Expenditure(),
  'Ilab': (BuildContext ctx) => Ilab(),
  "Settarget": (BuildContext ctx) => Settarget(),
  'Actionplan': (BuildContext ctx) => Actionplan(),
  'FavouritesPage': (BuildContext ctx) => const FavouritesPage(),
  'Feedbacks': (BuildContext ctx) => Feedbacks(),
  'Homequity': (BuildContext ctx) => Homequity(),
  'Support': (BuildContext ctx) => Support(),
  'Comingsoon': (BuildContext ctx) => Comingsoon(),
  "Opportunities": (BuildContext ctx) => const Opportunities(value: 0),
  "Opportunities22": (BuildContext ctx) => const Opportunities(value: 2),
  "Opportunities33": (BuildContext ctx) => const Opportunities(value: 3),
  "Opportunities44": (BuildContext ctx) => const Opportunities(value: 4),
  "login": (BuildContext ctx) => Login(),
  "BottomNav4": (BuildContext ctx) => const BottomNav(4),
};
