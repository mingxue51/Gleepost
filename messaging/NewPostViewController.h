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

@interface NewPostViewController : UIViewController <UINavigationControllerDelegate, FDTakeDelegate, UIActionSheetDelegate, PBJVideoPlayerControllerDelegate, UITextViewDelegate>

//@property (weak, nonatomic) GLPTimelineViewController *delegate;
@property (weak, nonatomic) UIViewController <NewPostDelegate> *delegate;
@property (strong, nonatomic) IBOutlet UINavigationBar *simpleNavBar;

//Used only if the class is call from the groups view controller.
@property (strong, nonatomic) GLPGroup *group;

-(void)doneSelectingDateForEvent:(NSDate *)date andTitle:(NSString *)title;
-(void)cancelSelectingDateForEvent;

-(void)hideKeyboard;
-(void)showKeyboard;

@end
