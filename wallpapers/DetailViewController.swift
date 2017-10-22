//
//  GSImageViewerController.swift
//  GSImageViewerControllerExample
//
//  Created by Evan Latner on 15/12/22.
//  Copyright © 2015 Evan Latner. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PopupDialog

public struct GSImageInfo {
    
    public enum ImageMode : Int {
        case aspectFit  = 1
        case aspectFill = 2
    }
    
    public let image     : UIImage
    public let imageMode : ImageMode
    public var imageHD   : URL?
    
    public var contentMode : UIViewContentMode {
        return UIViewContentMode(rawValue: imageMode.rawValue)!
    }
    
    public init(image: UIImage, imageMode: ImageMode) {
        self.image     = image
        self.imageMode = imageMode
    }
    
    public init(image: UIImage, imageMode: ImageMode, imageHD: URL?) {
        self.init(image: image, imageMode: imageMode)
        self.imageHD = imageHD
    }
    
    func calculateRect(_ size: CGSize) -> CGRect {
        
        let widthRatio  = size.width  / image.size.width
        let heightRatio = size.height / image.size.height
        
        switch imageMode {
            
        case .aspectFit:
            
            return CGRect(origin: CGPoint.zero, size: size)
            
        case .aspectFill:
            
            return CGRect(
                x      : 0,
                y      : 0,
                width  : image.size.width  * max(widthRatio, heightRatio),
                height : image.size.height * max(widthRatio, heightRatio)
            )
            
        }
    }
    
    func calculateMaximumZoomScale(_ size: CGSize) -> CGFloat {
        return max(2, max(
            image.size.width  / size.width,
            image.size.height / size.height
        ))
    }
    
}

open class GSTransitionInfo {
    
    open var duration: TimeInterval = 0.125
    open var canSwipe: Bool           = true
    
    public init(fromView: UIView) {
        self.fromView = fromView
    }
    
    weak var fromView : UIView?
    
    fileprivate var convertedRect : CGRect?
    
}

open class DetailViewController: UIViewController, UIImagePickerControllerDelegate {
    
    open let imageInfo      : GSImageInfo
    open var transitionInfo : GSTransitionInfo?
    
    var statusBarHidden: Bool?
    var downloadButton = UIButton()
    
    fileprivate let imageView  = UIImageView()
    fileprivate let scrollView = UIScrollView()
    
    fileprivate lazy var session: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration, delegate: nil, delegateQueue: OperationQueue.main)
    }()
    
    // MARK: Initialization
    
    public init(imageInfo: GSImageInfo) {
        self.imageInfo = imageInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(imageInfo: GSImageInfo, transitionInfo: GSTransitionInfo) {
        self.init(imageInfo: imageInfo)
        self.transitionInfo = transitionInfo
        if let fromView = transitionInfo.fromView, let referenceView = fromView.superview {
            self.transitioningDelegate = self
            self.modalPresentationStyle = .custom
            transitionInfo.convertedRect = referenceView.convert(fromView.frame, to: nil)
        }
    }
    
    public convenience init(image: UIImage, imageMode: UIViewContentMode, imageHD: URL?, fromView: UIView?) {
        let imageInfo = GSImageInfo(image: image, imageMode: GSImageInfo.ImageMode(rawValue: imageMode.rawValue)!, imageHD: imageHD)
        if let fromView = fromView {
            self.init(imageInfo: imageInfo, transitionInfo: GSTransitionInfo(fromView: fromView))
        } else {
            self.init(imageInfo: imageInfo)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Override
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        setupScrollView()
        setupImageView()
        setupGesture()
        setupImageHD()
        self.statusBarHidden = true
        
        edgesForExtendedLayout = UIRectEdge()
        automaticallyAdjustsScrollViewInsets = false
        scrollView.delaysContentTouches = false
        
        self.perform(#selector(addSavebutton), with: nil, afterDelay: 0.2)
        
        self.perform(#selector(showInterstitial), with: nil, afterDelay: 0.1)
        
    }
    
    @objc func showInterstitial () {
        //AdManager.Instance.showInterstitial(fromVC: self)
        //AdManager.Instance.showApplovinAd()
//        if ALInterstitialAd.isReadyForDisplay() {
//            ALInterstitialAd.show()
//        } else {
//            print("not ready")
//        }
    }
    
    @objc func addSavebutton () {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        downloadButton.setTitle("SAVE WALLPAPER", for: UIControlState.normal)
        downloadButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        downloadButton.setTitleColor(UIColor(white:0.13, alpha:1.0), for: .normal)
        downloadButton.backgroundColor = UIColor.white
        downloadButton.layer.cornerRadius = 27
        downloadButton.frame = CGRect(x: width/4, y: height+120, width: width/2, height: 54)
        downloadButton.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        downloadButton.layer.shadowOpacity = 1.0
        downloadButton.layer.shadowRadius = 10.0
        downloadButton.layer.shadowOffset = CGSize(width: 0, height: 0)
        scrollView.addSubview(downloadButton)
        scrollView.bringSubview(toFront: downloadButton)
        downloadButton.addTarget(self, action: #selector(userRequestToSaveImage), for: .touchUpInside)
        downloadButton.addTarget(self, action: #selector(lowerAlpha), for: .touchDown)
        downloadButton.addTarget(self, action: #selector(heightenAlpha), for: .touchDragExit)
        downloadButton.addTarget(self, action: #selector(heightenAlpha), for: .touchCancel)
       
        UIView.animate(withDuration: 0.2, animations: {
            self.downloadButton.frame = CGRect(x: width/4, y: self.view.frame.size.height - 110, width: self.downloadButton.frame.size.width, height: 54)
        }) { (success) in
            UIView.animate(withDuration: 0.15, animations: {
                self.downloadButton.frame = CGRect(x: width/4, y: self.view.frame.size.height - 100, width: self.downloadButton.frame.size.width, height: 54)
            }) { (success) in
                
            }
        }
    }
    
    @objc func userRequestToSaveImage () {
        //User.Instance.checkIfProMember()
        // Show Popup if not a pro user
        let userIsProMember = UserDefaults.standard.bool(forKey: "promember")
        if userIsProMember == true {
            saveImage()
        } else {
            showPopup()
        }
    }
    
    @objc func lowerAlpha () {
        downloadButton.alpha = 0.7
    }
    @objc func heightenAlpha () {
        downloadButton.alpha = 1.0
    }
    
    @objc func saveImage () {
        
        UIGraphicsBeginImageContextWithOptions(imageView.frame.size, true, 2)
        guard let context = UIGraphicsGetCurrentContext() else { return }
        imageView.layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return }
        UIGraphicsEndImageContext()
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)

    }
    
    func showPopup () {
        // Prepare the popup assets
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let popupVC = storyboard.instantiateViewController(withIdentifier: "Popup") as! PopupViewController
        popupVC.popupImage = imageView.image
        popupVC.parentVC = self
        present(popupVC, animated: true, completion: nil)
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
            heightenAlpha()
        } else {
            let ac = UIAlertController(title: "Saved Wallpaper!", message: "Your wallpaper has been saved to your Photos app for use.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                ReviewController.Instance.requestReview()
            }
            //ac.addAction(UIAlertAction(title: "OK", style: .default))
            ac.addAction(okAction)
            present(ac, animated: true)
            heightenAlpha()
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        if AdManager.Instance.interstitialIsShowing == true {
            
        } else {
            UIApplication.shared.setStatusBarHidden(false, with: UIStatusBarAnimation.fade)
        }
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.none)
    }
    
    override open func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        imageView.frame = imageInfo.calculateRect(view.bounds.size)
        
        scrollView.frame = view.bounds
        scrollView.contentSize = imageView.bounds.size
        //scrollView.maximumZoomScale = imageInfo.calculateMaximumZoomScale(scrollView.bounds.size)
    }
    
    // MARK: Setups
    
    fileprivate func setupView() {
        view.backgroundColor = UIColor.black
    }
    
    fileprivate func setupScrollView() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        view.addSubview(scrollView)
    }
    
    fileprivate func setupImageView() {
        imageView.backgroundColor = UIColor.black
        imageView.image = imageInfo.image
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        scrollView.addSubview(imageView)
        //scrollView.layer.cornerRadius = 10
    }
    
    fileprivate func setupGesture() {
        let single = UITapGestureRecognizer(target: self, action: #selector(singleTap))
        let double = UITapGestureRecognizer(target: self, action: #selector(doubleTap(_:)))
        double.numberOfTapsRequired = 2
        single.require(toFail: double)
        scrollView.addGestureRecognizer(single)
        //scrollView.addGestureRecognizer(double)
        
        if transitionInfo?.canSwipe == true {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(pan(_:)))
            pan.delegate = self
            scrollView.addGestureRecognizer(pan)
        }
    }
    
    fileprivate func setupImageHD() {
        guard let imageHD = imageInfo.imageHD else { return }
        
        let request = URLRequest(url: imageHD, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            self.imageView.image = image
            self.view.layoutIfNeeded()
        })
        task.resume()
    }
    
    // MARK: Gesture
    
    @objc fileprivate func singleTap() {
        if navigationController == nil || (presentingViewController != nil && navigationController!.viewControllers.count <= 1) {
            //dismiss(animated: true, completion: nil)
        }
    }
    
    @objc fileprivate func doubleTap(_ gesture: UITapGestureRecognizer) {
        let point = gesture.location(in: scrollView)
        
        if scrollView.zoomScale == 1.0 {
            scrollView.zoom(to: CGRect(x: point.x-40, y: point.y-40, width: 80, height: 80), animated: true)
        } else {
            scrollView.setZoomScale(1.0, animated: true)
        }
    }
    
    fileprivate var panViewOrigin : CGPoint?
    fileprivate var panViewAlpha  : CGFloat = 1
    
    @objc fileprivate func pan(_ gesture: UIPanGestureRecognizer) {
        
        func getProgress() -> CGFloat {
            let origin = panViewOrigin!
            let changeX = abs(scrollView.center.x - origin.x)
            let changeY = abs(scrollView.center.y - origin.y)
            let progressX = changeX / view.bounds.width
            let progressY = changeY / view.bounds.height
            return max(progressX, progressY)
        }
        
        func getChanged() -> CGPoint {
            let origin = scrollView.center
            let change = gesture.translation(in: view)
            return CGPoint(x: origin.x + change.x, y: origin.y + change.y)
        }
        
        func getVelocity() -> CGFloat {
            let vel = gesture.velocity(in: scrollView)
            return sqrt(vel.x*vel.x + vel.y*vel.y)
        }
        
        switch gesture.state {
            
        case .began:
            
            panViewOrigin = scrollView.center
            
        case .changed:
            
            scrollView.center = getChanged()
            panViewAlpha = 1 - getProgress()
            view.backgroundColor = UIColor(white: 0.0, alpha: panViewAlpha)
            gesture.setTranslation(CGPoint.zero, in: nil)
            
        case .ended:
            
            if getProgress() > 0.2 || getVelocity() > 1000 {
                dismiss(animated: true, completion: nil)
            } else {
                fallthrough
            }
            
        default:
            
            UIView.animate(withDuration: 0.3,
                           animations: {
                            self.scrollView.center = self.panViewOrigin!
                            self.view.backgroundColor = UIColor(white: 0.0, alpha: 1.0)
            },
                           completion: { _ in
                            self.panViewOrigin = nil
                            self.panViewAlpha  = 1.0
            }
            )
            
        }
    }
    
}

extension DetailViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.frame = imageInfo.calculateRect(scrollView.contentSize)
    }
    
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GSImageViewerTransition(imageInfo: imageInfo, transitionInfo: transitionInfo!, transitionMode: .present)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return GSImageViewerTransition(imageInfo: imageInfo, transitionInfo: transitionInfo!, transitionMode: .dismiss)
    }
    
}

class GSImageViewerTransition: NSObject, UIViewControllerAnimatedTransitioning {
    
    let imageInfo      : GSImageInfo
    let transitionInfo : GSTransitionInfo
    var transitionMode : TransitionMode
    
    enum TransitionMode {
        case present
        case dismiss
    }
    
    init(imageInfo: GSImageInfo, transitionInfo: GSTransitionInfo, transitionMode: TransitionMode) {
        self.imageInfo = imageInfo
        self.transitionInfo = transitionInfo
        self.transitionMode = transitionMode
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionInfo.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView
        
        let tempMask = UIView()
        tempMask.backgroundColor = UIColor.black
        
        let tempImage = UIImageView(image: imageInfo.image)
        tempImage.layer.cornerRadius = transitionInfo.fromView!.layer.cornerRadius
        tempImage.layer.masksToBounds = true
        tempImage.contentMode = imageInfo.contentMode
        
        containerView.addSubview(tempMask)
        containerView.addSubview(tempImage)
        
        if transitionMode == .present {
            transitionInfo.fromView!.alpha = 0
            let imageViewer = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! DetailViewController
            imageViewer.view.layoutIfNeeded()
            
            tempMask.alpha = 0
            tempMask.frame = imageViewer.view.bounds
            tempMask.frame.size.width = tempMask.frame.size.width + 100
            tempImage.frame = transitionInfo.convertedRect!
            
            UIView.animate(withDuration: transitionInfo.duration,
                           animations: {
                            tempMask.alpha  = 1
                            tempImage.frame = imageViewer.imageView.frame
            },
                           completion: { _ in
                            tempMask.removeFromSuperview()
                            tempImage.removeFromSuperview()
                            containerView.addSubview(imageViewer.view)
                            transitionContext.completeTransition(true)
            }
            )
            
        }
        
        if transitionMode == .dismiss {
            
            let imageViewer = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! DetailViewController
            imageViewer.view.removeFromSuperview()
            
            tempMask.alpha = imageViewer.panViewAlpha
            tempMask.frame = imageViewer.view.bounds
            tempImage.frame = imageViewer.scrollView.frame
            
            UIView.animate(withDuration: transitionInfo.duration,
                           animations: {
                            tempMask.alpha  = 0
                            tempImage.frame = self.transitionInfo.convertedRect!
            },
                           completion: { _ in
                            tempMask.removeFromSuperview()
                            imageViewer.view.removeFromSuperview()
                            self.transitionInfo.fromView!.alpha = 1
                            transitionContext.completeTransition(true)
            }
            )
            
        }
        
    }
    
}

extension DetailViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            if scrollView.zoomScale != 1.0 {
                return false
            }
        }
        return true
    }
    
}

