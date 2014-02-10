//
//  GLPIntroducedProfile.h
//  Gleepost
//
//  Created by Silouanos on 24/01/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPUser.h"
#import "GLPConversationViewController.h"

@interface GLPIntroducedProfile : UIView

@property (weak, nonatomic) GLPConversationViewController *delegate;

-(void)updateContents:(GLPUser*)incomingUser;
-(void)addUser:(id)sender;
@end
