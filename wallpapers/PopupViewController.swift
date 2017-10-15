//
//  PopupViewController.swift
//  wallpapers
//
//  Created by Evan Latner on 10/14/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import GoogleMobileAds

class PopupViewController: UIViewController, GADRewardBasedVideoAdDelegate, GADInterstitialDelegate {

    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var popupImageView: UIImageView!
    public var popupImage: UIImage?
    public var parentVC: DetailViewController?
    var userFinishedVideo: Bool = false
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var fourLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layer.cornerRadius = 10
        self.bkgView.layer.cornerRadius = 10
        self.bkgView.clipsToBounds = true
        self.bkgView.layer.masksToBounds = true
        self.bkgView.backgroundColor = UIColor.white
        self.popupImageView.image = popupImage
        self.popupImageView.clipsToBounds = true
        fourLabel.layer.cornerRadius = 4
        fourLabel.layer.masksToBounds = true
        
        interstitial = createAndLoadInterstitial()
        
    }
    
    func createAndLoadInterstitial() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        interstitial = createAndLoadInterstitial()
    }

    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        parentVC?.heightenAlpha()
        
    }
    
    @IBAction func buttonOneTapped(_ sender: Any) {
        // START SUBSCRIPTION
    }
    
    @IBAction func buttonTwoTapped(_ sender: Any) {
        GADRewardBasedVideoAd.sharedInstance().delegate = self
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            GADRewardBasedVideoAd.sharedInstance().present(fromRootViewController: self)
        } else if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("Interstital or Video Not ready")
            dismiss(animated: true, completion: nil)
            parentVC?.saveImage()
            parentVC?.heightenAlpha()
        }
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        // USER FINISHED VIDEO
        userFinishedVideo = true
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
        AdManager.Instance.loadAd()
    }
    
    func checkIfEitherAdIsReady () -> Bool {
        if GADRewardBasedVideoAd.sharedInstance().isReady == true {
            return true
        } else if interstitial.isReady {
            return true
        }
        return false
    }
    
    func rewardBasedVideoAdWillLeaveApplication(_ rewardBasedVideoAd: GADRewardBasedVideoAd) {
        // CANCELED
    }
    
    func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didFailToLoadWithError error: Error) {
        print("Reward based video ad failed to load.")
    }
}
