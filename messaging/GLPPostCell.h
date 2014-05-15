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

@interface GLPPostCell : UITableViewCell <UIActionSheetDelegate>

extern const float IMAGE_CELL_HEIGHT;
extern const float TEXT_CELL_HEIGHT;

@property (assign, nonatomic) UIViewController <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate> *delegate;


-(void)updateWithPostData:(GLPPost *)postData withPostIndex:(int)postIndex;

+(CGFloat)getCellHeightWithContent:(GLPPost *)post image:(BOOL)isImage isViewPost:(BOOL)isViewPost;

-(void)reloadImage:(BOOL)loadImage;


@end
