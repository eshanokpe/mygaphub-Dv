import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/strategy_intro_state.dart';


class StrategyIntroController extends Notifier<StrategyIntroState> {
  @override
  StrategyIntroState build() => const StrategyIntroState();

  /// Called when "Get Started" is tapped
  Future<void> onGetStartedPressed() async {
    state = state.copyWith(isNavigating: true);

    // Add analytics, logging or any logic here
    await Future.delayed(const Duration(milliseconds: 200));

    state = state.copyWith(isNavigating: false);
  }
}

final strategyIntroControllerProvider = NotifierProvider<StrategyIntroController, StrategyIntroState>(
  StrategyIntroController.new,
);