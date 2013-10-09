//
//  NewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineViewController.h"

@interface NewPostViewController : UIViewController

@property (weak, nonatomic) TimelineViewController *delegate;
@property (strong, nonatomic) IBOutlet UINavigationBar *simpleNavBar;

@end
