//
//  DataManager.swift
//  wallpapers
//
//  Created by Evan Latner on 10/11/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import Parse

class DataManager: NSObject {
    
    private static let _instance = DataManager()
    static var Instance: DataManager {
        return _instance
    }
    
    var contentArray: NSMutableArray?
    
    func retrieveContent () -> NSMutableArray? {
        let query = PFQuery(className:"Content")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.contentArray?.add(object)
                    }
                }
            } else {
                print("Error: \(error!) ")
            }
        }
        return contentArray
    }

}
