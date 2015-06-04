//
//  GLPMutipleImagesActionCell.swift
//  Gleepost
//
//  Created by Silouanos on 04/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

import UIKit

class GLPMultipleImagesActionCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    
    // MARK: - Selectors
    
    @IBAction func captureImage(sender: AnyObject) {
        
        println("GLPMutlipleImagesActionCell captureImage")
    }
    
    @IBAction func goToCameraRoll(sender: AnyObject) {
        
    }
    
    @IBAction func searchForImage(sender: AnyObject) {
        
    }
    
    
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
