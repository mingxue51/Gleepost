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
#import "TopPostView.h"

typedef NS_ENUM(NSInteger, GLPCellType) {
    kTextCell,
    kImageCell,
    kVideoCell,
    kPollCell
};

@protocol RemovePostCellDelegate <NSObject>

-(void)removePostWithPost:(GLPPost *)post;

@end

@protocol NewCommentDelegate <NSObject>

@optional
-(void)setPreviousViewToNavigationBar;
-(void)setPreviousNavigationBarName;
- (void)navigateToPostForCommentWithIndexPath:(NSIndexPath *)postIndexPath;
-(void)hideNavigationBarAndButtonWithNewTitle:(NSString*)newTitle;
-(void)navigateToViewPostFromCommentWithIndex:(int)postIndex;

@end

@protocol GLPPostCellDelegate <NSObject>

@required
- (void)elementTouchedWithRemoteKey:(NSInteger)remoteKey;
- (void)showLocationWithLocation:(GLPLocation *)location;
//- (void)goingButtonTouched;

@end

@interface GLPPostCell : UITableViewCell <MainPostViewDelegate, TopPostViewDelegate>



extern const float IMAGE_CELL_HEIGHT;
extern const float TEXT_CELL_HEIGHT;

@property (assign, nonatomic) UIViewController <RemovePostCellDelegate, NewCommentDelegate, ViewImageDelegate, GLPPostCellDelegate> *delegate;


-(void)setPost:(GLPPost *)post withPostIndexPath:(NSIndexPath *)indexPath;

+(CGFloat)getCellHeightWithContent:(GLPPost *)post cellType:(GLPCellType)cellType isViewPost:(BOOL)isViewPost;
+(CGSize)getContentLabelSizeForContent:(NSString *)content isViewPost:(BOOL)isViewPost cellType:(GLPCellType)cellType;

-(void)reloadMedia:(BOOL)loadMedia;

-(void)setIsViewPost:(BOOL)isViewPost;

- (void)deregisterNotificationsInVideoView;

- (GLPPost *)viewPost;

@end
