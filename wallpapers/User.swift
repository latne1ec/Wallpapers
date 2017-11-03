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
    
    func setUserAsProMember () {
        
        UserDefaults.standard.set(true, forKey: "promember")
        UserDefaults.standard.synchronize()
        
        if PFUser.current() != nil {
            PFUser.current()?.setObject(true, forKey: "promember")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func disableProMembership () {
        UserDefaults.standard.set(false, forKey: "promember")
        UserDefaults.standard.synchronize()
        if PFUser.current() != nil {
            PFUser.current()?.setObject(false, forKey: "promember")
            PFUser.current()?.saveInBackground()
        }
    }
    
    func checkIfProMember ()  {
        
        let userIsProMember = UserDefaults.standard.bool(forKey: "promember")
        if userIsProMember == true {
            
            let appleValidator = AppleReceiptValidator(service: .production)
            SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecret, forceRefresh: false, completion: {
                result in
                switch result {
                case .success(let receipt):
                    // Verify the purchase of a Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        type: .autoRenewable, // or .nonRenewing (see below)
                        productId: "com.teamlevellabs.wallpapers.promembershipweekly",
                        inReceipt: receipt)
            
                    switch purchaseResult {
                    case .purchased:
                        print("purchased")
                        self.setUserAsProMember()
                    case .expired:
                        self.delegate?.enableBanner()
                        print("expired")
                        self.disableProMembership()
                    case .notPurchased:
                        self.disableProMembership()
                        print("NOT purchased")
                    }
                    
//                    let purchaseResult2 = SwiftyStoreKit.verifySubscription(
//                        type: .autoRenewable, // or .nonRenewing (see below)
//                        productId: "com.teamlevellabs.wallpapers.promembershipmonthly",
//                        inReceipt: receipt)
//                    switch purchaseResult2 {
//                    case .purchased:
//                        print("purchased")
//                        self.setUserAsProMember()
//                    case .expired:
//                        self.delegate?.enableBanner()
//                        print("expired")
//                        self.disableProMembership()
//                    case .notPurchased:
//                        self.disableProMembership()
//                        print("NOT purchased")
//                    }
//
//                    let purchaseResult3 = SwiftyStoreKit.verifySubscription(
//                        type: .autoRenewable, // or .nonRenewing (see below)
//                        productId: "com.teamlevellabs.wallpapers.promembershipyearly",
//                        inReceipt: receipt)
//                    switch purchaseResult3 {
//                    case .purchased:
//                        print("purchased")
//                        self.setUserAsProMember()
//                    case .expired:
//                        self.delegate?.enableBanner()
//                        print("expired")
//                        self.disableProMembership()
//                    case .notPurchased:
//                        self.disableProMembership()
//                        print("NOT purchased")
//                    }
                    
                case .error(let error):
                    print("Receipt verification failed: \(error)")
                }
            })
            
        } else {
            
        }
    }
}
