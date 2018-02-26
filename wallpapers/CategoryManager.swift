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
    var categories = ["NEW","ABSTRACT","ANIMAL","ART","CITY","FLOWERS","MODELS",
                      "NATURE","OCEAN","QUOTES","SKY","TRAVEL"]
    
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
