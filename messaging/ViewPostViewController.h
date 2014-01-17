//
//  ViewPostViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"
#import "HPGrowingTextView.h"
#import "NewCommentDelegate.h"
#import "ViewImageDelegate.h"


@interface ViewPostViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, HPGrowingTextViewDelegate, NewCommentDelegate, ViewImageDelegate>

@property (strong, nonatomic) GLPPost *post;
//TODO: Remove after the integration of image posts.
@property (assign, nonatomic) int selectedUserId;
@property (assign, nonatomic) BOOL commentJustCreated;
@property (assign, nonatomic) BOOL isViewPostNotifications;


//-(float) calculateCommentSize: (NSString*) content;
-(void)navigateToProfile: (id)sender;
-(void)viewPostImage:(UIImage*)postImage;


@end
