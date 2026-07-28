import 'package:GapHub/models/calculatormodel.dart';
import 'package:GapHub/screens/registration/financial_snapshot/financial_independent_snapshot.dart';
import 'package:GapHub/utils/colors.dart';
import 'package:GapHub/widgets/navigateWithSlideTransition.dart';
import 'package:flutter/material.dart';

class CalculatingLoading extends StatefulWidget {
  final bool login;
  final Calculatormodel parameters;
  const CalculatingLoading(this.parameters, this.login, {super.key});

  @override
  State<CalculatingLoading> createState() => _CalculatingLoadingState();
}

class _CalculatingLoadingState extends State<CalculatingLoading> {
  @override
  void initState() {
    super.initState();
    _navigateToNextPage();
    print("parameterCurrency:${widget.parameters.currency}");
    print("savings:${widget.parameters.periodic}");
    print("education:${widget.parameters.education}");
    print("mortgage:${widget.parameters.mortgage}");
    print("mobility:${widget.parameters.mobility}");
  }

  void _navigateToNextPage() async {
    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      navigateWithSlideTransition(
        context: context,
        destinationScreen: FinancialIndependentSnapshot(false),
        transitionDuration: const Duration(milliseconds: 200),
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
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Calculating',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.blackColor,
                      fontStyle: FontStyle.italic,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  Text(
                    '...',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                      color: AppColors.primaryColor,
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
