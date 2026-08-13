/// State for Strategy Intro screen
class StrategyIntroState {
  final bool isNavigating;

  const StrategyIntroState({
    this.isNavigating = false,
  });

  StrategyIntroState copyWith({
    bool? isNavigating,
  }) {
    return StrategyIntroState(
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}