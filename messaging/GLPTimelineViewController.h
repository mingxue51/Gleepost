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
#import "ViewImageDelegate.h"
#import "GLPPostCell.h"

@interface GLPTimelineViewController : UITableViewController <GLPNewElementsIndicatorViewDelegate, NewCommentDelegate, ViewImageDelegate, RemovePostCellDelegate, GLPPostCellDelegate>

@property BOOL readyToReloadPosts;


-(void)reloadNewLocalPosts;
-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex;
-(void)reloadNewImagePostWithPost:(GLPPost*)inPost;
-(void)refreshPostsWithNewCategory;
-(void)newPostButtonClick;
-(void)showCategories:(id)sender;

-(void)loadGroupsFeed;

-(void)loadRegularPosts;

//-(void)showEventPost:(GLPPost *)post;

@end
