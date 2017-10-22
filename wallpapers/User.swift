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

class User: NSObject {
    
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
        
        let appleValidator = AppleReceiptValidator(service: .production)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecret, forceRefresh: false, completion: {
            result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    type: .autoRenewable, // or .nonRenewing (see below)
                    productId: "com.teamlevellabs.wallpapers.promembership",
                    inReceipt: receipt)
                print(purchaseResult)
                
                switch purchaseResult {
                case .purchased:
                    print("purchased")
                    self.setUserAsProMember()
                case .expired:
                    print("expired")
                    self.disableProMembership()
                case .notPurchased:
                    self.disableProMembership()
                    print("NOT purchased")
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        })
    }
}
