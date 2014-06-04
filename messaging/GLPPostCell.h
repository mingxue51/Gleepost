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

typedef NS_ENUM(NSInteger, GLPCellType) {
    kTextCell,
    kImageCell,
    kVideoCell
};

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

@protocol GLPPostCellDelegate <NSObject>

@required
-(void)navigateToUsersProfileWithRemoteKey:(NSInteger)remoteKey;

@end

@interface GLPPostCell : UITableViewCell <MainPostViewDelegate>



extern const float IMAGE_CELL_HEIGHT;
extern const float TEXT_CELL_HEIGHT;

@property (assign, nonatomic) UIViewController <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate, GLPPostCellDelegate> *delegate;


-(void)setPost:(GLPPost *)post withPostIndex:(NSInteger)index;

+(CGFloat)getCellHeightWithContent:(GLPPost *)post cellType:(GLPCellType)cellType isViewPost:(BOOL)isViewPost;

-(void)reloadMedia:(BOOL)loadMedia;

-(void)setIsViewPost:(BOOL)isViewPost;

@end
