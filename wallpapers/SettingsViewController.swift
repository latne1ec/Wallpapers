//
//  SettingsViewController.swift
//  wallpapers
//
//  Created by Evan Latner on 11/30/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class SettingsViewController: UIViewController, SKStoreProductViewControllerDelegate {

    @IBOutlet weak var bkgView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bkgView.layer.cornerRadius = 11
        self.bkgView.clipsToBounds = true
        self.bkgView.layer.masksToBounds = true
        self.bkgView.backgroundColor = UIColor.white

    }
    
    @IBAction func restorePurchases(_ sender: UIButton) {
        
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
    
    @IBAction func removeAdsButtonTapped(_ sender: UIButton) {
        makePurchase()
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        let message = "Check out these cool wallpapers:"
        if let link = NSURL(string: "https://itunes.apple.com/us/app/hd-wallpapers/id1306304549?mt=8") {
            let objectsToShare = [message,link] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func rateButtonTapped(_ sender: UIButton) {
        let storeProductVC = SKStoreProductViewController()
        storeProductVC.delegate = self
        storeProductVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: 1306304549)])
        self.present(storeProductVC, animated: true, completion: nil)
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true) {
        }
    }
    
    func makePurchase () {
        let loader = LoadingView()
        loader.backgroundColor = UIColor.black
        loader.activityIndicator.activityIndicatorViewStyle = .whiteLarge
        loader.frame = view.frame
        self.view.addSubview(loader)
        loader.show()
        SwiftyStoreKit.purchaseProduct("com.teamlevellabs.hdwallpapers.removeads", completion: {
            result in
            print(result)
            switch result {
            case .success:
                User.Instance.setUserAsProMember()
                let ac = UIAlertController(title: "Success!", message: "You have successfully removed all ads from Tape Measure™", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                }
                ac.addAction(okAction)
                self.present(ac, animated: true)
            case .error:
                let ac = UIAlertController(title: "Error", message: "An error occured while attempting to complete your purchase. Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
            loader.dismiss()
            loader.removeFromSuperview()
        })
    }

}
