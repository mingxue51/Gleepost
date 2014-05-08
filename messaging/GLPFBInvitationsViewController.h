//
//  GLPFBInvitationsViewController.h
//  Gleepost
//
//  Created by Silouanos on 08/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPSearchUserCell.h"
#import "GLPGroup.h"

@interface GLPFBInvitationsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, GLPSearchUserCellDelegate>

@property (strong, nonatomic) GLPGroup *group;

@end
