//
//  PickDateEventViewController.h
//  Gleepost
//
//  Created by Silouanos on 10/02/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NewPostViewController.h"

@interface PickDateEventViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) NewPostViewController *delegate;
@property (assign, nonatomic) BOOL isNewPoll;
@property (strong, nonatomic) UIImage *pollImage;

@end
