import 'package:GapHub/models/propertyModel.dart';
import 'package:GapHub/provider/providers.dart';
import 'package:GapHub/screens/360/accounts/retirement/presentation/financialIndependence/widget/financial_independence_card.dart';
import 'package:GapHub/screens/others/dashboards/acquisition/acquisitioncard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart' as legacy;
import '../../provider/pension_provider.dart';
import 'widget/FinancialTimeChart.dart';
import 'widget/PortfolioIncomeCard.dart';

class FinancialIndependenceTab extends ConsumerStatefulWidget {
  const FinancialIndependenceTab({super.key});

  @override
  ConsumerState<FinancialIndependenceTab> createState() =>
      _FinancialIndependenceTabState();
}

class _FinancialIndependenceTabState
    extends ConsumerState<FinancialIndependenceTab> {
  List<PropertyModel> _properties = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ Use the standalone Add provider (no family parameter needed here)
      final controller = ref.read(addPensionFormProvider.notifier);
      final data = await controller.fetchProperties();

      if (!mounted) return;
      setState(() {
        _properties = data;
        _isLoading = false;
      });
      debugPrint('✅ UI updated with ${_properties.length} properties');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FinancialIndependenceCard(
            width: screenWidth,
            height: screenHeight * 0.38,
            yes: true,
          ),
          SizedBox(height: screenHeight * .03),
          const FinancialTimeChart(),
          SizedBox(height: screenHeight * 0.02),
          const PortfolioIncomeCard(),
          SizedBox(height: screenHeight * 0.02),
          SizedBox(
            width: double.infinity,
            height: 200.h,
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_errorMessage != null) {
      return Center(
        child: Text('Error: $_errorMessage', textAlign: TextAlign.center),
      );
    }
    if (_properties.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No Acquisition properties available right now.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return Acquisitioncard(properties: _properties);
  }
}
