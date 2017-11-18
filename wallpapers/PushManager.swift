//
//  PushManager.swift
//  wallpapers
//
//  Created by Evan Latner on 11/6/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import OneSignal

class PushManager: NSObject {
    
    private static let _instance = PushManager()
    static var Instance: PushManager {
        return _instance
    }
    
    func askUserToAllowNotifications () {
        
//        let random = Int(arc4random_uniform(4)) && random % 2 == 0
        
//        if !userPushEnabled () {
//            let alert = UIAlertController(title: "Please Allow Notifications", message: "Be the first to know when new premium wallpapers are added.", preferredStyle: .alert)
//            let action1 = UIAlertAction(title: "Not Now", style: .default) { (action) in
//
//            }
//            let action2 = UIAlertAction(title: "OK", style: .default) { (action) in
//                AppDelegate.Instance.requestPushNotifications()
//            }
//            alert.addAction(action1)
//            alert.addAction(action2)
//            vc.present(alert, animated: true, completion: nil)
//        }
        
        AppDelegate.Instance.requestPushNotifications()
        
    }
    
    func userPushEnabled () -> Bool {
        let notificationType = UIApplication.shared.currentUserNotificationSettings!.types
        if notificationType == [] {
            // Not enabled
            return false
        } else {
            // Enabled
            return true
        }
    }
}
