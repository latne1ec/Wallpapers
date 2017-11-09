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

class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, SKStoreProductViewControllerDelegate, UserDelegate, AdManagerDelegate, CategoryManagerDelegate {

    var statusBarView: UIView?
    var localContentArray = NSMutableArray()
    var refresher:UIRefreshControl!
    var refresherNew: NVActivityIndicatorView!
    var rateButton = UIButton()
    var bannerView: GADBannerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CategoryManager.Instance.currentCategory = "NEW"
        setupLayout()
        setupStatusBarBKG()
        retrieveContent()
        
        self.refresher = UIRefreshControl()
        self.collectionView!.alwaysBounceVertical = true
        self.refresher.tintColor = UIColor.lightGray
        self.refresher.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        self.collectionView!.addSubview(refresher)
        self.collectionView?.backgroundColor = UIColor.black
        self.collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 130, right: 0)
        
        self.collectionView?.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "Footer");
        
        setupMenu()
        //setupBanner()
        User.Instance.delegate = self
        AdManager.Instance.delegate = self
        CategoryManager.Instance.delegate = self
    }
    
    func categoryChanged() {
        rateButton.setTitle(CategoryManager.Instance.currentCategory, for: .normal)
        retrieveContent()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkInternetConnection()
        print(PushManager.Instance)
        self.perform(#selector(askForPush), with: nil, afterDelay: 0.5)
    }
    
    @objc func askForPush () {
         PushManager.Instance.askUserToAllowNotifications(from: self)
    }
    
    func checkInternetConnection () {
        if Reachability.isConnectedToNetwork(){
        } else {
            let ac = UIAlertController(title: "No Internet Connection", message: "An internet connection is required to use this app. Please connect to the internet and try again.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func enableBanner() {
        setupBanner()
    }
    
    func removeBanner () {
        if bannerView != nil {
            bannerView.isHidden = true
        }
    }
    
    func setupMenu () {
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        rateButton.setTitle("NEW", for: UIControlState.normal)
        rateButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15.5)
        rateButton.setTitleColor(UIColor(white:0.13, alpha:1.0), for: .normal)
        rateButton.backgroundColor = UIColor.white
        rateButton.layer.cornerRadius = 26
        rateButton.frame = CGRect(x: width/2-60, y: height-114, width: 120, height: 54)
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
    
    }
    
    func setupBanner () {
        
        bannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        bannerView.frame = CGRect(x:0.0,
                                  y:self.view.frame.size.height - bannerView.frame.size.height,
                                  width:bannerView.frame.size.width,
                                  height:bannerView.frame.size.height)
        bannerView.delegate = self
        self.view.addSubview(bannerView)
        bannerView.adUnitID = "ca-app-pub-2441744724896180/1511033317"
        bannerView.rootViewController = self
        initAd()
        
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
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Category") as! CategoryViewController
        present(popupVC, animated: true, completion: nil)
        
        return
        rateButton.alpha = 1.0
        let storeProductVC = SKStoreProductViewController()
        storeProductVC.delegate = self
        storeProductVC.loadProduct(withParameters: [SKStoreProductParameterITunesItemIdentifier : NSNumber(value: 1306304549)])
        self.present(storeProductVC, animated: true, completion: nil)
    }
    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func refreshContent() {
        
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
                statusBarView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 40))
            default:
                break
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
        
        if cell.viewWithTag(99) == nil {
            let spinnerFrame = CGRect(x: cell.frame.size.width/2-12, y: cell.frame.size.height/2-12, width: 24, height: 24)
            let spinner = NVActivityIndicatorView(frame: spinnerFrame, type: NVActivityIndicatorType.ballScale, color: UIColor.lightGray, padding:nil)
            spinner.tag = 99
            spinner.startAnimating()
            cell.addSubview(spinner)
        }
    
        let object = self.localContentArray[indexPath.row] as? PFObject
        let imageFile = object!["contentFile"] as! PFFile
        let imageUrl = imageFile.url
        let url = URL(string: imageUrl!)
        cell.imageView.sd_setImage(with: url!, placeholderImage: nil,options: [.continueInBackground], completed: { (image, error, cacheType, imageURL) in
            // Perform operation.
            cell.imageView.alpha = 0
            if let spin = cell.viewWithTag(99) {
                let spinner = spin as! NVActivityIndicatorView
                spinner.stopAnimating()
                spinner.removeFromSuperview()
                spinner.isHidden = true
                UIView.animate(withDuration: 0.15, animations: {
                    spinner.stopAnimating()
                    spinner.removeFromSuperview()
                    spinner.isHidden = true
                })
            }
            cell.imageView.alpha = 1
        })
        
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

        if CategoryManager.Instance.currentCategory != "NEW" {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
            return footerView
        }
        let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Footer", for: indexPath)
        footerView.backgroundColor = UIColor.black
        let label = UILabel()
        label.frame = footerView.frame
        label.textAlignment = .center
        label.textColor = UIColor.lightGray
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "New wallpapers every day.\nSee you tomorrow ✌🏼"
        label.numberOfLines = 2
        label.alpha = 0.0
        footerView.addSubview(label)
        UIView.animate(withDuration: 0.15, delay: 1, options: [], animations: {
            label.alpha = 1.0
        }) { (success) in
            
        }
        return footerView

    }
    
    @objc func registerForPush () {
        print("dope")
    }
    
    func retrieveContent () {
        let loader = LoadingView()
        loader.frame = view.frame
        self.view.addSubview(loader)
        loader.show()
        let query = PFQuery(className:"Content")
        if CategoryManager.Instance.currentCategory! == "NEW" {
        } else {
            query.whereKey("mainCategory", equalTo: CategoryManager.Instance.currentCategory!.lowercased())
        }
        query.whereKey("isVisible", equalTo:true)
        query.order(byDescending: "createdAt")
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                loader.dismiss()
                if self.localContentArray.count > 0 {
                    self.localContentArray.removeAllObjects()
                }
                if let objects = objects {
                    for object in objects {
                        self.localContentArray.add(object)
                    }
                }
                self.collectionView?.reloadData()
                self.downloadAllImages()
                self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.5)
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .top,
                                                  animated: true)
            } else {
                loader.dismiss()
                print("Error: \(error!) ")
                self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.5)
            }
        }
    }
    
    func downloadAllImages () {
        
        for object in localContentArray {
            let dasObject = object as! PFObject
            let imageFile = dasObject["contentFile"] as! PFFile
            let imageUrl = imageFile.url
            let url = URL(string: imageUrl!)
            let imageManager = SDWebImageManager.shared()
            imageManager.imageDownloader?.downloadImage(with: url, options: [], progress: nil, completed: { (image, data, error, success) in
            })
        }
    }
    
    @objc func endRefreshing () {
        self.refresher.endRefreshing()
    }

}
