import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void saveLastRoute(Route lastRoute) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
  }

  // @override
  // void didPop(Route route, Route? previousRoute) {
  //   saveLastRoute(previousRoute);
  //   super.didPop(route, previousRoute);
  // }

  // @override
  // void didPush(Route route, Route previousRoute) {
  //   saveLastRoute(route);
  //   super.didPush(route, previousRoute);
  // }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('Pushed route: ${route.settings.name}');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    debugPrint('Popped route: ${route.settings.name}');
  }
}
