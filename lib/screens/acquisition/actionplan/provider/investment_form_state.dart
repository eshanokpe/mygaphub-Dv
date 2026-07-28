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
  final int
  step2TotalItems; // ✅ total fields in the currently selected category's checklist

  // Step 3 fields
  final List<Map<String, String>> step3Items;

  // Step 4 fields
  final List<Map<String, String>> step4Items;
  final bool
  step4ShowInvestigateForm; // ✅ NEW: toggles Step 4's intro vs Investigate UI

  // Step 5 fields
  final List<Map<String, String>> step5Items;
  final String allocationPercentage; // ✅ NEW: % of total asset to invest
  final bool
  step5ShowSecondScreen; // ✅ NEW: toggles Step 5's percentage screen vs Allocation screen
  final int?
  monthlyAllocationPercent; // ✅ NEW: selected chip (10/25/50/100) for monthly allocation
  final int?
  lumpsumAllocationPercent; // ✅ NEW: selected chip (10/25/50/100) for lumpsum allocation

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
    this.step3Items = const [],
    this.step4Items = const [],
    this.step4ShowInvestigateForm = false, // ✅ NEW
    this.step5Items = const [],
    this.allocationPercentage = '', // ✅ NEW
    this.step5ShowSecondScreen = false, // ✅ NEW
    this.monthlyAllocationPercent, // ✅ NEW
    this.lumpsumAllocationPercent, // ✅ NEW
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
    List<Map<String, String>>? step3Items,
    List<Map<String, String>>? step4Items,
    bool? step4ShowInvestigateForm, // ✅ NEW
    List<Map<String, String>>? step5Items,
    String? allocationPercentage, // ✅ NEW
    bool? step5ShowSecondScreen, // ✅ NEW
    int? monthlyAllocationPercent, // ✅ NEW
    bool clearMonthlyAllocationPercent = false, // ✅ NEW
    int? lumpsumAllocationPercent, // ✅ NEW
    bool clearLumpsumAllocationPercent = false, // ✅ NEW
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
      step3Items: step3Items ?? this.step3Items,
      step4Items: step4Items ?? this.step4Items,
      step4ShowInvestigateForm:
          step4ShowInvestigateForm ?? this.step4ShowInvestigateForm, // ✅ NEW
      step5Items: step5Items ?? this.step5Items,
      allocationPercentage:
          allocationPercentage ?? this.allocationPercentage, // ✅ NEW
      step5ShowSecondScreen:
          step5ShowSecondScreen ?? this.step5ShowSecondScreen, // ✅ NEW
      monthlyAllocationPercent:
          clearMonthlyAllocationPercent // ✅ NEW
          ? null
          : (monthlyAllocationPercent ?? this.monthlyAllocationPercent),
      lumpsumAllocationPercent:
          clearLumpsumAllocationPercent // ✅ NEW
          ? null
          : (lumpsumAllocationPercent ?? this.lumpsumAllocationPercent),
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
