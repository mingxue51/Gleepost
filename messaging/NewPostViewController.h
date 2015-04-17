//
//  NewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "FDTakeController.h"
#import "GLPVideoViewController.h"
#import "GLPSelectLocationViewController.h"
#import "ImageSelectorViewController.h"

@interface NewPostViewController : UIViewController <UINavigationControllerDelegate, PBJVideoPlayerControllerDelegate, UITextViewDelegate, UITextFieldDelegate, GLPSelectLocationViewControllerDelegate, ImageSelectorViewControllerDelegate>

@property (assign, nonatomic) BOOL comesFromFirstView;

-(void)hideKeyboard;
-(void)showKeyboard;

@end
