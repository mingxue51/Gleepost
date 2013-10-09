//
//  PostView.h
//  Gleepost
//
//  Created by Σιλουανός on 3/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostView : UIView
@property (retain, nonatomic) UIImageView *userImage;
@property (retain, nonatomic) UITextView *userName;
@property (retain, nonatomic) UITextView *postTime;
@property (retain, nonatomic) UITextView *content;
@property (retain, nonatomic) UIImageView *mainImage;
@property (retain, nonatomic) UIImageView *socialPanel;
@end
