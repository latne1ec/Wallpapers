//
//  SettingsManager.swift
//  wallpapers
//
//  Created by Evan Latner on 2/26/18.
//  Copyright © 2018 levellabs. All rights reserved.
//

import UIKit
import Parse

class SettingsManager: NSObject {
    private static let _instance = SettingsManager()
    static var Instance: SettingsManager {
        return _instance
    }

    var termsText: String?
    
    func getTermsText () {
        PFConfig.getInBackground { (config, error) in
            if config != nil {
                self.termsText = config?["termsText"] as? String
            }
        }
    }
    
    var hardSellEnabled: Bool = false
    func detectIfShouldShowHardSell () {
        PFConfig.getInBackground { (config, error) in
            if config != nil {
                self.hardSellEnabled = config?["hardSellEnabled"] as! Bool
            }
        }
    }
    
    var hasShownHardSell: Bool = {
        if UserDefaults.standard.object(forKey: "hasShownHardSell") != nil {
            return true
        } else {
            return false
        }
    }()
}
