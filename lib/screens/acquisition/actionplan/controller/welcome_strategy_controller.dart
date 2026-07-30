import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/welcome_strategy_state.dart';

class WelcomeStrategyController extends Notifier<WelcomeStrategyState> {
  @override
  WelcomeStrategyState build() => const WelcomeStrategyState();

  /// Called when the user taps "Continue".
  /// Add analytics / onboarding-step persistence here.
  Future<void> onContinuePressed() async {
    state = state.copyWith(isNavigating: true);
    // e.g. await ref.read(onboardingRepositoryProvider).markStepComplete('strategy_welcome');
    await Future<void>.delayed(const Duration(milliseconds: 200));
    state = state.copyWith(isNavigating: false);
  }
}

final welcomeStrategyControllerProvider =
    NotifierProvider<WelcomeStrategyController, WelcomeStrategyState>(
  WelcomeStrategyController.new,
);