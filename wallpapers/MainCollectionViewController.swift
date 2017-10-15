//
//  MainCollectionViewController.swift
//  wallpapers
//
//  Created by Evan Latner on 10/11/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import GSImageViewerController
import Parse
import SDWebImage
import NVActivityIndicatorView
private let reuseIdentifier = "Cell"

class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var statusBarView: UIView?
    let imageArray: [String] = ["mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png"]
    var localContentArray = NSMutableArray()
    var refresher:UIRefreshControl!
    var refresherNew: NVActivityIndicatorView!
    var rateButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupStatusBarBKG()
        retrieveContent()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.white
        self.refresher.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        self.collectionView?.backgroundColor = UIColor.black
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        rateButton.setTitle("RATE 😁", for: UIControlState.normal)
        rateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        rateButton.setTitleColor(UIColor.darkGray, for: .normal)
        rateButton.backgroundColor = UIColor.white
        rateButton.layer.cornerRadius = 26
        rateButton.frame = CGRect(x: width/2-50, y: height-80, width: 100, height: 54)
        rateButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        rateButton.layer.shadowOpacity = 1.0
        rateButton.layer.shadowRadius = 16.0
        rateButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.view.addSubview(rateButton)
        self.view.bringSubview(toFront: rateButton)
        rateButton.addTarget(self, action: #selector(requestReview), for: UIControlEvents.touchUpInside)
        rateButton.addTarget(self, action: #selector(lowerAlpha), for: UIControlEvents.touchDown)

        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer");

    }
    
    @objc func lowerAlpha () {
        rateButton.alpha = 0.5
    }
    
    @objc func requestReview () {
        rateButton.alpha = 1.0
        ReviewController.Instance.requestReview()
    }
    
    
    @objc func refreshContent() {
        if self.localContentArray.count > 0 {
            self.localContentArray.removeAllObjects()
        }
        self.retrieveContent()
    }
    
    func setupLayout () {
        let itemSize = UIScreen.main.bounds.width / 3 - 2
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsetsMake(5, 0, 10, 0)
        layout.itemSize = CGSize(width: itemSize, height: itemSize*1.5)
        layout.footerReferenceSize = CGSize(width: self.view.frame.size.width, height: 100)
        
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        self.collectionView?.collectionViewLayout = layout
    }
    
    func setupStatusBarBKG () {
        statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 23))
        statusBarView?.backgroundColor = UIColor.black//UIColor(white:0.07, alpha:1.0)
        view.addSubview(statusBarView!)
        view.bringSubview(toFront: statusBarView!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.localContentArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! MainCollectionViewCell
        let spinnerFrame = CGRect(x: cell.frame.size.width/2-12, y: cell.frame.size.height/2-12, width: 24, height: 24)
        let spinner = NVActivityIndicatorView(frame: spinnerFrame, type: NVActivityIndicatorType.ballScale, color: UIColor.lightGray, padding:nil)
        spinner.startAnimating()
        cell.addSubview(spinner)
        let object = self.localContentArray[indexPath.row] as! PFObject
        let imageFile = object["contentFile"] as! PFFile
        let imageUrl = imageFile.url
        let url = URL(string: imageUrl!)
        cell.imageView.sd_setImage(with: url, placeholderImage: nil, options: []) { (image, error, cacheType, url) in
            cell.imageView.alpha = 0
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            UIView.animate(withDuration: 0.15, animations: {
                cell.imageView.alpha = 1
            })
        }
        cell.imageView.layer.cornerRadius = 6
        cell.imageView.layer.masksToBounds = true
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MainCollectionViewCell
        if cell.imageView.image == nil {
            return
        }
        let imageInfo   = GSImageInfo(image: cell.imageView.image!, imageMode: .aspectFill)
        let transitionInfo = GSTransitionInfo(fromView:(cell.imageView))
        let imageViewer = DetailViewController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        present(imageViewer, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        
        footerView.backgroundColor = UIColor.black
        let label = UILabel()
        label.frame = footerView.frame
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "New wallpapers added every day.\nSee you tomorrow ✌🏼"
        label.numberOfLines = 2
        label.alpha = 0.0
        footerView.addSubview(label)
        UIView.animate(withDuration: 0.15, delay: 1, options: [], animations: {
            label.alpha = 1.0
        }) { (success) in
            
        }
        return footerView

    }
    
    func retrieveContent () {
        let query = PFQuery(className:"Content")
        query.whereKey("isVisible", equalTo:true)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if let objects = objects {
                    for object in objects {
                        self.localContentArray.add(object)
                    }
                }
                self.collectionView?.reloadData()
                self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.5)
            } else {
                print("Error: \(error!) ")
                self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.5)
            }
        }
    }
    
    @objc func endRefreshing () {
        self.refresher.endRefreshing()
    }

}
