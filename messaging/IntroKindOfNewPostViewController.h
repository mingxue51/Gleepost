//
//  IntroKindOfNewPostViewController.h
//  Gleepost
//
//  Created by Σιλουανός on 14/8/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPGroup;

@interface IntroKindOfNewPostViewController : UIViewController

@property (assign, nonatomic) BOOL groupPost;
@property (strong, nonatomic) GLPGroup *group;
/** We are going to change the status bar colour depending on the variable (comes from the previous VC). */
@property (assign, nonatomic) BOOL navBarTransparentMode;

@end
