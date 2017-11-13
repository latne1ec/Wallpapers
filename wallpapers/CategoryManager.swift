//
//  CategoryManager.swift
//  wallpapers
//
//  Created by Evan Latner on 11/9/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit

protocol CategoryManagerDelegate {
    func categoryChanged()
}

class CategoryManager: NSObject {
    
    private static let _instance = CategoryManager()
    static var Instance: CategoryManager {
        return _instance
    }
    var categories = ["NEW","ARCHITECTURE","ART","CITY","FLOWERS","NATURE","OCEAN","SPACE","TRAVEL"]
    
    var delegate: CategoryManagerDelegate?
    
    var currentCategory: String? {
        didSet {
            if currentCategory == oldValue {
                return
            }
            delegate?.categoryChanged()
        }
    }
}
