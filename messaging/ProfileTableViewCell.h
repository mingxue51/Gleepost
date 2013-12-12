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

-(void)initialiseElementsWithUserDetails:(GLPUser *)user;
-(void)updateImageWithUrl:(NSString*)url;
-(void)setDelegate:(GLPProfileViewController *)delegate;
-(void)setPrivateProfileDelegate:(GLPPrivateProfileViewController*)delegate;

@end
