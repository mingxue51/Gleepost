//
//  ImagePickerController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation
import Photos

@objc protocol ImagePickerSheetiOS7ControllerDelegate
{
    func presentCameraView()
    func presentFullSizeImagePicker()
}

private let enlargementAnimationDuration = 0.3
private let tableViewRowHeight: CGFloat = 60.0
private let tableViewPreviewRowHeight: CGFloat = 140.0
private let tableViewEnlargedPreviewRowHeight: CGFloat = 243.0
private let collectionViewInset: CGFloat = 5.0
private let collectionViewCheckmarkInset: CGFloat = 3.5
private let assetsMaxNumber: Int = 20;


@objc public class ImagePickeriOS7SheetController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate {
    
    // TODO: not used for now.
    private var lastCollectionViewSection = 0
    
    var delegate: ImagePickerSheetiOS7ControllerDelegate?
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.alwaysBounceVertical = false
//        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        
        //Register cells depending on actions.
        for action in self.actions
        {
            let nib = UINib(nibName: action.cellName(), bundle: nil)
            tableView.registerNib(nib, forCellReuseIdentifier: action.cellName())
        }
        
        return tableView

        }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "cancel"))
        
        return view
        }()
    
    private(set) var actions = [GLPImageAction]()
    private(set) var initialActions = [GLPImageAction]()
    private(set) var secondaryActions = [GLPImageAction]()
    private var selectedPhotoIndices = [Int]()
    private(set) var enlargedPreviews = false
    
    private var supplementaryViews = [Int: PreviewSupplementaryView]()
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    private func configureNotifications()
    {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showFullSizeImagePicker"), name: SwiftConstants.GLPNOTIFICATION_SHOW_IMAGE_PICKER, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showCaptureImageView"), name: SwiftConstants.GLPNOTIFICATION_SHOW_CAPTURE_VIEW, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("showPickImageFromTheWeb"), name: SwiftConstants.GLPNOTIFICATION_SHOW_PICK_IMAGE_FROM_WEB, object: nil)
    }
    
    private func removeNotifications()
    {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SwiftConstants.GLPNOTIFICATION_SHOW_IMAGE_PICKER, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SwiftConstants.GLPNOTIFICATION_SHOW_CAPTURE_VIEW, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: SwiftConstants.GLPNOTIFICATION_SHOW_PICK_IMAGE_FROM_WEB, object: nil)
    }
    
    // MARK: - View Lifecycle
    
    override public func loadView() {
        super.loadView()
        
        view.addSubview(backgroundView)
        
        let tvFrame = tableView.frame
        
        println("Table view frame \(tvFrame.origin.x)")
        
        view.addSubview(tableView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        configureNotifications()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        self.removeNotifications()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return actions.count
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return tableViewRowHeight
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let action = actions[indexPath.row]
        
        if let imageDefaultAction = action as? GLPImageDefaultImageAction
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(imageDefaultAction.cellName(), forIndexPath: indexPath) as! GLPImageDefaultImageActionCell
            cell.setData(imageDefaultAction)
            return cell
        }
        else if let defaultAction = action as? GLPDefaultImageAction
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(defaultAction.cellName(), forIndexPath: indexPath) as! GLPDefaultImageActionCell
            cell.setData(defaultAction)
            return cell
        }
        else if let multipleImagesAction = action as? GLPMultipleImagesAction
        {
            let cell = tableView.dequeueReusableCellWithIdentifier(multipleImagesAction.cellName(), forIndexPath: indexPath) as! GLPMultipleImagesActionCell
            cell.setData(multipleImagesAction)
            return cell
        }
        
        return tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell.self), forIndexPath: indexPath) as! UITableViewCell
    }
    
    // MARK: - UITableViewDelegate
    
//    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return indexPath.section != 0
//    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let action = actions[indexPath.row]
        
        switch action.imageActionStyle
        {
        case .PickLocation:
            self.sendLocation()
            self.cancel()
        case .SendImage:
//            self.sendImages()
            self.cancel()
        case .BackToOptions:
            self.goBackToInitialView(indexPath)
            
        default:
            self.cancel()
        }
    }
    
    // MARK: - Action options
    
    private func goBackToInitialView(indexPath: NSIndexPath)
    {
        self.selectedPhotoIndices.removeAll(keepCapacity: false)
        self.updateImageCounterCell()
        
        self.enlargedPreviews = false
        self.switchImageActions(applyInitialActions: true)
    }
    
    private func sendLocation()
    {
        //Pending.
    }
    
    func showFullSizeImagePicker()
    {
        println("ImagePickerSheetController showFullSizeImagePicker")
        self.cancel { () -> Void in
            self.delegate!.presentFullSizeImagePicker()
        }
    }
    
    func showCaptureImageView()
    {
        println("ImagePickerSheetController showCaptureImageView")
        
        self.cancel { () -> Void in
            self.delegate!.presentCameraView()
        }
    }
    
    func showPickImageFromTheWeb()
    {
        println("ImagePickerSheetController showPickImageFromTheWeb")
    }
    
    // MARK: - Actions
    
    func addInitialAction(action: GLPImageAction) {
        //        let cancelActions = actions.filter { $0.style == ImageActionStyle.Cancel }
        //        if action.style == .Cancel && cancelActions.count > 0 {
        //            // precondition() would be more swifty here, but that's not really testable as of now
        //            NSException(name: NSInternalInconsistencyException, reason: "ImagePickerSheetController can only have one action with a style of .Cancel", userInfo: nil).raise()
        //        }
        
        initialActions.append(action)
        actions.append(action)
    }
    
    func addSecondaryAction(action: GLPImageAction)
    {
        secondaryActions.append(action)
    }
    
    /**
    Clears the actions array (if needed) and copies the new array
    depending on the initialActions variable.
    
    :param: applyInitialActions if true copies the initialActions array otherwise the secondaryActions.
    */
    private func switchImageActions(#applyInitialActions: Bool)
    {
        actions = applyInitialActions ? initialActions : secondaryActions
    }
    
    private func updateImageCounterCell()
    {
        if !self.enlargedPreviews
        {
            return
        }
        
        for imageAction in self.actions
        {
            if let defaultImageAction = imageAction as? GLPDefaultImageAction
            {
                defaultImageAction.increaseCount(selectedPhotoIndices.count == 0 ? 1 : selectedPhotoIndices.count)
            }
        }
        
        
    }
    
    // MARK: - Photos
    
    private func sizeForAsset(asset: PHAsset) -> CGSize {
        let proportion = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        
        let height: CGFloat = {
            let rowHeight = self.enlargedPreviews ? tableViewEnlargedPreviewRowHeight : tableViewPreviewRowHeight
            return rowHeight-2.0*collectionViewInset
            }()
        
        return CGSize(width: CGFloat(floorf(Float(proportion*height))), height: height)
    }
    
    private func targetSizeForAssetOfSize(size: CGSize) -> CGSize {
        let scale = UIScreen.mainScreen().scale
        return CGSize(width: scale*size.width, height: scale*size.height)
    }
    
    // MARK: - Buttons
    
    private func reloadButtonTitles() {
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
    @objc private func cancel() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            println("ImagePickerSheetController canceled")
            
        })
    }
    
    private func cancel(completion: () -> Void)
    {
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            println("ImagePickerSheetController canceled")
            completion()
        })
    }
    
    // MARK: - Layout
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        backgroundView.frame = view.bounds
        
        var tableViewHeight = Array(0..<tableView.numberOfRowsInSection(0)).reduce(tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))) { total, row in
            total + tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 0))
        }
        
        tableViewHeight -= tableViewRowHeight
        
        tableView.frame = CGRect(x: view.bounds.minX, y: view.bounds.maxY-tableViewHeight, width: view.bounds.width, height: tableViewHeight)
    }
    
    // MARK: - Transitioning
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationiOS7Controller(imagePickerSheetController: self, presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationiOS7Controller(imagePickerSheetController: self, presenting: false)
    }
    
}

