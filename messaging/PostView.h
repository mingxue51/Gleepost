//
//  PostView.h
//  Gleepost
//
//  Created by Σιλουανός on 3/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface PostView : UIView
//@property (strong, nonatomic) IBOutlet UIImageView *userImage;

@property (strong, nonatomic) IBOutlet UIButton *userImage;
@property (strong, nonatomic) IBOutlet UILabel *userName;
@property (strong, nonatomic) IBOutlet UILabel *postTime;
@property (strong, nonatomic) IBOutlet UILabel *content;
@property (strong, nonatomic) IBOutlet UIImageView *mainImage;

@property (strong, nonatomic) IBOutlet UILabel *information;

@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *shareButton;

@property (retain, nonatomic) UIImageView *socialPanel;





-(void) initialiseElementsWithPost:(Post*) incomingPost;

@end