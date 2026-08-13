import 'package:flutter/material.dart';

@immutable
class InvestmentFormState {
  // Step 1 fields
  final String investmentName;
  final String investmentReason;
  final String category;
  final String? nameError;
  final String? reasonError;
  final String? selectedCategory;

  // Step 2 fields
  final List<Map<String, String>> step2Items;
  final int step2TotalItems;
  final bool step2CategoryJustSelected;

  // Step 3 fields
  final List<Map<String, String>> step3Items;
  final String assetGrowthFunds;
  final String personalFund;
  final String emergencyFund;
  final String savingsChoice;
  final String newMonthlySavings;
  final String obtainPlan;

  // Step 4 fields
  final List<Map<String, String>> step4Items;
  final bool step4ShowInvestigateForm;
  final String investigation; // ✅ Added for API raw text

  // Step 5 fields
  final List<Map<String, String>> step5Items;
  final String allocationPercentage;
  final bool step5ShowSecondScreen;
  final bool step5ShowSummaryScreen;
  final int? monthlyAllocationPercent;
  final int? lumpsumAllocationPercent;
  final String monthlyPercent; // ✅ Added for API raw string
  final String lumpsumPercent; // ✅ Added for API raw string

  // Step management
  final int currentStep;
  final bool isNavigating;
  final bool isLoading;
  final String? strategyId;

  // Progress
  final double step1Progress;
  final double step2Progress;
  final double step3Progress;
  final double step4Progress;
  final double step5Progress;

  // Feedback messages
  final String? successMessage;
  final String? errorMessage;

  const InvestmentFormState({
    this.investmentName = '',
    this.investmentReason = '',
    this.category = 'retirement',
    this.nameError,
    this.reasonError,
    this.step2Items = const [],
    this.step2TotalItems = 0,
    this.step2CategoryJustSelected = false,
    this.step3Items = const [],
    this.assetGrowthFunds = '',
    this.personalFund = '',
    this.emergencyFund = '',
    this.savingsChoice = '',
    this.newMonthlySavings = '',
    this.obtainPlan = '',
    this.step4Items = const [],
    this.step4ShowInvestigateForm = false,
    this.investigation = '',
    this.step5Items = const [],
    this.allocationPercentage = '',
    this.step5ShowSecondScreen = false,
    this.step5ShowSummaryScreen = false,
    this.monthlyAllocationPercent,
    this.lumpsumAllocationPercent,
    this.monthlyPercent = '',
    this.lumpsumPercent = '',
    this.currentStep = 0,
    this.isNavigating = false,
    this.isLoading = false,
    this.strategyId,
    this.step1Progress = 0.1,
    this.step2Progress = 0.0,
    this.step3Progress = 0.0,
    this.step4Progress = 0.0,
    this.step5Progress = 0.0,
    this.successMessage,
    this.errorMessage,
    this.selectedCategory,
  });

  InvestmentFormState copyWith({
    String? investmentName,
    String? investmentReason,
    String? category,
    String? nameError,
    String? reasonError,
    List<Map<String, String>>? step2Items,
    int? step2TotalItems,
    bool? step2CategoryJustSelected,
    List<Map<String, String>>? step3Items,
    String? assetGrowthFunds,
    String? personalFund,
    String? emergencyFund,
    String? savingsChoice,
    String? newMonthlySavings,
    String? obtainPlan,
    List<Map<String, String>>? step4Items,
    bool? step4ShowInvestigateForm,
    String? investigation,
    List<Map<String, String>>? step5Items,
    String? allocationPercentage,
    bool? step5ShowSecondScreen,
    bool? step5ShowSummaryScreen,
    int? monthlyAllocationPercent,
    bool clearMonthlyAllocationPercent = false,
    int? lumpsumAllocationPercent,
    bool clearLumpsumAllocationPercent = false,
    String? monthlyPercent,
    String? lumpsumPercent,
    int? currentStep,
    bool? isNavigating,
    bool? isLoading,
    String? strategyId,
    double? step1Progress,
    double? step2Progress,
    double? step3Progress,
    double? step4Progress,
    double? step5Progress,
    String? successMessage,
    String? errorMessage,
    String? selectedCategory,
  }) {
    return InvestmentFormState(
      investmentName: investmentName ?? this.investmentName,
      investmentReason: investmentReason ?? this.investmentReason,
      category: category ?? this.category,
      nameError: nameError,
      reasonError: reasonError,
      step2Items: step2Items ?? this.step2Items,
      step2TotalItems: step2TotalItems ?? this.step2TotalItems,
      step2CategoryJustSelected:
          step2CategoryJustSelected ?? this.step2CategoryJustSelected,
      step3Items: step3Items ?? this.step3Items,
      assetGrowthFunds: assetGrowthFunds ?? this.assetGrowthFunds,
      personalFund: personalFund ?? this.personalFund,
      emergencyFund: emergencyFund ?? this.emergencyFund,
      savingsChoice: savingsChoice ?? this.savingsChoice,
      newMonthlySavings: newMonthlySavings ?? this.newMonthlySavings,
      obtainPlan: obtainPlan ?? this.obtainPlan,
      step4Items: step4Items ?? this.step4Items,
      step4ShowInvestigateForm:
          step4ShowInvestigateForm ?? this.step4ShowInvestigateForm,
      investigation: investigation ?? this.investigation,
      step5Items: step5Items ?? this.step5Items,
      allocationPercentage: allocationPercentage ?? this.allocationPercentage,
      step5ShowSecondScreen:
          step5ShowSecondScreen ?? this.step5ShowSecondScreen,
      step5ShowSummaryScreen:
          step5ShowSummaryScreen ?? this.step5ShowSummaryScreen,
      monthlyAllocationPercent: clearMonthlyAllocationPercent
          ? null
          : (monthlyAllocationPercent ?? this.monthlyAllocationPercent),
      lumpsumAllocationPercent: clearLumpsumAllocationPercent
          ? null
          : (lumpsumAllocationPercent ?? this.lumpsumAllocationPercent),
      monthlyPercent: monthlyPercent ?? this.monthlyPercent,
      lumpsumPercent: lumpsumPercent ?? this.lumpsumPercent,
      currentStep: currentStep ?? this.currentStep,
      isNavigating: isNavigating ?? this.isNavigating,
      isLoading: isLoading ?? this.isLoading,
      strategyId: strategyId ?? this.strategyId,
      step1Progress: step1Progress ?? this.step1Progress,
      step2Progress: step2Progress ?? this.step2Progress,
      step3Progress: step3Progress ?? this.step3Progress,
      step4Progress: step4Progress ?? this.step4Progress,
      step5Progress: step5Progress ?? this.step5Progress,
      successMessage: successMessage,
      errorMessage: errorMessage,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}
