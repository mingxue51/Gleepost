//
//  GLPIntroducedProfile.h
//  Gleepost
//
//  Created by Silouanos on 24/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"
#import "ViewTopicViewController.h"

@interface GLPIntroducedProfile : UIView

@property (weak, nonatomic) ViewTopicViewController *delegate;

-(void)updateContents:(GLPUser*)incomingUser;

@end
