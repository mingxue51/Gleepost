//
//  GLPTimelineViewController.h
//  Gleepost
//
//  Created by Lukas on 11/9/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPpost.h"
#import "GLPNewElementsIndicatorView.h"
#import "NewCommentDelegate.h"
#import "ViewImageDelegate.h"

@interface GLPTimelineViewController : UITableViewController <GLPNewElementsIndicatorViewDelegate, NewCommentDelegate, ViewImageDelegate>

@property BOOL readyToReloadPosts;


-(void)reloadNewLocalPosts;
-(void)likeButtonPushed:(id)sender;
-(void)commentButtonPushed:(id)sender;
-(void)shareButtonPushed:(id)sender;
-(void)setPlusButtonToNavigationBar;
-(void)setNavigationBarName;
-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex;
-(void)reloadNewImagePostWithPost:(GLPPost*)inPost;

@end
