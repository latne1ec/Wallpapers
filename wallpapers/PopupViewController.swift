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
    
    @IBOutlet weak var fourLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bkgView.layer.cornerRadius = 11
        self.bkgView.clipsToBounds = true
        self.bkgView.layer.masksToBounds = true
        self.bkgView.backgroundColor = UIColor.white
        self.popupImageView.image = popupImage
        self.popupImageView.clipsToBounds = true
    
    }

    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        parentVC?.heightenAlpha()
        PushManager.Instance.askUserToAllowNotifications()
    }
    
    @IBAction func buttonOneTapped(_ sender: Any) {
        // START SUBSCRIPTION
        purchase(purchase: RegisteredPurchase.ProMembership)
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
        print("hi")
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Help")
        present(popupVC, animated: true, completion: nil)
        
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
