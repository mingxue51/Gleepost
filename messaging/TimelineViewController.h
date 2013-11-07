//
//  TimelineViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"

@interface TimelineViewController : UITableViewController

@property BOOL readyToReloadPosts;


- (void)loadPosts;
-(void)likeButtonPushed: (id)sender;
-(void)commentButtonPushed: (id)sender;
-(void)shareButtonPushed: (id)sender;
-(void) setPlusButtonToNavigationBar;
-(void)setNavigationBarName;
-(void)addNewPost:(GLPPost*)post;

@end
