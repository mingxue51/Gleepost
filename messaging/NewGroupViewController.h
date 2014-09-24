//
//  NewGroupViewController.h
//  Gleepost
//
//  Created by Silouanos on 05/03/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"
#import "ImageSelectorViewController.h"

#import "GLPGroup.h"

@protocol GroupCreatedDelegate <NSObject>

@optional
-(void)groupCreatedWithData:(GLPGroup *)group;
-(void)popUpCreateView;

@end

@interface NewGroupViewController : UIViewController <FDTakeDelegate, ImageSelectorViewControllerDelegate>

@property (assign, nonatomic) GroupPrivacy groupType;

-(void)setDelegate:(UIViewController<GroupCreatedDelegate> *)delegate;

@end
