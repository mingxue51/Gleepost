//
//  UIPlaceHolderTextView.h
//  scores rhumatologie
//
//  Created by Lukas on 5/30/13.
//  Copyright (c) 2013 Siu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
