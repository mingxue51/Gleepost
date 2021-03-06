//
//  GLPDefaultImageActionCell.swift
//  CustomImagePickerSheetController
//
//  Created by Silouanos on 02/06/15.
//  Copyright (c) 2015 Silouanos. All rights reserved.
//

import UIKit

class GLPDefaultImageActionCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    internal func setData(data: GLPDefaultImageAction)
    {
        self.titleLabel.text = data.title
        self.titleLabel.textColor = data.textColour
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
