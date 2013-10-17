//
//  ViewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface ViewPostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) Post *post;
//TODO: Remove after the integration of image posts.
@property int selectedIndex;

-(float) calculateCommentSize: (NSString*) content;

@end
