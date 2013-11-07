//
//  NewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineViewController.h"
#import "FDTakeController.h"

@interface NewPostViewController : UIViewController <UINavigationControllerDelegate, FDTakeDelegate>

@property (weak, nonatomic) TimelineViewController *delegate;
@property (strong, nonatomic) IBOutlet UINavigationBar *simpleNavBar;
@property (strong, nonatomic) UIImageView *uploadedImage;
@property BOOL imagePosted;
@property BOOL imageReady;
- (IBAction)addImage:(id)sender;

@end
