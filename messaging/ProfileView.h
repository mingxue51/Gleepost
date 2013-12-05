//
//  ProfileView.h
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"
#import "ReflectedImageView.h"

@interface ProfileView : UIView
@property (weak, nonatomic) IBOutlet UIImageView* back;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet ReflectedImageView *reflectedProfileImage;
@property (weak, nonatomic) IBOutlet UISwitch *busyFreeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (weak, nonatomic) IBOutlet UILabel *profileHeadInformation;
@property (weak, nonatomic) IBOutlet UILabel *course;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *busyFreeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *notificationNewBubbleImageView;
@property (weak, nonatomic) IBOutlet UILabel *notificationNewBubbleLabel;

@property(weak, nonatomic) GLPUser* currentUser;


-(void) initialiseView:(GLPUser*)incomingUser;
- (void)showNotificationsBubble:(int)count;
- (void)hideNotificationsBubble;
-(void)setUserDetails:(GLPUser*)incomingUser;
-(void)updateImage:(UIImage*)image;
-(void)updateImageWithUrl:(NSString*)url;
@end
