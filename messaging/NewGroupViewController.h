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

typedef NS_ENUM(NSUInteger, GroupType) {
    kPublicGroup = 0,
    kPrivateGroup = 1,
    kSecretGroup = 2
};

@class GLPGroup;

@protocol GroupCreatedDelegate <NSObject>

@optional
-(void)groupCreatedWithData:(GLPGroup *)group;
-(void)popUpCreateView;

@end

@interface NewGroupViewController : UIViewController <FDTakeDelegate, ImageSelectorViewControllerDelegate>

@property (assign, nonatomic) GroupType groupType;

-(void)setDelegate:(UIViewController<GroupCreatedDelegate> *)delegate;

@end
