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
#import "FDTakeController.h"
#import "GLPPostCell.h"
#import "NewPostViewController.h"
#import "DescriptionSegmentGroupCell.h"
#import "GLPStretchedImageView.h"
#import "ViewPostImageViewController.h"

@interface GroupViewController : UIViewController<NewCommentDelegate, ViewImageDelegate, UIActionSheetDelegate, DescriptionSegmentGroupCellDelegate, FDTakeDelegate, RemovePostCellDelegate, GLPPostCellDelegate, GLPImageViewDelegate>

@property (strong, nonatomic) GLPGroup *group;
@property (assign, nonatomic) BOOL fromPushNotification;
@end
