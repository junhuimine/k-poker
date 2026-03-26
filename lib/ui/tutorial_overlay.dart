/// 🎴 K-Poker — 도움말 및 도감 시스템
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../i18n/app_strings.dart';
import '../i18n/locale_provider.dart';
import '../data/all_cards.dart';
import '../models/card_def.dart';

class TutorialOverlay extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  const TutorialOverlay({super.key, required this.onComplete});

  @override
  ConsumerState<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late List<CardDef> _deckCards;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _deckCards = allCards.where((c) => !c.isBonus).toList(); // 보너스 제외 48장
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);

    return GestureDetector(
      onTap: widget.onComplete,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black87,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 뒷 배경 닫힘 방지
            child: Container(
              width: 850,
              height: 550,
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF30363D), width: 2),
                boxShadow: [
                  BoxShadow(color: Colors.amber.withValues(alpha: 0.15), blurRadius: 40),
                ],
              ),
              child: Column(
                children: [
                  // 상단 탭 및 닫기 버튼
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 8, left: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: const Color(0xFFFFD700),
                            labelColor: const Color(0xFFFFD700),
                            unselectedLabelColor: Colors.white54,
                            tabs: [
                              Tab(text: strings.tabRules, icon: const Icon(Icons.menu_book)),
                              Tab(text: strings.tabDictionary, icon: const Icon(Icons.style)),
                              Tab(text: strings.tabYaku, icon: const Icon(Icons.military_tech)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white54, size: 32),
                          padding: const EdgeInsets.all(16),
                          onPressed: widget.onComplete,
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: Color(0xFF30363D), height: 1),
                  // 컨텐츠 영역
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildRulesTab(strings),
                        _buildDictionaryTab(strings),
                        _buildYakuTab(strings),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRulesTab(AppStrings strings) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        _RuleSection(title: strings.ruleIntroTitle, body: strings.ruleIntroBody, icon: Icons.sports_esports),
        const SizedBox(height: 24),
        _RuleSection(title: strings.ruleTurnTitle, body: strings.ruleTurnBody, icon: Icons.sync),
        const SizedBox(height: 24),
        _RuleSection(title: strings.ruleGoStopTitle, body: strings.ruleGoStopBody, icon: Icons.whatshot),
      ],
    );
  }

  Widget _buildDictionaryTab(AppStrings strings) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.9,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 12,
      itemBuilder: (context, i) {
        final month = i + 1;
        final monthCards = _deckCards.where((c) => c.month == month).toList();
        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Text(strings.monthFormatted(month), style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Expanded(
                child: Wrap(
                  spacing: 4, runSpacing: 4,
                  alignment: WrapAlignment.center,
                  children: monthCards.map((c) {
                    return Tooltip(
                      message: _getCardGradeName(c.grade, strings, doubleJunk: c.doubleJunk),
                      child: Container(
                        decoration: const BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.black45, blurRadius: 4, offset: Offset(1, 2))],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.asset(
                            'assets/images/cards/${c.id}.png',
                            width: 36, height: 54, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _errorCardFallback(c),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getCardGradeName(CardGrade grade, AppStrings strings, {bool doubleJunk = false}) {
    if (doubleJunk) return strings.ui('doublePi');
    switch (grade) {
      case CardGrade.bright: return strings.ui('cardGradeBright');
      case CardGrade.animal: return strings.ui('cardGradeAnimalFull');
      case CardGrade.ribbon: return strings.ui('cardGradeRibbonFull');
      case CardGrade.junk: return strings.ui('cardGradeJunk');
    }
  }

  Widget _errorCardFallback(CardDef c) {
    return Container(
      width: 36, height: 54,
      color: const Color(0xFF2A1A3A),
      alignment: Alignment.center,
      child: Text('${c.month}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
    );
  }

  Widget _buildYakuTab(AppStrings strings) {
    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        _YakuSection(title: strings.yakuGwangTitle, body: strings.yakuGwangBody, emoji: '🌟', color: Colors.yellowAccent),
        const SizedBox(height: 16),
        _YakuSection(title: strings.yakuRibbonTitle, body: strings.yakuRibbonBody, emoji: '🎀', color: Colors.blueAccent),
        const SizedBox(height: 16),
        _YakuSection(title: strings.yakuAnimalTitle, body: strings.yakuAnimalBody, emoji: '🦌', color: Colors.greenAccent),
        const SizedBox(height: 16),
        _YakuSection(title: strings.yakuPiTitle, body: strings.yakuPiBody, emoji: '🍂', color: Colors.brown.shade300),
      ],
    );
  }
}

class _RuleSection extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _RuleSection({required this.title, required this.body, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: Color(0xFFFFD700), width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD700), size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Text(body, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),
        ],
      ),
    );
  }
}

class _YakuSection extends StatelessWidget {
  final String title;
  final String body;
  final String emoji;
  final Color color;

  const _YakuSection({required this.title, required this.body, required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(body, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
