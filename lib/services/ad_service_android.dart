import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 실제 구현 — Android 전용.
class AdService {
  AdService._();

  // ── 광고 단위 ID ──────────────────────────────────────────
  // 출시 전 실제 AdMob 광고 단위 ID로 교체 필요.
  static const String _rewardedAdUnitId =
      'ca-app-pub-8134930906845147/1359323512'; // 실제 ID (보상형)
  static const String bannerAdUnitId =
      'ca-app-pub-8134930906845147/6752085143'; // 실제 ID (배너)

  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  static Future<void> init() async {
    await MobileAds.instance.initialize();
    await loadRewardedAd();
  }

  static Future<void> loadRewardedAd() async {
    if (_isLoading || _rewardedAd != null) return;
    _isLoading = true;

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
        },
      ),
    );
  }

  /// 보상형 광고를 표시합니다.
  /// 광고가 준비되지 않았으면 false를 반환합니다.
  static Future<bool> showRewardedAd({
    required void Function() onRewarded,
    void Function(String error)? onError,
  }) async {
    if (_rewardedAd == null) {
      onError?.call('광고를 불러오는 중입니다. 잠시 후 다시 시도해주세요.');
      loadRewardedAd(); // 백그라운드에서 미리 로드
      return false;
    }

    bool rewarded = false;
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        onError?.call(error.message);
        loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (_, __) {
        rewarded = true;
        onRewarded();
      },
    );

    return rewarded;
  }

  /// 배너 위젯 반환 — Android: 실제 AdMob 배너 StatefulWidget
  static Widget getBannerWidget({bool vertical = false}) =>
      _BannerAdWidget(adUnitId: bannerAdUnitId, vertical: vertical);

  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}

/// 배너 광고 StatefulWidget — BannerAd 생명주기 관리
class _BannerAdWidget extends StatefulWidget {
  final String adUnitId;
  final bool vertical;

  const _BannerAdWidget({required this.adUnitId, required this.vertical});

  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final size = widget.vertical ? AdSize.largeBanner : AdSize.banner;
    final ad = BannerAd(
      adUnitId: widget.adUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, _) => ad.dispose(),
      ),
    );
    await ad.load();
    if (mounted) setState(() => _bannerAd = ad);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) {
      return widget.vertical
          ? const SizedBox(height: 100)
          : const SizedBox(height: 50);
    }
    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
