//
//  User.swift
//  wallpapers
//
//  Created by Evan Latner on 10/20/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import Parse
import SwiftyStoreKit
import StoreKit

protocol UserDelegate {
    func enableBanner()
}

class User: NSObject {
    
    var delegate: UserDelegate?
    
    private static let _instance = User()
    static var Instance: User {
        return _instance
    }
    
    var proMember: Bool?
    
    // Old for Remove Ads
    func setUserAsProMember () {
        
        UserDefaults.standard.set(true, forKey: "promember")
        UserDefaults.standard.synchronize()
        
        if PFUser.current() != nil {
            PFUser.current()?.setObject(true, forKey: "promember")
            PFUser.current()?.saveInBackground()
        }
    }
    
    
    // New for Subscriptions
    func setUserAsPremiumMembershipWeekly () {
        UserDefaults.standard.set(true, forKey: "premiumMembership")
        UserDefaults.standard.synchronize()
        
        if PFUser.current() != nil {
            PFUser.current()?.setObject(true, forKey: "premiumMembership")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func disablePremiumMembership () {
        UserDefaults.standard.set(false, forKey: "premiumMembership")
        UserDefaults.standard.synchronize()
        if PFUser.current() != nil {
            PFUser.current()?.setObject(false, forKey: "premiumMembership")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func checkIfPremiumMembership ()  {
        print("here")
        let userIsProMember = UserDefaults.standard.bool(forKey: "premiumMembership")
        if userIsProMember == true {
            print("ok")
            let appleValidator = AppleReceiptValidator(service: .sandbox)
            SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecret, forceRefresh: false, completion: {
                result in
                switch result {
                case .success(let receipt):
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        type: .autoRenewable, 
                        productId: "com.teamlevellabs.hdwallpapers.premiummembership",
                        inReceipt: receipt)
            
                    switch purchaseResult {
                    case .purchased(let expiryDate):
                        print("purchased")
                        print("Product is valid until \(expiryDate)")
                        self.setUserAsPremiumMembershipWeekly()
                    case .expired:
                        // Re enable - Not for no ads
                        //self.delegate?.enableBanner()
                        print("expired")
                        self.disablePremiumMembership()
                    case .notPurchased:
                        self.delegate?.enableBanner()
                        self.disablePremiumMembership()
                        print("NOT purchased")
                    }
                    
                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            })
            
        } else {
            
        }
    }
}
