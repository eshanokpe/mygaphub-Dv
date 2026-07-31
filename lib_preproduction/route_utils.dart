import 'package:GapHub/screens/360/accounts/philanthropy/philanthropy.dart';
import 'package:flutter/material.dart';
import 'package:GapHub/screens/360/accounts/retirement/retirement.dart';
import 'package:GapHub/screens/360/threesixty.dart';
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
import 'screens/360/accounts/liabilities/liabilities.dart';
import 'screens/360/accounts/mortgage/mortgage.dart';
import 'screens/360/accounts/mortgage/mortgageitem.dart';
import 'screens/360/accounts/protection/addProtection/add_protection.dart';
import 'screens/360/accounts/protection/protectiondetails.dart';
import 'screens/360/accounts/retirement/retirementdetails.dart';
import 'screens/360/iLAB/ilab.dart';
import 'screens/360/iLAB/settarget.dart';
import 'screens/acquisition/actionplan/presentation/action_plan_strategy.dart';
import 'widgets/bottomnav.dart';

final appRoutes = {
  "Dashboard": (BuildContext ctx) => const Dashboard(index: 0),
  'NewRetirementAccnt': (BuildContext ctx) => const Retirement(),
  "Retirement": (BuildContext ctx) => const Retirement(),
  'ForgotPassword': (BuildContext ctx) => const Forgotpword(),
  'Verification': (BuildContext ctx) => const Verification(),
  // 'SplashScreen': (BuildContext ctx) => SplashScreen(),
  'Reminder': (BuildContext ctx) => const ReminderScreen(),

  "Protection": (BuildContext ctx) => const AddProtectionScreen(),
  'Threesixty': (BuildContext ctx) => const Threesixty(),
  'Income': (BuildContext ctx) => const Income(),
  'Assets': (BuildContext ctx) => const Assets(),
  'Liabilities': (BuildContext ctx) => const Liabilities(),
  'Protectiondetails': (BuildContext ctx) => const Protectiondetails(),
  'Expenditure': (BuildContext ctx) => const Expenditure(),
  'Ilab': (BuildContext ctx) => const Ilab(),
  "Settarget": (BuildContext ctx) => const Settarget(),

  //Acquisition
  'Actionplan': (BuildContext ctx) => const ActionPlanStrategy(),
  'FavouritesPage': (BuildContext ctx) => const FavouritesPage(),
  'Feedbacks': (BuildContext ctx) => const Feedbacks(),
  'Homequity': (BuildContext ctx) => const Homequity(),
  'Support': (BuildContext ctx) => const Support(),
  'Comingsoon': (BuildContext ctx) => const Comingsoon(),
  "Opportunities": (BuildContext ctx) => const Opportunities(value: 0),
  "Opportunities22": (BuildContext ctx) => const Opportunities(value: 2),
  "Opportunities33": (BuildContext ctx) => const Opportunities(value: 3),
  "Opportunities44": (BuildContext ctx) => const Opportunities(value: 4),
  "login": (BuildContext ctx) => const Login(), //
  //BottomNav
  "BottomNav4": (BuildContext ctx) => const BottomNav(4),
  //'Home' : (BuildContext ctx) => Home(),
  //'Account' : (BuildContext ctx) => Account(),
};
