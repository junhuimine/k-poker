/// 🎴 K-Poker — 설정 화면 (볼륨/언어/카드 스킨)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/audio_manager.dart';
import '../state/card_skin_provider.dart'; // CardSkin + FrontSkin
import '../i18n/locale_provider.dart';
import '../i18n/app_strings.dart';

class SettingsOverlay extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const SettingsOverlay({super.key, required this.onClose});

  @override
  ConsumerState<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends ConsumerState<SettingsOverlay> {
  final _audio = AudioManager();

  // 로컬 상태 — AudioManager의 값을 복사해서 즉시 반영
  late double _bgmVol;
  late double _sfxVol;
  late bool _bgmMuted;
  late bool _sfxMuted;

  @override
  void initState() {
    super.initState();
    _bgmVol = _audio.bgmVolume;
    _sfxVol = _audio.sfxVolume;
    _bgmMuted = _audio.bgmMuted;
    _sfxMuted = _audio.sfxMuted;
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeStateProvider);

    final strings = ref.watch(appStringsProvider);

    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        color: Colors.black54,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // 내부 클릭 무시
            child: Container(
              width: 360,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF161B22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF30363D)),
                boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.2), blurRadius: 30)],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 헤더
                    Row(
                      children: [
                        const Text('⚙️', style: TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(strings.ui('settings'), style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close, color: Colors.white54, size: 20)),
                      ],
                    ),
                    const Divider(color: Color(0xFF30363D)),
                    const SizedBox(height: 8),

                    // 🔊 BGM 볼륨
                    _buildVolumeRow('🎵 ${strings.ui('bgm')}', _bgmVol, _bgmMuted, (v) {
                      setState(() => _bgmVol = v);
                      _audio.setBgmVolume(v);
                    }, () {
                      setState(() => _bgmMuted = !_bgmMuted);
                      _audio.toggleBgmMute();
                    }, strings),
                    const SizedBox(height: 12),

                    // 🔊 SFX 볼륨
                    _buildVolumeRow('🔊 ${strings.ui('sfx')}', _sfxVol, _sfxMuted, (v) {
                      setState(() => _sfxVol = v);
                      _audio.setSfxVolume(v);
                    }, () {
                      setState(() => _sfxMuted = !_sfxMuted);
                      _audio.toggleSfxMute();
                    }, strings),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF30363D)),
                    const SizedBox(height: 12),

                    // 🌐 언어 선택
                    Text('🌐 ${strings.ui('language')}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: AppLanguage.values.map((l) {
                        final isSelected = l == lang;
                        return GestureDetector(
                          onTap: () => ref.read(localeStateProvider.notifier).setLanguage(l),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.blue.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: isSelected ? Colors.blue : Colors.white24),
                            ),
                            child: Text(
                              _langLabel(l),
                              style: TextStyle(
                                color: isSelected ? Colors.blueAccent : Colors.white70,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF30363D)),
                    const SizedBox(height: 12),

                    // 🎴 카드 앞면 스킨
                    Text('🎨 ${strings.ui('cardSkinFront')}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: FrontSkin.values.map((skin) {
                        final isActive = skin == ref.watch(frontSkinProvider);
                        return GestureDetector(
                          onTap: () => ref.read(frontSkinProvider.notifier).setSkin(skin),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isActive ? Colors.deepPurple.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isActive ? Colors.deepPurpleAccent : Colors.white24,
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: isActive ? [BoxShadow(color: Colors.deepPurple.withValues(alpha: 0.3), blurRadius: 8)] : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(skin.emoji, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 6),
                                Text(skin.displayName, style: TextStyle(
                                  color: isActive ? Colors.deepPurpleAccent : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Color(0xFF30363D)),
                    const SizedBox(height: 12),

                    // 🃏 카드 뒷면 스킨
                    Text('🃏 ${strings.ui('cardSkinBack')}', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CardSkin.values.map((skin) {
                        final isActive = skin == ref.watch(cardSkinProvider);
                        return GestureDetector(
                          onTap: () => ref.read(cardSkinProvider.notifier).setSkin(skin),
                          child: Container(
                            width: 64, height: 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isActive ? Colors.amber : Colors.white24,
                                width: isActive ? 2 : 1,
                              ),
                              boxShadow: isActive ? [BoxShadow(color: Colors.amber.withValues(alpha: 0.3), blurRadius: 8)] : null,
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset(skin.assetPath, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: const Color(0xFF2A1A3A),
                                      child: Center(child: Text(skin.emoji, style: const TextStyle(fontSize: 20))),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0, left: 0, right: 0,
                                    child: Container(
                                      color: Colors.black54,
                                      padding: const EdgeInsets.symmetric(vertical: 2),
                                      child: Text(skin.displayName,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isActive ? Colors.amber : Colors.white70,
                                          fontSize: 9, fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVolumeRow(String label, double volume, bool muted, ValueChanged<double> onChanged, VoidCallback onMute, AppStrings strings) {
    final displayPercent = (volume * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: onMute,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: muted ? Colors.red.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(muted ? '🔇' : (volume > 0.6 ? '🔊' : volume > 0.3 ? '🔉' : '🔈'),
                  style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: muted ? Colors.red.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                muted ? strings.ui('volumeOff') : '$displayPercent%',
                style: TextStyle(
                  color: muted ? Colors.redAccent : Colors.blueAccent,
                  fontSize: 13, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 32,
          child: SliderTheme(
            data: SliderThemeData(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 6,
              activeTrackColor: muted ? Colors.grey.shade600 : Colors.blueAccent,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
              thumbColor: muted ? Colors.grey : Colors.white,
              overlayColor: Colors.blueAccent.withValues(alpha: 0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: volume,
              onChanged: (v) {
                // 뮤트 상태에서 슬라이더 움직이면 자동으로 뮤트 해제
                if (muted) onMute();
                onChanged(v);
              },
              // SFX일 때 슬라이더 놓으면 테스트 사운드 재생 (기본 라벨과 한국어 포함 대응)
              onChangeEnd: (label.contains('효과음') || label.contains('SFX') || label.contains('SE') || label.contains('音效')) ? (_) => _audio.cardPlay() : null,
            ),
          ),
        ),
      ],
    );
  }

  // ignore: unused_element
  Widget _skinChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.amber.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? Colors.amber : Colors.white24),
      ),
      child: Text(label, style: TextStyle(
        color: isActive ? Colors.amber : Colors.white54, fontSize: 12,
        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
      )),
    );
  }

  String _langLabel(AppLanguage lang) {
    switch (lang) {
      case AppLanguage.ko: return '🇰🇷 한국어';
      case AppLanguage.en: return '🇺🇸 English';
      case AppLanguage.ja: return '🇯🇵 日本語';
      case AppLanguage.zhCn: return '🇨🇳 简体中文';
      case AppLanguage.zhTw: return '🇹🇼 繁體中文';
      case AppLanguage.es: return '🇪🇸 Español';
      case AppLanguage.fr: return '🇫🇷 Français';
      case AppLanguage.de: return '🇩🇪 Deutsch';
      case AppLanguage.pt: return '🇧🇷 Português';
      case AppLanguage.th: return '🇹🇭 ภาษาไทย';
    }
  }
}
