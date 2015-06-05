//
//  GLPMutipleImagesActionCell.swift
//  Gleepost
//
//  Created by Silouanos on 04/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

import UIKit

class GLPMultipleImagesActionCell: UITableViewCell {
    
//    @IBOutlet weak var cameraRollButton!
//    @IBOutlet weak var captureButton!
//    @IBOutlet weak var captureButton!
    
    @IBOutlet var buttons: [UIButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setData(multipleImagesData: GLPMultipleImagesAction)
    {
        for index in 0...buttons.count - 1
        {
            let button = buttons[index]
            button.setImage(UIImage(named: multipleImagesData.array[index]), forState: UIControlState.Normal)
        }
        
    }
    
    
    // MARK: - Selectors
    
    @IBAction func captureImage(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(SwiftConstants.GLPNOTIFICATION_SHOW_CAPTURE_VIEW, object: self)
    }
    
    @IBAction func goToCameraRoll(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(SwiftConstants.GLPNOTIFICATION_SHOW_IMAGE_PICKER, object: self)
    }
    
    @IBAction func searchForImage(sender: AnyObject) {
        NSNotificationCenter.defaultCenter().postNotificationName(SwiftConstants.GLPNOTIFICATION_SHOW_PICK_IMAGE_FROM_WEB, object: self)
    }
    
    
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
