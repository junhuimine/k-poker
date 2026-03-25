/// 🎴 카드 뒷면 스킨 관리
library;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 사용 가능한 스킨 목록
enum CardSkin {
  original('Original', 'assets/images/cards/card_back.png', '🎴'),
  classic('Classic', 'assets/images/cards/card_back_classic.png', '🌟'),
  midnight('Midnight', 'assets/images/cards/card_back_midnight.png', '🌙'),
  jade('Jade', 'assets/images/cards/card_back_jade.png', '💎'),
  sakura('Sakura', 'assets/images/cards/card_back_sakura.png', '🌸');

  final String displayName;
  final String assetPath;
  final String emoji;
  const CardSkin(this.displayName, this.assetPath, this.emoji);
}

/// 현재 선택된 스킨 상태
class CardSkinNotifier extends StateNotifier<CardSkin> {
  CardSkinNotifier() : super(CardSkin.original) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final skinName = prefs.getString('card_skin') ?? 'classic';
    try {
      state = CardSkin.values.firstWhere((s) => s.name == skinName);
    } catch (_) {
      state = CardSkin.classic;
    }
  }

  Future<void> setSkin(CardSkin skin) async {
    state = skin;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('card_skin', skin.name);
  }
}

final cardSkinProvider = StateNotifierProvider<CardSkinNotifier, CardSkin>(
  (ref) => CardSkinNotifier(),
);
