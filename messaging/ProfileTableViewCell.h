//
//  ProfileTableViewCell.h
//  Gleepost
//
//  Created by Silouanos on 09/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"

@interface ProfileTableViewCell : UITableViewCell

-(void)initialiseElementsWithUserDetails:(GLPUser *)user;

@end
