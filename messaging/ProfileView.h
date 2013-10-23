//
//  ProfileView.h
//  Gleepost
//
//  Created by Σιλουανός on 15/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileView : UIView
@property (strong, nonatomic) IBOutlet UIImageView* back;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UISwitch *busyFreeSwitch;
@property (strong, nonatomic) IBOutlet UIButton *notificationsButton;
@property (strong, nonatomic) IBOutlet UILabel *profileHeadInformation;

-(void) initialiseView;

@end
