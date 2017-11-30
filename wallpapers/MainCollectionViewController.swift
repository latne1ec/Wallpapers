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

class MainCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, GADBannerViewDelegate, SKStoreProductViewControllerDelegate, UserDelegate, AdManagerDelegate, CategoryManagerDelegate, UIViewControllerPreviewingDelegate {

    var statusBarView: UIView?
    var localContentArray = NSMutableArray()
    var refresher:UIRefreshControl!
    var refresherNew: NVActivityIndicatorView!
    var pullingToRefresh: Bool?
    var categoryButton = UIButton()
    var removeAdsButton = UIButton()
    var settingsButton = UIButton()
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
        User.Instance.delegate = self
        AdManager.Instance.delegate = self
        CategoryManager.Instance.delegate = self
        pullingToRefresh = false
        
        let userIsProMember = UserDefaults.standard.bool(forKey: "promember")
        if userIsProMember == true {
        } else {
            if PFUser.current() != nil {
                /// && PFUser.current()?.object(forKey: "runCount") as! Int > 1
                //self.perform(#selector(showPro), with: nil, afterDelay: 0.75)
            }
        }
        
        //registerForPreviewing(with: self, sourceView: view)
    }
    
    @objc func showPro () {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Pro") as! PopupViewController
        popupVC.popupImage = UIImage(named: "Screenshot1.6.jpg")
        popupVC.homeVC = self
        present(popupVC, animated: true, completion: nil)
    }
    
    func categoryChanged() {
        categoryButton.setTitle(CategoryManager.Instance.currentCategory, for: .normal)
        
        if let category = CategoryManager.Instance.currentCategory {
            switch category {
            case "ARCHITECTURE":
                categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 8)
            case "NEW":
                categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            case "ART":
                categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
            case "CITY":
                categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.5)
            case "FLOWERS":
                categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 11.5)
            case "NATURE", "OCEAN", "SPACE", "TRAVEL":
                categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12)
            default:
                 categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 12.5)
            }
        }
        retrieveContent()
        pullingToRefresh = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        checkInternetConnection()
        print(PushManager.Instance)
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
        
        categoryButton.setTitle("NEW", for: UIControlState.normal)
        categoryButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        categoryButton.titleLabel?.minimumScaleFactor = 0.5
        categoryButton.titleLabel?.adjustsFontSizeToFitWidth = true
        categoryButton.setTitleColor(UIColor(white:0.13, alpha:1.0), for: .normal)
        categoryButton.backgroundColor = UIColor.white
        //categoryButton.layer.cornerRadius = 26
        //categoryButton.frame = CGRect(x: width/2-60, y: height-114, width: 120, height: 54)
        categoryButton.layer.cornerRadius = 40
        categoryButton.frame = CGRect(x: width/2-40, y: height-134, width: 80, height: 80)
        categoryButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.70).cgColor
        categoryButton.layer.shadowOpacity = 1.0
        categoryButton.layer.shadowRadius = 9.0
        categoryButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        categoryButton.addBorder()
        self.view.addSubview(categoryButton)
        self.view.bringSubview(toFront: categoryButton)
        categoryButton.addTarget(self, action: #selector(selectCategory), for: UIControlEvents.touchUpInside)
        categoryButton.addTarget(self, action: #selector(lowerAlpha), for: UIControlEvents.touchDown)
        categoryButton.addTarget(self, action: #selector(heightenAlpha), for: .touchDragExit)
        categoryButton.addTarget(self, action: #selector(heightenAlpha), for: .touchCancel)
        categoryButton.addBounce()
        
        settingsButton.setImage(UIImage(named: "settingsButton"), for: .normal)
        settingsButton.imageView?.contentMode = .scaleAspectFit
        settingsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        //settingsButton.setTitleColor(UIColor.darkText, for: .normal)
        settingsButton.backgroundColor = UIColor.white
        settingsButton.layer.cornerRadius = 26
        settingsButton.frame = CGRect(x: width/2-110, y: height-110, width: 54, height: 54)
        settingsButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        settingsButton.layer.shadowOpacity = 1.0
        settingsButton.layer.shadowRadius = 8.0
        settingsButton.addBorder()
        settingsButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        settingsButton.addTarget(self, action: #selector(rateButtonTapped(sender:)), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(lowerAlpha), for: .touchDown)
        settingsButton.addTarget(self, action: #selector(heightenAlpha), for: .touchDragExit)
        self.view.addSubview(settingsButton)
        self.view.bringSubview(toFront: settingsButton)
        settingsButton.addBounce()
        
        removeAdsButton.setImage(UIImage(named: "noads"), for: .normal)
        removeAdsButton.imageView?.contentMode = .scaleAspectFit
        removeAdsButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        //removeAdsButton.setTitleColor(UIColor.darkText, for: .normal)
        removeAdsButton.backgroundColor = UIColor.white
        removeAdsButton.layer.cornerRadius = 26
        removeAdsButton.frame = CGRect(x: width/2+55, y: height-110, width: 54, height: 54)
        removeAdsButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        removeAdsButton.layer.shadowOpacity = 1.0
        removeAdsButton.layer.shadowRadius = 8.0
        removeAdsButton.addBorder()
        removeAdsButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        removeAdsButton.addTarget(self, action: #selector(makePurchase), for: .touchUpInside)
        removeAdsButton.addTarget(self, action: #selector(lowerAlpha), for: .touchDown)
        removeAdsButton.addTarget(self, action: #selector(heightenAlpha), for: .touchDragExit)
        //removeAdsButton.addRedDot()
        self.view.addSubview(removeAdsButton)
        self.view.bringSubview(toFront: removeAdsButton)
        removeAdsButton.addBounce()
    
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
    
    @objc func heightenAlpha (sender: UIButton) {
        sender.alpha = 1.0
    }
    
    @objc func lowerAlpha (sender: UIButton) {
        sender.alpha = 0.5
    }
    
    @objc func selectCategory (sender: UIButton) {
        sender.alpha = 1.0
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Category") as! CategoryViewController
        present(popupVC, animated: false, completion: nil)
    }
    
    @objc func rateButtonTapped (sender: UIButton) {
        sender.alpha = 1.0
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
        present(popupVC, animated: true, completion: nil)
    }
    
    @objc func removeAdsButtonTapped (sender: UIButton) {
        sender.alpha = 1.0
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Pro") as! PopupViewController
        popupVC.popupImage = UIImage(named: "Screenshot1.6.jpg")
        popupVC.homeVC = self
        present(popupVC, animated: true, completion: nil)
    }

    
    func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func refreshContent() {
        pullingToRefresh = true
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
        if self.localContentArray.count > 0 {
            return self.localContentArray.count
        } else {
            return 0
        }
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
    
        if let object = self.localContentArray[indexPath.row] as? PFObject {
            let imageFile = object["contentFile"] as! PFFile
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
        }
        
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
    
    //3D Touch - Peek
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        guard let indexPath = collectionView?.indexPathForItem(at: location),
            let cell = collectionView?.cellForItem(at: indexPath) as? MainCollectionViewCell
            else {
                return nil
        }
        let imageInfo   = GSImageInfo(image: cell.imageView.image!, imageMode: .aspectFill)
        let transitionInfo = GSTransitionInfo(fromView:(cell.imageView))
        let imageViewer = DetailViewController(imageInfo: imageInfo, transitionInfo: transitionInfo)
        //present(imageViewer, animated: true, completion: nil)
        
        //WHAT I PUT HERE TO SHOW MY DETAILVIEW DATA?
        
        if #available(iOS 9.0, *) {
            previewingContext.sourceRect = cell.frame
        } else {
            // Fallback on earlier versions
        }
        
        return imageViewer
    }
    
    //3D Touch - Pop
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        self.show(viewControllerToCommit, sender: self)
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
    
    func retrieveContent () {
        let loader = LoadingView()
        loader.frame = view.frame
        self.view.addSubview(loader)
        if pullingToRefresh == true {
        } else {
            loader.show()
        }
        let query = PFQuery(className:"Content")
        if CategoryManager.Instance.currentCategory! == "NEW" {
        } else {
            query.whereKey("mainCategory", equalTo: CategoryManager.Instance.currentCategory!.lowercased())
        }
        query.whereKey("isVisible", equalTo:true)
        query.order(byDescending: "createdAt")
        query.limit = 500
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                if self.pullingToRefresh == false {
                    loader.dismiss()
                }
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
                if self.localContentArray.count == 0 {
                    return
                }
                self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.5)
                self.collectionView?.setContentOffset(.zero, animated: true)
                self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                                  at: .top,
                                                  animated: true)
            } else {
                if self.pullingToRefresh == false {
                    loader.dismiss()
                }
                print("Error: \(error!) ")
                self.perform(#selector(self.endRefreshing), with: nil, afterDelay: 0.5)
            }
        }
    }
    
    func downloadAllImages () {
        if localContentArray.count == 0 {
            return
        }
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
        self.collectionView?.setContentOffset(.zero, animated: true)
        self.collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0),
                                          at: .top,
                                          animated: true)
    }
    
    @objc func makePurchase (sender: UIButton) {
        sender.alpha = 1.0
        let loader = LoadingView()
        loader.frame = view.frame
        self.view.addSubview(loader)
        loader.show()
        SwiftyStoreKit.purchaseProduct("com.teamlevellabs.hdwallpapers.removeads", completion: {
            result in
            print(result)
            switch result {
            case .success:
                User.Instance.setUserAsProMember()
                self.removeBanner()
                let ac = UIAlertController(title: "Success!", message: "You have successfully removed all ads from HD Wallpapers™", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                    UIAlertAction in
                }
                ac.addAction(okAction)
                self.present(ac, animated: true)
            case .error:
                let ac = UIAlertController(title: "Error", message: "An error occured while attempting to complete your purchase. Please try again.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
            loader.dismiss()
            loader.removeFromSuperview()
        })
    }

}

extension UIButton {
    func addRedDot () {
        let redDot = UIView()
        redDot.backgroundColor = UIColor.red
        redDot.frame = CGRect(x: self.bounds.midX, y: self.bounds.midY+15, width: 4, height: 4)
        redDot.layer.cornerRadius = 2
        self.addSubview(redDot)
    }
    
    func addBounce() {
        self.addTarget(self, action: #selector(test), for: .touchDown)
        self.addTarget(self, action: #selector(test2), for: .touchUpInside)
        self.addTarget(self, action: #selector(test2), for: .touchDragExit)
    }
    
    @objc func test () {
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform(scaleX: 0.98, y: 0.98)
        }
    }
    @objc func test2 () {
        UIView.animate(withDuration: 0.05) {
            self.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
    }
    
    func addBorder () {
        // Not using
        //self.layer.borderColor = UIColor.lightGray.cgColor
        //self.layer.borderWidth = 0.5
    }
}
