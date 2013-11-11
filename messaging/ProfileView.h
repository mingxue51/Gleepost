//
//  ProfileView.h
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"

@interface ProfileView : UIView
@property (weak, nonatomic) IBOutlet UIImageView* back;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UISwitch *busyFreeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *notificationsButton;
@property (weak, nonatomic) IBOutlet UILabel *profileHeadInformation;
@property (weak, nonatomic) IBOutlet UILabel *busyFreeLabel;

-(void) initialiseView:(GLPUser*)incomingUser;

@end
