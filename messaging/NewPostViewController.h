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
#import "GLPSelectLocationViewController.h"

@interface NewPostViewController : UIViewController <UINavigationControllerDelegate, FDTakeDelegate, UIActionSheetDelegate, PBJVideoPlayerControllerDelegate, UITextViewDelegate, UITextFieldDelegate, GLPSelectLocationViewControllerDelegate>

-(void)hideKeyboard;
-(void)showKeyboard;

@end
