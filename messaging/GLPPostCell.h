//
//  GLPPostCell.h
//  Gleepost
//
//  Created by Silouanos on 15/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"
#import "ViewImageDelegate.h"
#import "MainPostView.h"

@protocol RemovePostCellDelegate <NSObject>

-(void)removePostWithPost:(GLPPost *)post;

@end

@protocol NewCommentDelegate <NSObject>

@optional
-(void)setPreviousViewToNavigationBar;
-(void)setPreviousNavigationBarName;
-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle;
-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex;

@end

@interface GLPPostCell : UITableViewCell <MainPostViewDelegate>

extern const float IMAGE_CELL_HEIGHT;
extern const float TEXT_CELL_HEIGHT;

@property (assign, nonatomic) UIViewController <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate> *delegate;


-(void)setPost:(GLPPost *)post withPostIndex:(NSInteger)index;

+(CGFloat)getCellHeightWithContent:(GLPPost *)post image:(BOOL)isImage isViewPost:(BOOL)isViewPost;

-(void)reloadImage:(BOOL)loadImage;

-(void)setIsViewPost:(BOOL)isViewPost;

@end
