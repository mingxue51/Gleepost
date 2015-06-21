//
//  GroupViewController.h
//  Gleepost
//
//  Created by Silouanos on 04/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPGroup.h"
#import "GLPPostCell.h"
#import "NewPostViewController.h"
#import "DescriptionSegmentGroupCell.h"
#import "GLPGroupStretchedImageView.h"
#import "ImageSelectorViewController.h"

@protocol GroupViewControllerDelegate <NSObject>

- (void)dismissTheWholeViewController;

@end

@interface GroupViewController : UIViewController<ViewImageDelegate, UIActionSheetDelegate, DescriptionSegmentGroupCellDelegate, RemovePostCellDelegate, GLPPostCellDelegate, NewCommentDelegate, GLPImageViewDelegate, ImageSelectorViewControllerDelegate>

@property (weak, nonatomic) UIViewController<GroupViewControllerDelegate> *delegate;

@property (strong, nonatomic) GLPGroup *group;

/** This is used only when the group is navigated from notifications
 in order to focus on the latest user's post.*/
@property (assign, nonatomic) NSInteger postCreatedRemoteKey;
@property (assign, nonatomic) BOOL fromPushNotification;

@property (assign, nonatomic) BOOL fromPushNotificationWithNewMessage;

@end
