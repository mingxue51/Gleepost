//
//  GroupViewController.h
//  Gleepost
//
//  Created by Silouanos on 04/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPGroup.h"
#import "NewCommentDelegate.h"
#import "ViewImageDelegate.h"
#import "FDTakeController.h"
#import "GLPPostCell.h"
#import "NewPostViewController.h"
//#import "GroupTopViewCell.h"


@interface GroupViewController : UIViewController<NewCommentDelegate, ViewImageDelegate, NewPostDelegate, UIActionSheetDelegate/*, GroupTopViewCellDelegate */, FDTakeDelegate, RemovePostCellDelegate, GLPPostCellDelegate>

@property (strong, nonatomic) GLPGroup *group;
@property (assign, nonatomic) BOOL fromPushNotification;
@end
