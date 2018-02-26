//
//  DetailsView.swift
//  wallpapers
//
//  Created by Evan Latner on 2/26/18.
//  Copyright © 2018 levellabs. All rights reserved.
//

import UIKit

class DetailsView: UIView {
    
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var mainTextView: UITextView!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "DetailsView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    
    func setup () {
        
        // Create Background View
        let backgroundView = UIView()
        backgroundView.frame = CGRect(x: 0, y: 0, width: 2000, height: 2000)
        backgroundView.center = (UIApplication.shared.keyWindow?.center)!
        backgroundView.backgroundColor = UIColor.black
        backgroundView.alpha = 0.8
        self.addSubview(backgroundView)
        self.sendSubview(toBack: backgroundView)
        
        mainView.layer.cornerRadius = 17
        
        doneButton.layer.cornerRadius = 21
        doneButton.layer.shadowColor = UIColor.black.cgColor
        doneButton.layer.shadowOffset = CGSize(width: 0.0, height: 0.30)
        doneButton.layer.shadowOpacity = 0.150
        doneButton.layer.shadowRadius = 3.0
        doneButton.addButtonFade()
        
        mainView.layer.shadowColor = UIColor.black.cgColor
        mainView.layer.shadowOffset = CGSize(width: 0.0, height: 0.30)
        mainView.layer.shadowOpacity = 0.50
        mainView.layer.shadowRadius = 3.0
        
    }
    
    public func animateOpen () {
        self.alpha = 0.0
        self.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
        UIView.animate(withDuration: 0.15, animations: {
            self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            self.alpha = 1.0
        }) { (success) in
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIButton) {
        dismissTheView()
    }
    
    @objc func dismissTheView () {
        UIView.animate(withDuration: 0.175, animations: {
            self.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
            self.alpha = 0.0
        }) { (success) in
            self.removeFromSuperview()
        }
    }
}

