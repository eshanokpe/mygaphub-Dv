class EssentialVideoState {
  final bool isPlaying;
  final bool isLoading;
  final bool isNavigating;
  final bool skipEnabled;

  const EssentialVideoState({
    this.isPlaying = false,
    this.isLoading = false,
    this.isNavigating = false,
    this.skipEnabled = false,
  });

  EssentialVideoState copyWith({
    bool? isPlaying,
    bool? isLoading,
    bool? isNavigating,
    bool? skipEnabled,
  }) {
    return EssentialVideoState(
      isPlaying: isPlaying ?? this.isPlaying,
      isLoading: isLoading ?? this.isLoading,
      isNavigating: isNavigating ?? this.isNavigating,
      skipEnabled: skipEnabled ?? this.skipEnabled,
    );
  }
}
