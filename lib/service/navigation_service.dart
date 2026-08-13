// navigation_service.dart
import 'package:flutter/material.dart';

class NavigationService2 {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  

  static BuildContext? get context => navigatorKey.currentContext;

  static Future<dynamic> navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!.pushNamed(routeName, arguments: arguments);
  }

  static void goBack() {
    navigatorKey.currentState!.pop(); 
  }
}