//
//  ProfileAboutTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"

@interface ProfileAboutTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UILabel *lockLabel;
@property (weak, nonatomic) IBOutlet UILabel *informationLabel;

-(void)updateUserDetails:(GLPUser *)user;
@end
