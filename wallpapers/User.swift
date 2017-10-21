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
    }
    
    func disableProMembership () {
        UserDefaults.standard.set(false, forKey: "promember")
        UserDefaults.standard.synchronize()
    }
    
    func checkIfProMember ()  {
        
        let appleValidator = AppleReceiptValidator(service: .production)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, password: sharedSecret, forceRefresh: true, completion: {
            result in
            switch result {
            case .success(let receipt):
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    type: .autoRenewable, // or .nonRenewing (see below)
                    productId: "com.teamlevellabs.wallpapers.promembership",
                    inReceipt: receipt)
                
                switch purchaseResult {
                case .purchased:
                    self.proMember = true
                case .expired:
                    self.proMember = false
                case .notPurchased:
                    self.proMember = false
                }
                
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        })
    }

}
