
//
//  ImageSelectorPreviewController.swift
//  CMBMobile
//
//  Created by Luo on 5/11/16.
//  Copyright © 2016 Yst－WHB. All rights reserved.
//
import UIKit
import AVFoundation

class MTImagePickerPreviewController:UIViewController,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource {
    
    var dataSource:[MTImagePickerModel]!
    var selectedSource:Set<MTImagePickerModel>!
    var initialIndexPath:NSIndexPath?
    var maxCount:Int!
    var dismiss:((Set<MTImagePickerModel>) -> Void)?
    
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var lbSelected: UILabel!
    private var initialScrollDone = false
    
    class var instance:MTImagePickerPreviewController {
        get {
            let storyboard = UIStoryboard(name: "MTImagePicker", bundle: NSBundle.mainBundle())
            let vc = storyboard.instantiateViewControllerWithIdentifier("MTImagePickerPreviewController") as! MTImagePickerPreviewController
            return vc
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lbSelected.text = String(self.selectedSource.count)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        self.scrollViewDidEndDecelerating(self.collectionView)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.initialScrollDone {
            self.initialScrollDone = true
            if let initialIndexPath = self.initialIndexPath {
                self.collectionView.scrollToItemAtIndexPath(initialIndexPath , atScrollPosition: .None, animated: false)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let model = self.dataSource[indexPath.row]
        self.btnCheck.selected = self.selectedSource.contains(model)
        if model.mediaType == .Photo {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("ImageCell", forIndexPath: indexPath) as! ImagePickerPreviewCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.mainScreen().scale
            cell.initWithModel(model, controller: self)
            return cell
        } else {
            let cell = self.collectionView.dequeueReusableCellWithReuseIdentifier("VideoCell", forIndexPath: indexPath) as! VideoPickerPreviewCell
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.mainScreen().scale
            cell.initWithModel(model,controller:self)
            return cell
        } 
    }
    
    // 旋转处理
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if self.view.bounds.size != size {
            self.collectionView.collectionViewLayout.invalidateLayout()
            if let videoCell = self.collectionView.visibleCells().first as? VideoPickerPreviewCell {
                coordinator.animateAlongsideTransition({ (_) in
                    // CALayer 无法autolayout 需要重设frame
                    videoCell.resetLayer()
                }, completion: nil)
            }
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(self.collectionView.bounds.width, self.collectionView.bounds.height);
    }
    
    //MARK:UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if let videoCell = self.collectionView.visibleCells().first as? VideoPickerPreviewCell {
            videoCell.didScroll()
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let cell = self.collectionView.visibleCells().first
        if let videoCell = cell as? VideoPickerPreviewCell {
            videoCell.didEndScroll()
        } else if let imageCell = cell as? ImagePickerPreviewCell {
            imageCell.didEndScroll()
        }
    }
    
    @IBAction func btnBackTouch(sender: AnyObject) {
        self.dismiss?(self.selectedSource)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func btnCheckTouch(sender: UIButton) {
        if self.selectedSource.count < self.maxCount || sender.selected == true {
            sender.selected = !sender.selected
            if let indexPath = self.collectionView.indexPathsForVisibleItems().first {
                let model = self.dataSource[indexPath.row]
                if sender.selected {
                    self.selectedSource.insert(model)
                    sender.heartbeatsAnimation(0.15)
                }else {
                    self.selectedSource.remove(model)
                }
                self.lbSelected.text = String(self.selectedSource.count)
                self.lbSelected.heartbeatsAnimation(0.15)
            }
        } else {
            let alertView = FlashAlertView(message: "Maxium selected".localized, delegate: nil)
            alertView.show()
        }
    }
}

