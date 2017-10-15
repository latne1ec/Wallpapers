//
//  MainViewController.swift
//  wallpapers
//
//  Created by Evan Latner on 10/12/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import Parse
import SDWebImage

extension UIScrollView {
    var currentPage:Int{
        return Int(round(self.contentOffset.x / self.frame.size.width))
    }
}

class MainViewController: UIViewController, UIScrollViewDelegate {
    
    let scroller = UIScrollView()
    let downloadButton = UIButton()
    let currentIndex = Int()
    var extraWidth = CGFloat()
    let contentArray = NSMutableArray()
    let imageArray = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black
        extraWidth = self.view.frame.size.width+25
        grabContent()
        
    }
    
    func grabContent () {
        let query = PFQuery(className:"Content")
        query.whereKey("isVisible", equalTo:true)
        query.order(byAscending: "createdAt")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.contentArray.add(object)
                    }
                }
                self.setupScrollerImages()
            } else {
                print("Error: \(error!) ")
            }
        }
    }
    
    func setupScrollerImages () {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        scroller.frame = CGRect(x: 0, y: 0, width: extraWidth, height: self.view.frame.size.height)
        scroller.contentSize = CGSize(width: extraWidth * CGFloat(contentArray.count), height: self.view.frame.size.height)
        scroller.isPagingEnabled = true
        scroller.bounces = true
        scroller.showsVerticalScrollIndicator = false
        scroller.showsHorizontalScrollIndicator = false
        scroller.contentOffset = CGPoint(x: 0, y: 0)
        self.view.addSubview(scroller)
        
        for index in 0..<contentArray.count {
            let imageView = UIImageView()
            imageView.sd_setShowActivityIndicatorView(true)
            imageView.sd_setIndicatorStyle(.whiteLarge)
            let object = self.contentArray[index] as! PFObject
            let imageFile = object["contentFile"] as! PFFile
            let imageUrl = imageFile.url
            imageView.sd_setImage(with: URL(string: imageUrl!), placeholderImage: nil)
            imageView.frame = CGRect(x: extraWidth * CGFloat(index), y: 0, width: width, height: height)
            imageView.layer.cornerRadius = 10
            imageView.layer.masksToBounds = true
            imageArray.add(imageView)
            scroller.addSubview(imageView)
        }
        
        downloadButton.setTitle("SAVE WALLPAPER", for: UIControlState.normal)
        downloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        downloadButton.setTitleColor(UIColor.darkGray, for: .normal)
        downloadButton.backgroundColor = UIColor.white
        downloadButton.layer.cornerRadius = 27
        downloadButton.frame = CGRect(x: width/4, y: height-120, width: width/2, height: 54)
        downloadButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        downloadButton.layer.shadowOpacity = 1.0
        downloadButton.layer.shadowRadius = 10.0
        downloadButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        downloadButton.addTarget(self, action: #selector(downloadImage), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(lowerAlpha), for: .touchDown)
        downloadButton.addTarget(self, action: #selector(heightenAlpha), for: .touchDragExit)
        self.view.addSubview(downloadButton)
        self.view.bringSubview(toFront: downloadButton)
    }
    
    @objc func lowerAlpha () {
        downloadButton.alpha = 0.7
    }
    @objc func heightenAlpha () {
        downloadButton.alpha = 1.0
    }
    
    @objc func downloadImage () {
        downloadButton.alpha = 1.0
        let imageView = imageArray[scroller.currentPage] as! UIImageView
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, true, 2)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        imageView.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos for wallpaper use.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func downloadAllImages () {
        
        for object in contentArray {
            let dasObject = object as! PFObject
            let imageFile = dasObject["contentFile"] as! PFFile
            let imageUrl = imageFile.url
            let url = URL(string: imageUrl!)
            let imageManager = SDWebImageManager.shared()
            imageManager.imageDownloader?.downloadImage(with: url, options: [], progress: nil, completed: { (image, data, error, success) in
            })
        }
    }
}
