//
//  PopupViewController.swift
//  wallpapers
//
//  Created by Evan Latner on 10/14/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Parse
import SwiftyStoreKit
import StoreKit

var sharedSecret = "e1cff994993d43718a641288122d06bc"

enum RegisteredPurchase: String {
    case ProMembership = "promembership"
}

class NetworkActivityIndicatorManager: NSObject {
    private static var loadingCount = 0
    
    class func NetworkOperationStarted () {
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        loadingCount+=1
    }
    
    class func NetworkOperationFinished () {
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
}

class PopupViewController: UIViewController, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate, ALAdRewardDelegate, ALAdVideoPlaybackDelegate, ALAdDisplayDelegate {
    
    
    let bundleId = "com.teamlevellabs.wallpapers"
    var proMembership = RegisteredPurchase.ProMembership

    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var popupImageView: UIImageView!
    public var popupImage: UIImage?
    public var parentVC: DetailViewController?
    var userFinishedVideo: Bool = false
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var fourLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.view.layer.cornerRadius = 10
        self.bkgView.layer.cornerRadius = 11
        self.bkgView.clipsToBounds = true
        self.bkgView.layer.masksToBounds = true
        self.bkgView.backgroundColor = UIColor.white
        self.popupImageView.image = popupImage
        self.popupImageView.clipsToBounds = true
//        fourLabel.layer.cornerRadius = 4
//        fourLabel.layer.masksToBounds = true
        
        interstitial = createAndLoadInterstitial()
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-2441744724896180/3211349561")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        dismiss(animated: true, completion: nil)
        if PFUser.current() != nil {
            PFUser.current()?.incrementKey("interstitialWatchCount")
            PFUser.current()?.saveInBackground()
        }
        parentVC?.saveImage()
        parentVC?.heightenAlpha()
        interstitial = createAndLoadInterstitial()
    }

    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        parentVC?.heightenAlpha()
        
    }
    
    @IBAction func buttonOneTapped(_ sender: Any) {
        // START SUBSCRIPTION
        purchase(purchase: RegisteredPurchase.ProMembership)
    }
    
    @IBAction func buttonTwoTapped(_ sender: Any) {
    
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        } else if ALIncentivizedInterstitialAd.isReadyForDisplay() {
            ALIncentivizedInterstitialAd.shared().adVideoPlaybackDelegate = self
            ALIncentivizedInterstitialAd.shared().adDisplayDelegate = self
            ALIncentivizedInterstitialAd.showAndNotify(self)
        } else if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Interstital or Video Not ready")
            dismiss(animated: true, completion: nil)
            parentVC?.saveImage()
            parentVC?.heightenAlpha()
        }
    }
    
    @IBAction func restorePurchasesTapped(_ sender: UIButton) {
        
        let loader = LoadingView()
        loader.frame = view.frame
        self.view.addSubview(loader)
        loader.show()
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            results in
            loader.dismiss()
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        })
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        // USER FINISHED VIDEO
        userFinishedVideo = true
        if PFUser.current() != nil {
            PFUser.current()?.incrementKey("rewardedVideoWatchCount")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func rewardBasedVideoAdDidClose(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        if userFinishedVideo {
            dismiss(animated: true, completion: nil)
            parentVC?.saveImage()
            parentVC?.heightenAlpha()
        } else {
            let ac = UIAlertController(title: "Sorry", message: "You need to watch a full video to unlock and save this wallpaper.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
        AdManager.Instance.loadRewardedVideoAd()
    }
    
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        // CANCELED
    }
    
    
    // APPLOVIN
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
    
    func rewardValidationRequest(for ad: ALAd, didSucceedWithResponse response: [AnyHashable : Any]) {
        print("Showing Video")
    }
    
    func rewardValidationRequest(for ad: ALAd, didExceedQuotaWithResponse response: [AnyHashable : Any]) {
        
    }
    
    func rewardValidationRequest(for ad: ALAd, wasRejectedWithResponse response: [AnyHashable : Any]) {
        
    }
    
    func videoPlaybackBegan(in ad: ALAd) {
        
    }
    
    func videoPlaybackEnded(in ad: ALAd, atPlaybackPercent percentPlayed: NSNumber, fullyWatched wasFullyWatched: Bool) {
        if wasFullyWatched {
            userFinishedVideo = true
        }
    }
    
    
    func rewardValidationRequest(for ad: ALAd, didFailWithError responseCode: Int) {
        print(responseCode)
        if responseCode == kALErrorCodeIncentivizedUserClosedVideo {
            
            let ac = UIAlertController(title: "Sorry", message: "You need to watch a full video to unlock and save this wallpaper.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                ALIncentivizedInterstitialAd.preloadAndNotify(nil)
            }
            ac.addAction(okAction)
            present(ac, animated: true)
        }
    }
    
    func ad(_ ad: ALAd, wasDisplayedIn view: UIView) {
        
    }
    
    func ad(_ ad: ALAd, wasHiddenIn view: UIView) {
        self.perform(#selector(performSave), with: nil, afterDelay: 0.75)
    }
    
    @objc func performSave () {
        if PFUser.current() != nil {
            PFUser.current()?.incrementKey("rewardedVideoWatchCount")
            PFUser.current()?.saveInBackground()
        }
        dismiss(animated: true, completion: nil)
        parentVC?.saveImage()
        parentVC?.heightenAlpha()
        ALIncentivizedInterstitialAd.preloadAndNotify(nil)
    }
    
    func ad(_ ad: ALAd, wasClickedIn view: UIView) {
        
    }
    
    
    // IAP
    
    func getInfo (purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([bundleId + "." + purchase.rawValue], completion: {
            result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
        })
    }
    
    func purchase (purchase: RegisteredPurchase) {
        let loader = LoadingView()
        loader.frame = view.frame
        self.view.addSubview(loader)
        loader.show()
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.purchaseProduct(bundleId + "." + purchase.rawValue, completion: {
            result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
            loader.dismiss()
            loader.removeFromSuperview()
        })
    }
    
    func restorePurchases () {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
            result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
        })
    }
    
    func verifyReceipt () {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecret, forceRefresh: true, completion: {
            result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
        })
    }
    
    func verifyPurchase () {
        NetworkActivityIndicatorManager.NetworkOperationStarted()
        let appleValidator = AppleReceiptValidator(service: .production)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecret, forceRefresh: true, completion: {
            result in
            NetworkActivityIndicatorManager.NetworkOperationFinished()
        })
    }
    
    
    
    
}
