//
//  ReviewController.swift
//  wallpapers
//
//  Created by Evan Latner on 10/15/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import StoreKit

class ReviewController: NSObject {
    private static let _instance = ReviewController()
    static var Instance: ReviewController {
        return _instance
    }
    
    public func requestReview () {
        SKStoreReviewController.requestReview()
    }

}
