//
//  ProfileTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"
#import "GLPGroup.h"
#import "GLPConversation.h"


@class ProfileTableViewCell;

@protocol ProfileTableViewCellDelegate <NSObject>

@optional
-(void)changeProfileImage:(id)sender;
-(void)showInformationMenu:(id)sender;
-(void)showFullProfileImage:(id)sender;
-(void)unlockProfile;
-(void)viewConversation:(GLPConversation *)conversation;

@end


@interface ProfileTableViewCell : UITableViewCell

extern const float PROFILE_CELL_HEIGHT;



@property (assign, nonatomic) BOOL isBusy;


-(void)initialiseElementsWithUserDetails:(GLPUser *)user;
-(void)initialiseElementsWithUserDetails:(GLPUser *)user withImage:(UIImage*)image;
-(void)initialiseGroupImage:(UIImage *)image;
-(void)initialiseProfileImage:(UIImage*)image;
-(void)updateImageWithUrl:(NSString*)url;
-(void)setDelegate:(UIViewController <ProfileTableViewCellDelegate> *)delegate;
//-(void)setPrivateProfileDelegate:(GLPPrivateProfileViewController*)delegate;
-(void)initialiseElementsWithGroupInformation:(GLPGroup *)group withGroupImage:(UIImage *)image;

@end
