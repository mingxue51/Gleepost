//
//  NewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDTakeController.h"
#import "GLPVideoViewController.h"
@class GLPPost;
@class GLPGroup;

@protocol NewPostDelegate <NSObject>

@required
-(void)reloadNewImagePostWithPost:(GLPPost *)post;

@end

@interface NewPostViewController : UIViewController <UINavigationControllerDelegate, FDTakeDelegate, UIActionSheetDelegate, PBJVideoPlayerControllerDelegate, UITextViewDelegate, UITextFieldDelegate>

//@property (weak, nonatomic) GLPTimelineViewController *delegate;
@property (weak, nonatomic) UIViewController <NewPostDelegate> *delegate;

//Used only if the class is call from the groups view controller.
@property (strong, nonatomic) GLPGroup *group;

-(void)hideKeyboard;
-(void)showKeyboard;

@end
