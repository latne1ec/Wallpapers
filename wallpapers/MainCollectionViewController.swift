//
//  MainCollectionViewController.swift
//  wallpapers
//
//  Created by Evan Latner on 10/11/17.
//  Copyright © 2017 levellabs. All rights reserved.
//

import UIKit
import GoogleMobileAds
import GSImageViewerController
import Parse
import SDWebImage
import NVActivityIndicatorView
import SwiftyStoreKit
import StoreKit

private let reuseIdentifier = "Cell"

class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, SKStoreProductViewControllerDelegate {

    var statusBarView: UIView?
    let imageArray: [String] = ["mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png","mango2.png"]
    var localContentArray = NSMutableArray()
    var refresher:UIRefreshControl!
    var refresherNew: NVActivityIndicatorView!
    var rateButton = UIButton()
    
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLayout()
        setupStatusBarBKG()
        retrieveContent()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.lightGray
        self.refresher.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        self.collectionView?.backgroundColor = UIColor.black
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 120, right: 0)
        
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer");
        
        setupMenu()
        setupBanner()
    
    }
    
    func setupMenu () {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        rateButton.setTitle("PRO", for: UIControlState.normal)
        rateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        rateButton.setTitleColor(UIColor(white:0.13, alpha:1.0), for: .normal)
        rateButton.backgroundColor = UIColor.white
        rateButton.layer.cornerRadius = 28
        rateButton.frame = CGRect(x: width/2-40, y: height-100, width: 80, height: 54)
        //rateButton.frame = CGRect(x: width/5, y: height-100, width: 100, height: 54)
        rateButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0).cgColor
        rateButton.layer.shadowOpacity = 1.0
        rateButton.layer.shadowRadius = 20.0
        rateButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.view.addSubview(rateButton)
        self.view.bringSubview(toFront: rateButton)
        rateButton.addTarget(self, action: #selector(requestReview), for: UIControlEvents.touchUpInside)
        rateButton.addTarget(self, action: #selector(lowerAlpha), for: UIControlEvents.touchDown)
        rateButton.addTarget(self, action: #selector(heightenAlpha), for: .touchDragExit)
        rateButton.addTarget(self, action: #selector(heightenAlpha), for: .touchCancel)
        
//        let restorePurchaseButton = UIButton(frame: CGRect(x: self.view.bounds.midX+width/4, y: height - 90, width: 50, height: 50))
//        restorePurchaseButton.backgroundColor = UIColor.white
//        restorePurchaseButton.layer.cornerRadius = 26
//        restorePurchaseButton.addTarget(self, action: #selector(restorePurchaseButtonTapped), for: UIControlEvents.touchUpInside)
//        self.view.addSubview(restorePurchaseButton)
    }
    
    func setupBanner () {
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.frame = CGRect(x:0.0,
                                  y:self.view.frame.size.height - bannerView.frame.size.height,
                                  width:bannerView.frame.size.width,
                                  height:bannerView.frame.size.height)
        bannerView.delegate = self
        self.view.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = self
        //initAd()
    }
    
    @objc func initAd () {
        bannerView.load(GADRequest())
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("adViewDidReceiveAd")
    }
    
    func adView(_ bannerView: GADBannerView,
                didFailToReceiveAdWithError error: GADRequestError) {
        print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
        Timer.scheduledTimer(timeInterval: 2, target: self,
                             selector: #selector(initAd), userInfo: nil, repeats: false)
    }
    
    @objc func heightenAlpha () {
        rateButton.alpha = 1.0
    }
    
    @objc func lowerAlpha () {
        rateButton.alpha = 0.5
    }
    
    @objc func requestReview () {
        rateButton.alpha = 1.0
//        let storeProductVC = SKStoreProductViewController()
//        storeProductVC.delegate = self
//        storeProductVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: 1296651713)])
//        self.present(storeProductVC, animated: true, completion: nil)
        
//        let message = "Check out these 4k wallpapers:"
//        if let link = NSURL(string: "https://itunes.apple.com/us/app/wallpaper-pro-hd-backgrounds/id1298573221?ls=1&mt=8")
//        {
//            let objectsToShare = [message,link] as [Any]
//            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
//            activityVC.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.addToReadingList]
//            self.present(activityVC, animated: true, completion: nil)
//        }
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Pro") as! PopupViewController
        popupVC.popupImage = UIImage(named: "Screenshot1.6.jpg")
        present(popupVC, animated: true, completion: nil)
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
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
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.nativeBounds.height {
            case 2436:
                print("here")
                statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
            default:
                print("unknown")
            }
        }
        statusBarView?.backgroundColor = UIColor.black
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
            spinner.isHidden = true
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
