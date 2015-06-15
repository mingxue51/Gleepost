//
//  GLPTimestampMessageLabel.swift
//  Gleepost
//
//  Created by Silouanos on 15/06/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  Class that is used to represent the timestamp in GLPMessageCell.

import UIKit

class GLPTimestampMessageLabel: UILabel
{
    
    private lazy var dateFormatter: NSDateFormatter = {
       
        let dateFrormatter = NSDateFormatter()
        dateFrormatter.locale = NSLocale.currentLocale()
        dateFrormatter.doesRelativeDateFormatting = true
        return dateFrormatter
        
    }()
    
    private lazy var dateTextAttributes: Dictionary<String, AnyObject> = {
       
        var dictionary = Dictionary<String, AnyObject>()
        dictionary[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 10.0)!
        dictionary[NSForegroundColorAttributeName] = self.textColour
        dictionary[NSParagraphStyleAttributeName] = self.paragraphStyle
        return dictionary
        
    }()
    
    private lazy var timeTextAttributes: Dictionary<String, AnyObject> = {
        
        var dictionary = Dictionary<String, AnyObject>()
        dictionary[NSFontAttributeName] = UIFont(name: "HelveticaNeue", size: 10.0)
        dictionary[NSForegroundColorAttributeName] = self.textColour
        dictionary[NSParagraphStyleAttributeName] = self.paragraphStyle
        return dictionary
    }()
    
    private lazy var textColour: UIColor = {
        return UIColor.lightGrayColor()
    }()
    
    private lazy var paragraphStyle: NSParagraphStyle = {
       
        var paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        return paragraphStyle
        
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureLabel()
    }
    
    override func awakeFromNib() {
        
        println("GLPTimestampMessageLabel awakeFromNib")
        super.awakeFromNib()
    }
    
    private func configureLabel()
    {
        self.userInteractionEnabled = false
        self.textAlignment = .Center
    }
    
    func setDate(date: NSDate)
    {
        let datePart = formatDate(date, forDate: true)
        let timePart = formatDate(date, forDate: false)
        
        var timestamp = NSMutableAttributedString(string: datePart, attributes: self.dateTextAttributes)
        timestamp.appendAttributedString(NSAttributedString(string: " "))
        timestamp.appendAttributedString(NSAttributedString(string: timePart, attributes: self.timeTextAttributes))
        
        self.attributedText = timestamp
    }
    
    


    //MARK: - Date formatters
    
    private func formatDate(date: NSDate, forDate: Bool) -> String
    {
        self.dateFormatter.dateStyle = forDate ? .MediumStyle : .NoStyle
        self.dateFormatter.timeStyle = forDate ? .NoStyle : .ShortStyle
        return self.dateFormatter.stringFromDate(date)
    }
    

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
