//
//  GLPProfileViewController.h
//  Gleepost
//
//  Created by Silouanos on 10/12/2013.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"
#import "NSObject_ProfileEnums.h"

@interface GLPProfileViewController : UITableViewController


@property (strong, nonatomic) GLPPost *selectedPost;
@property (assign, nonatomic) int selectedUserId;

-(void)viewSectionWithId:(GLPSelectedTab) selectedTab;
-(void)popUpNotifications:(id)sender;

@end
