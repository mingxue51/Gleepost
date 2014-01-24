//
//  ProfileTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"
#import "GLPProfileViewController.h"
#import "GLPPrivateProfileViewController.h"

@interface ProfileTableViewCell : UITableViewCell

extern const float PROFILE_CELL_HEIGHT;



@property (assign, nonatomic) BOOL isBusy;


-(void)initialiseElementsWithUserDetails:(GLPUser *)user;
-(void)initialiseElementsWithUserDetails:(GLPUser *)user withImage:(UIImage*)image;
-(void)initialiseProfileImage:(UIImage*)image;
-(void)updateImageWithUrl:(NSString*)url;
-(void)setDelegate:(GLPProfileViewController *)delegate;
-(void)setPrivateProfileDelegate:(GLPPrivateProfileViewController*)delegate;

@end
