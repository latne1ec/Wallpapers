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
    case ProMembership = "promembershipweekly"
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
    public var homeVC: MainCollectionViewController?
    var userFinishedVideo: Bool = false
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var fourLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bkgView.layer.cornerRadius = 11
        self.bkgView.clipsToBounds = true
        self.bkgView.layer.masksToBounds = true
        self.bkgView.backgroundColor = UIColor.white
        self.popupImageView.image = popupImage
        self.popupImageView.clipsToBounds = true
    
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
        
        let random = Int(arc4random_uniform(4))
        
        if random % 2 == 0 {
            // Prioritize ADMOB
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

        } else {
            // Prioritize APPLOVIN
            if ALIncentivizedInterstitialAd.isReadyForDisplay() {
                ALIncentivizedInterstitialAd.shared().adVideoPlaybackDelegate = self
                ALIncentivizedInterstitialAd.shared().adDisplayDelegate = self
                ALIncentivizedInterstitialAd.showAndNotify(self)
            } else if interstitial.isReady {
                interstitial.present(fromRootViewController: self)
            } else if GADRewardBasedVideoAd.sharedInstance().isReady == true {
                GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
            } else {
                print("Interstital or Video Not ready")
                dismiss(animated: true, completion: nil)
                parentVC?.saveImage()
                parentVC?.heightenAlpha()
            }
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
                let ac = UIAlertController(title: "Error", message: "An unknown error occured", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
            else if results.restoredPurchases.count > 0 {
                // RESTORE SUCCESS
                let ac = UIAlertController(title: "Purchases Restored", message: "Your purchase has been successfully restored!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                User.Instance.setUserAsProMember()
                User.Instance.checkIfProMember()
            }
            else {
                let ac = UIAlertController(title: "Error", message: "No purchases to restore", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        })
    }
    
    @IBAction func helpTapped(_ sender: UIButton) {
        print("hi")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Help")
        present(popupVC, animated: true, completion: nil)
        
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
            print(result)
            switch result {
            case .success:
                User.Instance.setUserAsProMember()
                let ac = UIAlertController(title: "Success!", message: "You are now a Pro Member, welcome to the club! Enjoy HD Wallpapers plus an Ad Free Experience for as long as your subscription is active.", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                    self.homeVC?.removeBanner()
                    self.perform(#selector(self.closePopup), with: nil, afterDelay: 0.25)
                }
                ac.addAction(okAction)
                self.present(ac, animated: true)
            case .error:
                let ac = UIAlertController(title: "Error", message: "An error occured while attempting to complete your purchase. Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
            NetworkActivityIndicatorManager.NetworkOperationFinished()
            loader.dismiss()
            loader.removeFromSuperview()
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
}
