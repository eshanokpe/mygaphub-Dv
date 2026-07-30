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
//
// NOTE: Uses ref.read (not ref.watch) for providersLegacyProvider.
// PensionFormController only needs the `Providers` instance once, at
// construction time, to call methods on it (setretiredata/setpensions).
// If we `watch` it here, then every time PensionFormController itself
// calls providers.notifyListeners() (e.g. inside _refreshRetirementData
// during submit()), Riverpod treats that as a reason to rebuild THIS
// provider — which disposes the in-flight PensionFormController and
// creates a new one. That's what was causing `mounted` to flip to
// false right after the successful API call, right before the
// SuccessModal could show.
final addPensionFormProvider =
    StateNotifierProvider<PensionFormController, PensionFormState>((ref) {
      final providers = ref.read(providersLegacyProvider);
      return PensionFormController(providers, null);
    });

// Edit Screen Provider (loads existing data immediately)
//
// Same fix applied here: ref.read instead of ref.watch, for the same
// reason as addPensionFormProvider above.
final editPensionFormProviderFamily =
    StateNotifierProvider.family<
      PensionFormController,
      PensionFormState,
      Map<String, dynamic>?
    >((ref, existingData) {
      final providers = ref.read(providersLegacyProvider);
      return PensionFormController(providers, existingData);
    });

final pensionControllerProvider =
    StateNotifierProvider<RetiredashController, RetiredashState>(
      (ref) => RetiredashController(),
    );
