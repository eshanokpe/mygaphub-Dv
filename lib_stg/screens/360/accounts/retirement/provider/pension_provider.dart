import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:GapHub/provider/providers.dart';
import '../controller/pension_form_controller.dart';

// ------------------------------
// Pension Form State
// ------------------------------
class PensionFormState {
  final String planType;
  final String planName;
  final String providerName;
  final String currentBalance;
  final String projectedYearlyIncome;
  final String monthlyContribution;
  final String retirementAge;
  final bool isSubmitting;
  final bool success;
  final String? errorMessage;

  const PensionFormState({
    this.planType = 'pension',
    this.planName = '',
    this.providerName = '',
    this.currentBalance = '',
    this.projectedYearlyIncome = '',
    this.monthlyContribution = '',
    this.retirementAge = '0',
    this.isSubmitting = false,
    this.success = false,
    this.errorMessage,
  });

  PensionFormState copyWith({
    String? planType,
    String? planName,
    String? providerName,
    String? currentBalance,
    String? projectedYearlyIncome,
    String? monthlyContribution,
    String? retirementAge,
    bool? isSubmitting,
    bool? success,
    String? errorMessage,
  }) {
    return PensionFormState(
      planType: planType ?? this.planType,
      planName: planName ?? this.planName,
      providerName: providerName ?? this.providerName,
      currentBalance: currentBalance ?? this.currentBalance,
      projectedYearlyIncome:
          projectedYearlyIncome ?? this.projectedYearlyIncome,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      retirementAge: retirementAge ?? this.retirementAge,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      success: success ?? this.success,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// ------------------------------
// Retirement Dashboard State
// ------------------------------
class RetiredashState {
  final int selectedTabIndex;

  const RetiredashState({this.selectedTabIndex = 0});

  RetiredashState copyWith({int? selectedTabIndex}) {
    return RetiredashState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}

// ------------------------------
// Providers
// ------------------------------
final providersLegacyProvider = ChangeNotifierProvider<Providers>(
  (ref) => Providers(),
);

// Add Screen Provider
final addPensionFormProvider =
    StateNotifierProvider<PensionFormController, PensionFormState>((ref) {
      final providers = ref.watch(providersLegacyProvider);
      return PensionFormController(providers, null);
    });

// Edit Screen Provider (loads existing data immediately)
final editPensionFormProviderFamily =
    StateNotifierProvider.family<
      PensionFormController,
      PensionFormState,
      Map<String, dynamic>?
    >((ref, existingData) {
      final providers = ref.watch(providersLegacyProvider);
      return PensionFormController(providers, existingData);
    });

final pensionControllerProvider =
    StateNotifierProvider<RetiredashController, RetiredashState>(
      (ref) => RetiredashController(),
    );
