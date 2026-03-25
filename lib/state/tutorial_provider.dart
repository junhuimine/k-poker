import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialState {
  final bool hasSeenFirstYaku;
  final bool hasSeenFirstGo;
  final bool suppressAllTutorials;
  final bool isLoading;

  const TutorialState({
    required this.hasSeenFirstYaku,
    required this.hasSeenFirstGo,
    required this.suppressAllTutorials,
    required this.isLoading,
  });

  TutorialState copyWith({
    bool? hasSeenFirstYaku,
    bool? hasSeenFirstGo,
    bool? suppressAllTutorials,
    bool? isLoading,
  }) {
    return TutorialState(
      hasSeenFirstYaku: hasSeenFirstYaku ?? this.hasSeenFirstYaku,
      hasSeenFirstGo: hasSeenFirstGo ?? this.hasSeenFirstGo,
      suppressAllTutorials: suppressAllTutorials ?? this.suppressAllTutorials,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class TutorialNotifier extends StateNotifier<TutorialState> {
  TutorialNotifier() : super(const TutorialState(
    hasSeenFirstYaku: false,
    hasSeenFirstGo: false,
    suppressAllTutorials: false,
    isLoading: true,
  )) {
    _loadState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = state.copyWith(
      hasSeenFirstYaku: prefs.getBool('tut_first_yaku') ?? false,
      hasSeenFirstGo: prefs.getBool('tut_first_go') ?? false,
      suppressAllTutorials: prefs.getBool('tut_suppress_all') ?? false,
      isLoading: false,
    );
  }

  Future<void> markSeenFirstYaku() async {
    if (state.hasSeenFirstYaku) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tut_first_yaku', true);
    state = state.copyWith(hasSeenFirstYaku: true);
  }

  Future<void> markSeenFirstGo() async {
    if (state.hasSeenFirstGo) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tut_first_go', true);
    state = state.copyWith(hasSeenFirstGo: true);
  }

  Future<void> suppressAll() async {
    if (state.suppressAllTutorials) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tut_suppress_all', true);
    state = state.copyWith(suppressAllTutorials: true);
  }
}

final tutorialProvider = StateNotifierProvider<TutorialNotifier, TutorialState>((ref) {
  return TutorialNotifier();
});
