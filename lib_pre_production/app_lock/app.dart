import 'package:GapHub/route_utils.dart';
import 'package:GapHub/screens/others/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class MyApp extends StatefulWidget {
  final String data;

  const MyApp({super.key, required this.data});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GAPhub',
      debugShowCheckedModeBanner: false,
      builder: EasyLoading.init(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xffED3237)),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xffffffff),
        highlightColor: const Color(0xffED3237).withOpacity(.5),
        primaryColor: const Color(0xffED3237),
        // accentColor: Color(0xff494949),
        colorScheme: Theme.of(
          context,
        ).colorScheme.copyWith(secondary: const Color(0xff494949)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(),
      routes: appRoutes,
    );
  }
}
