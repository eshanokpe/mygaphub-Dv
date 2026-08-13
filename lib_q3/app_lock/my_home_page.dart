// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_lock/flutter_app_lock.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({
    super.key,
    required this.title,
    required this.data,
  });

  final String title;
  final String data;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
 
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 4), () {
      // ignore: use_build_context_synchronously
      AppLock.of(context)!.disable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                key: const Key('Testing'),
                child: const Text('Test'),
                onPressed: () {
                  //Navigator.of(context).pushNamed("TestScreen");
                }),
            ElevatedButton(
              key: const Key('AwaitShowButton'),
              child: const Text('Manually show lock screen (awaiting)'),
              onPressed: () async {
                await AppLock.of(context)!.showLockScreen();

                if (kDebugMode) {
                  print('Did unlock!');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
