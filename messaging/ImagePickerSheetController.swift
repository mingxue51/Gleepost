//
//  ImagePickerController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation
import Photos

@objc protocol ImagePickerSheetControllerDelegate
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


@objc public class ImagePickerSheetController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIViewControllerTransitioningDelegate {
    
    // TODO: not used for now.
    private var lastCollectionViewSection = 0
    
    var delegate: ImagePickerSheetControllerDelegate?

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.alwaysBounceVertical = false
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.registerClass(ImagePreviewTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ImagePreviewTableViewCell.self))
        
        //Register cells depending on actions.
        for action in self.actions
        {
            let nib = UINib(nibName: action.cellName(), bundle: nil)
            tableView.registerNib(nib, forCellReuseIdentifier: action.cellName())
        }
        
        return tableView
    }()
    
    private lazy var collectionView: ImagePickerCollectionView = {
        let collectionView = ImagePickerCollectionView()
        collectionView.backgroundColor = .clearColor()
        collectionView.imagePreviewLayout.sectionInset = UIEdgeInsetsMake(collectionViewInset, collectionViewInset, collectionViewInset, collectionViewInset)
        collectionView.imagePreviewLayout.showsSupplementaryViews = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self))
        collectionView.registerClass(PreviewSupplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(PreviewSupplementaryView.self))
        
        return collectionView
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
    private var assets = [PHAsset]()
    private var selectedPhotoIndices = [Int]()
    private(set) var enlargedPreviews = false
    
    private var supplementaryViews = [Int: PreviewSupplementaryView]()
    
    private let imageManager = PHCachingImageManager()
    
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
        view.addSubview(tableView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchAssets()
        configureNotifications()
    }
    
    public override func viewWillDisappear(animated: Bool) {
        self.removeNotifications()
        super.viewWillDisappear(animated)
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return actions.count
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if assets.count > 0 {
                return enlargedPreviews ? tableViewEnlargedPreviewRowHeight : tableViewPreviewRowHeight
            }
            
            return 0
        }
        
        return tableViewRowHeight
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ImagePreviewTableViewCell.self), forIndexPath: indexPath) as! ImagePreviewTableViewCell
            cell.collectionView = collectionView
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            
            return cell
        }
        
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
    
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let action = actions[indexPath.row]
        
        switch action.imageActionStyle
        {
        case .PickLocation:
            self.sendLocation()
            self.cancel()
        case .SendImage:
            self.sendImages()
            self.cancel()
        case .BackToOptions:
            self.goBackToInitialView(indexPath)
        
        default:
            self.cancel()
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return assets.count + 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ImageCollectionViewCell.self), forIndexPath: indexPath) as! ImageCollectionViewCell
        
        if indexPath.section == self.assets.count
        {
            cell.imageView.image = UIImage(named: "add_image_to_the_end")
            return cell
        }
        
        let asset = assets[indexPath.section]
        let size = sizeForAsset(asset)
        
        requestImageForAsset(asset, size: size) { image in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
            
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(PreviewSupplementaryView.self), forIndexPath: indexPath) as! PreviewSupplementaryView
        view.userInteractionEnabled = false
        view.buttonInset = UIEdgeInsetsMake(0.0, collectionViewCheckmarkInset, collectionViewCheckmarkInset, 0.0)
        view.selected = contains(selectedPhotoIndices, indexPath.section)
        
        supplementaryViews[indexPath.section] = view
        
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if indexPath.section == self.assets.count
        {
            let asset = assets[indexPath.section - 1]
            return sizeForAsset(asset)
        }
        
        let asset = assets[indexPath.section]
        
        return sizeForAsset(asset)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let inset = 2.0 * collectionViewCheckmarkInset
        let size = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: section))
        let imageWidth = PreviewSupplementaryView.checkmarkImage?.size.width ?? 0
        return CGSizeMake(imageWidth  + inset, size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        let nextIndex = indexPath.row+1
        if nextIndex < assets.count {
            let asset = assets[nextIndex]
            let size = sizeForAsset(asset)
            
            self.prefetchImagesForAsset(asset, size: size)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == self.assets.count
        {
            NSNotificationCenter.defaultCenter().postNotificationName(SwiftConstants.GLPNOTIFICATION_SHOW_IMAGE_PICKER, object: self)
            return
        }
        
        let selected = contains(selectedPhotoIndices, indexPath.section)
        
        if !selected {
            selectedPhotoIndices.append(indexPath.section)
            
            self.updateImageCounterCell()
            
            if !enlargedPreviews {
                enlargedPreviews = true
                
                //Add secondary image actions in actions array.
                self.switchImageActions(applyInitialActions: false)
                self.collectionView.imagePreviewLayout.invalidationCenteredIndexPath = indexPath
                
                view.setNeedsLayout()
                UIView.animateWithDuration(enlargementAnimationDuration, animations: {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.reloadButtonTitles()
                    self.collectionView.imagePreviewLayout.showsSupplementaryViews = true
                })
            }
            else {
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                    var contentOffset = CGPointMake(cell.frame.midX - collectionView.frame.width / 2.0, 0.0)
                    contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                    contentOffset.x = min(contentOffset.x, collectionView.contentSize.width - collectionView.frame.width + collectionView.contentInset.right)
                    
                    collectionView.setContentOffset(contentOffset, animated: true)
                }
                self.updateImageCounterCell()
                reloadButtonTitles()
            }
        }
        else {
            selectedPhotoIndices.removeAtIndex(find(selectedPhotoIndices, indexPath.section)!)
            self.updateImageCounterCell()
            reloadButtonTitles()
        }
        
        
        if let sectionView = supplementaryViews[indexPath.section] {
            sectionView.selected = !selected
        }
    }
    
    // MARK: - Action options
    
    private func goBackToInitialView(indexPath: NSIndexPath)
    {
        self.selectedPhotoIndices.removeAll(keepCapacity: false)
        self.updateImageCounterCell()

        self.enlargedPreviews = false
        self.switchImageActions(applyInitialActions: true)
        
        self.collectionView.imagePreviewLayout.invalidationCenteredIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        view.setNeedsLayout()
        UIView.animateWithDuration(enlargementAnimationDuration, animations: {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            self.collectionView.imagePreviewLayout.showsSupplementaryViews = false
            self.view.layoutIfNeeded()
            }, completion: { finished in
                self.reloadButtonTitles()
        })
    }
    
    private func sendLocation()
    {
        
    }
    
    private func sendImages()
    {
        var images = [UIImage?]()
        var counter = selectedPhotoIndices.count
        
        for index in selectedPhotoIndices {
            let asset = assets[index]
            
            requestImageForAsset(asset, deliveryMode: .HighQualityFormat) { image in
                images.append(image)
                counter--
                if counter <= 0 {
                    println("ImagePickerSheetController sendImages \(images.count)")
                }
            }
        }
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
    
    private func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        
        result .enumerateObjectsUsingBlock { (obj, _, _) -> Void in
            
            if let asset = obj as? PHAsset where self.assets.count < assetsMaxNumber
            {
                self.assets.append(asset)
            }
        }
    }
    
    private func requestImageForAsset(asset: PHAsset, size: CGSize? = nil, deliveryMode: PHImageRequestOptionsDeliveryMode = .Opportunistic, completion: (image: UIImage?) -> Void) {
        var targetSize = PHImageManagerMaximumSize
        if let size = size {
            targetSize = targetSizeForAssetOfSize(size)
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode;
        
        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
        if asset.representsBurst {
            imageManager.requestImageDataForAsset(asset, options: options) { data, _, _, _ in
                let image = UIImage(data: data)
                completion(image: image)
            }
        }
        else {
            imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options) { image, _ in
                completion(image: image)
            }
        }
    }
    
    private func prefetchImagesForAsset(asset: PHAsset, size: CGSize) {
        // Not necessary to cache image because PHImageManager won't return burst images
        if !asset.representsBurst {
            let targetSize = targetSizeForAssetOfSize(size)
            imageManager.startCachingImagesForAssets([asset], targetSize: targetSize, contentMode: .AspectFill, options: nil)
        }
    }
    
    public func getSelectedImagesWithCompletion(completion: (images:[UIImage?]) -> Void) {
        var images = [UIImage?]()
        var counter = selectedPhotoIndices.count
        
        for index in selectedPhotoIndices {
            let asset = assets[index]
            
            requestImageForAsset(asset, deliveryMode: .HighQualityFormat) { image in
                images.append(image)
                counter--
                
                if counter <= 0 {
                    completion(images: images)
                }
            }
        }
    }
    
    // MARK: - Buttons
    
    private func reloadButtonTitles() {
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
    @objc private func cancel() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: { () -> Void in
            
            println("ImagePickerSheetController canceled")

        })
        
//        let cancelActions = actions.filter { $0.style == ImageActionStyle.Cancel }
//        if let cancelAction = cancelActions.first {
//            cancelAction.handle(numberOfPhotos: selectedPhotoIndices.count)
//        }
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
        
        let tableViewHeight = Array(0..<tableView.numberOfRowsInSection(1)).reduce(tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))) { total, row in
            total + tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 1))
        }

        tableView.frame = CGRect(x: view.bounds.minX, y: view.bounds.maxY-tableViewHeight, width: view.bounds.width, height: tableViewHeight)
    }
    
    // MARK: - Transitioning
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: false)
    }
    
}
