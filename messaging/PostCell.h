//
//  PostCell.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PostCell : UITableViewCell

@property (retain, nonatomic) UIImageView *userImage;
@property (retain, nonatomic) UITextView *userName;
@property (retain, nonatomic) UITextView *postTime;
@property (retain, nonatomic) UITextView *content;
@property (retain, nonatomic) UIImageView *mainImage;
@property (retain, nonatomic) UIImageView *socialPanel;


-(void) createElements;

@end
