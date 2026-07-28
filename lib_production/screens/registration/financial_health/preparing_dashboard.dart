import 'dart:async';

import 'package:GapHub/provider/AuthProvider.dart';
import 'package:GapHub/screens/others/dashboards/dashboard.dart';
import 'package:GapHub/screens/registration/calculation/multi_form.dart';
import 'package:GapHub/screens/registration/calculation/precalc.dart';
import 'package:GapHub/screens/registration/financial_health/prequestions.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PreparingDasbaordUI extends StatefulWidget {
  const PreparingDasbaordUI({key});

  @override
  State<PreparingDasbaordUI> createState() => _PreparingDasbaordUIState();
} 

class _PreparingDasbaordUIState extends State<PreparingDasbaordUI> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prepareDashboardData();
    });
  }

  Future<void> _prepareDashboardData() async {
    if (_isNavigating || !mounted) return;

    _isNavigating = true;
    final authProvider = context.read<AuthProvider>();
    final minimumLoaderTime = Future.delayed(const Duration(seconds: 2));

    try {
      final results = await Future.wait([
        authProvider.signInDetails(context),
        minimumLoaderTime,
      ]);
      print('Dashboard preparation results: ${results[0]}');

      if (!mounted) return;

      final data = results.first as Map<String, dynamic>;
      print(" Dashboard preparation data: $data");
      if (data['success'] == true) {
        _navigateFromResult(data);
        return;
      }

      final errorMessage =
          data['message'] ?? data['error'] ?? 'Unable to prepare dashboard.';
      _showError(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showError('Unable to prepare dashboard. Please try again.');
    } finally {
      _isNavigating = false;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
    Navigator.pop(context);
  }

  void _navigateFromResult(Map<String, dynamic> data) {
    final route = data['route'];
    switch (route) {
      case 'prequestions':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Prequestions()),
        );
        break;
      case 'precalc':
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Precalc()),
        );
        break;
      case 'multiStepForm':
        final initialPage = data['initialPage'] ?? 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepForm(
              initialPage: initialPage,
              currentPageIndex: initialPage,
            ),
          ),
        );
        break;
      case 'dashboard':
      default:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Dashboard(index: 0)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            padding: EdgeInsets.zero,
            icon: const Icon(
              Icons.arrow_back_ios,
              color: AppColors.arrowbackColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: InkWell(
                child: Image.asset('assets/logo.png', width: 30),
                onTap: () {
                  // Handle help tap
                },
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/loader.gif', width: 130),
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Preparing your dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.blackColor,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  Text(
                    'One moment now...',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 16,
                      color: AppColors.grayColor,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
