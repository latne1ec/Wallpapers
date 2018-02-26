//
//  SubscribeView.swift
//  wallpapers
//
//  Created by Evan Latner on 2/26/18.
//  Copyright © 2018 levellabs. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import Parse

class SubscribeView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var detailsButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mainImage: UIImageView!
    @IBOutlet weak var featureOne: UILabel!
    @IBOutlet weak var featureTwo: UILabel!
    @IBOutlet weak var featureThree: UILabel!
    @IBOutlet weak var termsTextView: UITextView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "SubscribeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setup () {
        
        // Create Background View
        let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: 2000, height: 2000)
        backgroundView.center = (UIApplication.shared.keyWindow?.center)!
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.88
        self.addSubview(backgroundView)
        self.sendSubview(toBack: backgroundView)
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0.0, height: 0.25)
        mainView.layer.shadowOpacity = 0.24
        mainView.layer.shadowRadius = 5.0
        
        mainView.layer.cornerRadius = 17
        mainView.clipsToBounds = true
        
        buyButton.addTarget(self, action: #selector(buyButtonTapped), for: .touchUpInside)
        buyButton.layer.shadowColor = UIColor.black.cgColor
        buyButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.30)
        buyButton.layer.shadowOpacity = 0.125
        buyButton.layer.shadowRadius = 3.0
        buyButton.adjustsImageWhenHighlighted = false
        buyButton.layer.cornerRadius = 27
        buyButton.addButtonFade()
        
        let label1 = UILabel()
        label1.textColor = UIColor(red:0.18, green:0.18, blue:0.19, alpha:1.0)
        label1.text = "Try for Free"
        let heavyFont = UIFont.systemFont(ofSize: 21.0, weight: UIFont.Weight.heavy)
        label1.font = heavyFont
        label1.textAlignment = .center
        label1.frame = CGRect(x: 0, y: 0, width: buyButton.frame.size.width, height: 40)
        buyButton.addSubview(label1)
        
        let label2 = UILabel()
        label2.textColor = UIColor(red:0.18, green:0.18, blue:0.19, alpha:1.0)
        let boldFont = UIFont.systemFont(ofSize: 9, weight: UIFont.Weight.bold)
        label2.font = boldFont
        label2.tag = 666
        label2.textAlignment = .center
        label2.frame = CGRect(x: 0, y: 18, width: buyButton.frame.size.width, height: 42)
        buyButton.addSubview(label2)
        
        // Get Terms
//        if let termsText = SettingsManager.Instance.termsText {
//            let x = "X"
//            if termsText != x {
//                termsTextView.text = termsText
//            }
//        }
        
        if !Reachability.isConnectedToNetwork() {
            label1.isHidden = true
            label2.isHidden = true
            buyButton.setTitle("Try for Free", for: .normal )
        }
        
        closeButton.addTarget(self, action: #selector(dismissTheView), for: .touchUpInside)
        detailsButton.addTarget(self, action: #selector(detailsButtonTapped), for: .touchUpInside)
        restoreButton.addTarget(self, action: #selector(restoreButtonTapped), for: .touchUpInside)
        
        mainImage.layer.masksToBounds = true
        mainImage.clipsToBounds = true
        
    }
    
    public func animateOpen () {
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }) { (success) in
        }
    }
    
    @objc func buyButtonTapped () {
        purchaseSubscription()
    }
    
    @objc func detailsButtonTapped () {
        let detailsView = DetailsView.instanceFromNib() as! DetailsView
        detailsView.setup()
        detailsView.animateOpen()
        self.addSubview(detailsView)
    }
    
    @objc func restoreButtonTapped () {
        //restorePurchases()
    }
    
    @objc func dismissTheView () {
        
//        if SettingsManager.Instance.hardSellEnabled && !SettingsManager.Instance.hasShownHardSell && !User.Instance.isProSubscriber {
//            showHardSellAlert()
//            return
//        }
        
        UIView.animate(withDuration: 0.175, animations: {
            self.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
            self.alpha = 0.0
        }) { (success) in
            self.removeFromSuperview()
        }
    }
    
    func showHardSellAlert () {
        SettingsManager.Instance.hasShownHardSell = true
        let ac = UIAlertController(title: "Are you sure?", message: "The 3 day trial is 100% Free plus you can cancel your subscription at anytime at no charge.", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Not now", style: .default, handler: { (alert) in
            self.dismissTheView()
        })
        let action2 = UIAlertAction(title: "Try for Free", style: .default, handler: { (alert) in
            // Make Subscription Purchase
            self.purchaseSubscription()
        })
        ac.addAction(action1)
        ac.addAction(action2)
        ac.preferredAction = action2
        UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
    }
    
    func purchaseSubscription () {
        
        if !Reachability.isConnectedToNetwork() {
            let alert = UIAlertController(title: "No Internet Connection", message: "Your internet connection appears to be offline. Please connect to the internet and try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
            return
        }
        
        let loader = LoadingView()
        loader.frame = (UIApplication.shared.keyWindow?.frame)!
        loader.center = (UIApplication.shared.keyWindow?.center)!
        loader.backgroundColor = UIColor.black
        loader.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        UIApplication.shared.keyWindow?.addSubview(loader)
        loader.show()
        let productId = "com.teamlevellabs.measuretape.prosubscriber"
        SwiftyStoreKit.purchaseProduct(productId, atomically: true) { result in
            
            if case .success(let purchase) = result {
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
                // PURCHASED
                
                /// CHANGEEE
                //User.Instance.setUserAsProSubscriberYearly()
                self.dismissTheView()
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBanner"), object: nil)
            } else {
                let ac = UIAlertController(title: "Error", message: "An error occured while attempting to complete your purchase. Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
                // purchase error
            }
            loader.dismiss()
            loader.removeFromSuperview()
        }
    }
    
//    func restorePurchases() {
//
//        if !Reachability.isConnectedToNetwork() {
//            let alert = UIAlertController(title: "No Internet Connection", message: "Your internet connection appears to be offline. Please connect to the internet and try again.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
//            return
//        }
//
//        let loader = LoadingView()
//        loader.frame = (UIApplication.shared.keyWindow?.frame)!
//        loader.center = (UIApplication.shared.keyWindow?.center)!
//        loader.backgroundColor = UIColor.black
//        loader.activityIndicator.activityIndicatorViewStyle = .whiteLarge
//        UIApplication.shared.keyWindow?.addSubview(loader)
//        loader.show()
//        SwiftyStoreKit.restorePurchases(atomically: true, completion: {
//            results in
//            loader.dismiss()
//            if results.restoreFailedPurchases.count > 0 {
//                let ac = UIAlertController(title: "Error", message: "An unknown error occured", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default))
//                UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
//            } else if results.restoredPurchases.count > 0 {
//                // RESTORE SUCCESS
//                print("items are avail to restore")
//                //print("Restore Success: \(results.restoredPurchases)")
//                for index in 0..<results.restoredPurchases.count {
//                    if results.restoredPurchases[index].productId == "com.teamlevellabs.measuretape.removeads" {
//                        // User previously bought Remove Ads
//                        let ac = UIAlertController(title: "Purchases Restored", message: "Your purchase has been successfully restored!", preferredStyle: .alert)
//                        let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
//                            User.Instance.setUserAsProMember()
//                            self.dismissTheView()
//                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBanner"), object: nil)
//                        })
//                        ac.addAction(action)
//                        print("here 2")
//                        UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
//                    }
//
//                    if results.restoredPurchases[index].productId == "com.teamlevellabs.measuretape.prosubscriber" {
//                        print("Pro Subscriber")
//                        // Now verify the membership is still active
//                        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: sharedSecret)
//                        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false, completion: {
//                            result in
//                            switch result {
//                            case .success(let receipt):
//                                // Verify the purchase of a Subscription
//                                let purchaseResult = SwiftyStoreKit.verifySubscription(
//                                    ofType: .autoRenewable,
//                                    productId: "com.teamlevellabs.measuretape.prosubscriber",
//                                    inReceipt: receipt)
//                                switch purchaseResult {
//                                case .purchased:
//                                    print("Purchased")
//                                    let ac = UIAlertController(title: "Purchases Restored", message: "Your purchase has been successfully restored!", preferredStyle: .alert)
//                                    let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
//                                        User.Instance.setUserAsProSubscriberYearly()
//                                        self.dismissTheView()
//                                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "disableBanner"), object: nil)
//                                    })
//                                    ac.addAction(action)
//                                    print("here 3")
//                                    UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
//                                case .expired:
//                                    print("expired")
//                                    let ac = UIAlertController(title: "Subscription Expired", message: "Your subscription has expired.", preferredStyle: .alert)
//                                    let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
//                                    })
//                                    ac.addAction(action)
//                                    print("here 4")
//                                    User.Instance.disableProSubscription()
//                                    UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
//                                case .notPurchased:
//                                    print("NOT purchased")
//                                    let ac = UIAlertController(title: "Error", message: "No subscriptions to restore", preferredStyle: .alert)
//                                    ac.addAction(UIAlertAction(title: "OK", style: .default))
//                                    print("here 5")
//                                    User.Instance.disableProSubscription()
//                                    UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
//                                }
//                            case .error(let error):
//                                print("Receipt verification failed: \(error)")
//                            }
//                        })
//                    }
//                }
//
//            } else {
//                let ac = UIAlertController(title: "Error", message: "No purchases to restore", preferredStyle: .alert)
//                ac.addAction(UIAlertAction(title: "OK", style: .default))
//                print("here 6")
//                UIApplication.shared.keyWindow?.rootViewController?.present(ac, animated: true, completion: nil)
//            }
//        })
//    }
    
}


extension UIButton {
    func addButtonFade() {
        self.addTarget(self, action: #selector(fade), for: .touchDown)
        self.addTarget(self, action: #selector(reset), for: .touchUpInside)
        self.addTarget(self, action: #selector(reset), for: .touchCancel)
        self.addTarget(self, action: #selector(reset), for: .touchDragExit)
        self.addTarget(self, action: #selector(reset), for: .touchDragOutside)
    }
    
    @objc func fade () {
        self.alpha = 0.4
    }
    @objc func reset () {
        UIView.animate(withDuration: 0.05) {
            self.alpha = 1.0
        }
    }
}
