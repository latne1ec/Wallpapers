//
//  AdManager.swift
//  wallpapers
//
//  Created by Evan Latner on 10/13/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import GoogleMobileAds

class AdManager: NSObject, GADInterstitialDelegate {
    
    private static let _instance = AdManager()
    static var Instance: AdManager {
        return _instance
    }
    
    var interstitial: GADInterstitial!
    var interstitialIsShowing: Bool?
    
    
    // ADMOB
    public func loadRewardedVideoAd() {
        GADRewardBasedVideoAd.sharedInstance().load(GADRequest(),
                                                    withAdUnitID: "ca-app-pub-2441744724896180/3585488732")
    }
    
    // ADMOB
    public func preloadInterstitial () {
        interstitial = createAndLoadInterstitial()
    }
    
    // ADMOB
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    // ADMOB
    func showInterstitial (fromVC: UIViewController) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: fromVC)
            interstitialIsShowing = true
        }
    }
    
    // ADMOB
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
        interstitialIsShowing = false
    }
    
    public func showAd () {
        let vc = UIApplication.shared.keyWindow?.rootViewController
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: vc!)
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        print("Reward received with currency: \(reward.type), amount \(reward.amount).")
    }
    
    func rewardBasedVideoAdDidReceive(_ rewardBasedVideoAd:GADRewardBasedVideoAd) {
        print("Reward based video ad is received.")
    }
    
    func rewardBasedVideoAdDidOpen(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Opened reward based video ad.")
    }
    
    func rewardBasedVideoAdDidStartPlaying(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad started playing.")
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad is closed.")
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        print("Reward based video ad will leave application.")
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
    
    
    // Applovin
    func showApplovinAd () {
        if ALInterstitialAd.isReadyForDisplay() {
            ALInterstitialAd.show()
        }
    }

    
    
}
