//
//  MainPostView.h
//  Gleepost
//
//  Created by Silouanos on 16/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"
#import "GLPLabel.h"

@protocol MainPostViewDelegate <NSObject>

@required

-(void)viewPostImage:(id)sender;
-(void)navigateToProfile:(id)sender;
-(void)showViewOptionsWithActionSheer:(UIActionSheet *)actionSheet;
-(void)showShareViewWithItems:(UIActivityViewController *)shareItems;
-(void)deleteCurrentPost;
-(void)commentButtonSelected;

@end

@interface MainPostView : UIView <UIActionSheetDelegate, GLPLabelDelegate>

@property (assign, nonatomic) UITableViewCell <MainPostViewDelegate> *delegate;

-(void)setElementsWithPost:(GLPPost *)post withViewPost:(BOOL)viewPost;

-(void)setHeightDependingOnLabelHeight:(float)height andIsViewPost:(BOOL)isViewPost;

-(NSString *)content;

- (void)setMediaNeedsToReload:(BOOL)imageNeedsToReload;

- (void)deregisterNotificationsForVideoView;

-(IBAction)moreOptions:(id)sender;

@end
