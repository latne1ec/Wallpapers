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

var sharedSecret = "3d99e9a864fb4c39b39c39a552bcd6b9"

enum RegisteredPurchase: String {
    case ProMembership = "removeads"
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

class PopupViewController: UIViewController {
    
    let bundleId = "com.teamlevellabs.hdwallpapers"
    var proMembership = RegisteredPurchase.ProMembership

    @IBOutlet weak var bkgView: UIView!
    @IBOutlet weak var popupImageView: UIImageView!
    public var popupImage: UIImage?
    public var parentVC: DetailViewController?
    public var homeVC: MainCollectionViewController?
    var userFinishedVideo: Bool = false
    var interstitial: GADInterstitial!
    
    @IBOutlet weak var premiumContentLabel: UILabel!
    
    @IBOutlet weak var premiumContentRectangle: UILabel!
    @IBOutlet weak var fourLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bkgView.layer.cornerRadius = 11
        self.bkgView.clipsToBounds = true
        self.bkgView.layer.masksToBounds = true
        self.bkgView.backgroundColor = UIColor.white
        self.popupImageView.image = popupImage
        self.popupImageView.clipsToBounds = true
        
        if premiumContentLabel != nil {
            premiumContentLabel.layer.shadowColor = UIColor.black.cgColor
            premiumContentLabel.layer.shadowOpacity = 1.0
            premiumContentLabel.layer.shadowRadius = 12.0
            premiumContentLabel.layer.shadowOffset = CGSize(width: 0, height: 0)
        }
        
        if premiumContentRectangle != nil {
            premiumContentRectangle.layer.cornerRadius = 5
            premiumContentRectangle.layer.shadowColor = UIColor.black.cgColor
            premiumContentRectangle.layer.shadowOpacity = 0.50
            premiumContentRectangle.layer.shadowRadius = 2.0
            premiumContentRectangle.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
            premiumContentRectangle.clipsToBounds = true
            //premiumContentRectangle.layer.masksToBounds = true
        }
    
    }

    @IBAction func closePopup(_ sender: Any) {
        let ac = UIAlertController(title: "Are you sure?", message: "The 3 day trial is 100% FREE plus you can cancel your subscription at anytime at no charge.", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Later", style: .default, handler: { (alert) in
            self.dismiss(animated: true, completion: nil)
            self.parentVC?.heightenAlpha()
            self.parentVC?.dismiss(animated: true, completion: nil)
        })
        let action2 = UIAlertAction(title: "Try FREE", style: .default, handler: { (alert) in
            // Make Subscription Purchase
            self.purchaseSubscription()
        })
        ac.addAction(action1)
        ac.addAction(action2)
        self.present(ac, animated: true, completion: nil)
    }
    
    @IBAction func buttonOneTapped(_ sender: Any) {
        // Old
        //purchase(purchase: RegisteredPurchase.ProMembership)
        purchaseSubscription()
    }
    
    @IBAction func buttonTwoTapped(_ sender: Any) {
        
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
            } else if results.restoredPurchases.count > 0 {
                // RESTORE SUCCESS
                let ac = UIAlertController(title: "Purchases Restored", message: "Your purchase has been successfully restored!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    self.homeVC?.removeBanner()
                    self.perform(#selector(self.closePopup), with: nil, afterDelay: 0.25)
                    User.Instance.setUserAsProMember()
                })
                ac.addAction(action)
                self.present(ac, animated: true)
                
            } else {
                let ac = UIAlertController(title: "Error", message: "No purchases to restore", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        })
    }
    
    @IBAction func helpTapped(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Help")
        present(popupVC, animated: true, completion: nil)
        
    }
    
    // New Subscriptions
    
    func purchaseSubscription () {
        let loader = LoadingView()
        loader.frame = view.frame
        self.view.addSubview(loader)
        loader.show()
        let productId = "com.teamlevellabs.hdwallpapers.premiummembership"
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                print("Purchased")
                User.Instance.setUserAsPremiumMembershipWeekly()
                self.homeVC?.removeBanner()
                self.parentVC?.dismiss(animated: true, completion: nil)
            } else {
                // purchase error
            }
            loader.dismiss()
            loader.removeFromSuperview()
        }
    }
    
    
    
    // OLD
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
                let ac = UIAlertController(title: "Success!", message: "You have successfully removed all ads from HD Wallpapers™", preferredStyle: .alert)
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
