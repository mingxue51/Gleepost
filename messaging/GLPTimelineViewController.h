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

@interface GLPTimelineViewController : UIViewController <GLPNewElementsIndicatorViewDelegate, NewCommentDelegate, ViewImageDelegate, RemovePostCellDelegate, GLPPostCellDelegate>

@property BOOL readyToReloadPosts;


-(void)reloadNewLocalPosts;
-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex;
-(void)reloadNewImagePostWithPost:(GLPPost*)inPost;
-(void)refreshPostsWithNewCategory;
-(void)newPostButtonClick;
-(void)loadGroupsFeed;

-(void)loadRegularPosts;

//-(void)showEventPost:(GLPPost *)post;

@end
