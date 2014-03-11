//
//  GLPSearchUsersViewController.h
//  Gleepost
//
//  Created by Lukas on 3/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPSearchUserCell.h"
#import "GLPGroup.h"

@interface GLPSearchUsersViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, GLPSearchUserCellDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) GLPGroup *group;
@property (assign, nonatomic) BOOL searchForMembers;
@end
