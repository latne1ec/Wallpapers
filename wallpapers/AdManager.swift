//
//  AdManager.swift
//  wallpapers
//
//  Created by Evan Latner on 10/13/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Parse

protocol AdManagerDelegate {
    func enableBanner()
}

class AdManager: NSObject, GADInterstitialDelegate, ALAdDisplayDelegate, ALAdVideoPlaybackDelegate {
    
    private static let _instance = AdManager()
    static var Instance: AdManager {
        return _instance
    }
    
    var delegate: AdManagerDelegate?

    var interstitial: GADInterstitial!
    var interstitialIsShowing: Bool?
    var monetizationEnabled: Bool?
    var shouldShowAd: Bool?
    
    func detectIfMonetizationEnabled () {
        PFConfig.getInBackground { (config, error) in
            self.monetizationEnabled = config?["monetizationEnabled"] as? Bool
            if self.monetizationEnabled == true {
                print("here")
                self.delegate?.enableBanner()
            }
        }
    }
    
    // ADMOB
    public func preloadInterstitial () {
        interstitial = createAndLoadInterstitial()
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2441744724896180/3211349561")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func showAdmobInterstitial (fromVC: UIViewController) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: fromVC)
            interstitialIsShowing = true
        }
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        preloadInterstitial()
        interstitialIsShowing = false
        print("did dismiss")
        if PFUser.current() != nil {
            PFUser.current()?.incrementKey("interstitialWatchCount")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial ready")
    }
    
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print(error.localizedDescription)
    }
    
    
    // APPLOVIN
    
    func showApplovinAd () {
        if ALInterstitialAd.isReadyForDisplay() {
            ALInterstitialAd.show()
        }
    }
    
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        print("was hidden")
        if PFUser.current() != nil {
            PFUser.current()?.incrementKey("interstitialWatchCount")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        print("clicked")
    }
    
    func videoPlaybackBegan(in ad: ALAd) {
        
    }
    
    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool) {
        
    }
    
}
