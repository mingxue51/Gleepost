//
//  TimelineViewController.h
//  messaging
//
//  Created by Lukas on 8/19/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TimelineViewController : UITableViewController
- (void)loadPosts;
-(void)likeButtonPushed: (id)sender;
-(void)commentButtonPushed: (id)sender;
-(void)shareButtonPushed: (id)sender;
-(void) setPlusButtonToNavigationBar;

@end
