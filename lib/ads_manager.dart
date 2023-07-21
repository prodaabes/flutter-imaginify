import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'api.dart';

class AdsManager {
  static bool testMode = false;

  static String get rewardedAdUnitId {
    if (testMode == true) {
      final adUnitId = Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
      return adUnitId;
    } else {
      final adUnitId = Platform.isAndroid
          ? 'ca-app-pub-9677843275487630/6267279151'
          : 'ca-app-pub-9677843275487630/3764582354';
      return adUnitId;
    }
  }

  static bool isRewardedAdReady = false;
  static late RewardedAd rewardedAd;

  static void loadRewardedAd() {
    RewardedAd.load(
        adUnitId: AdsManager.rewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            rewardedAd = ad;
            isRewardedAdReady = true;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              // Called when the ad showed the full screen content.
                onAdShowedFullScreenContent: (ad) {},
                // Called when an impression occurs on the ad.
                onAdImpression: (ad) {},
                // Called when the ad failed to show full screen content.
                onAdFailedToShowFullScreenContent: (ad, err) {
                  // Dispose the ad here to free resources.
                  ad.dispose();
                },
                // Called when the ad dismissed full screen content.
                onAdDismissedFullScreenContent: (ad) {
                  // Dispose the ad here to free resources.
                  ad.dispose();

                  isRewardedAdReady = false;
                  loadRewardedAd();
                },
                // Called when a click is recorded for an ad.
                onAdClicked: (ad) {});
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
  }

  static void showRewardedAd(Function(AdWithoutView ad, RewardItem reward) earnedRewardCallback) {
    rewardedAd.show(onUserEarnedReward: (ad, item) {
      earnedRewardCallback(ad, item);
    });
  }
}