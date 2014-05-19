//
//  MainPostView.h
//  Gleepost
//
//  Created by Silouanos on 16/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"

@protocol MainPostViewDelegate <NSObject>

@required

-(void)viewPostImage:(id)sender;
-(void)showViewOptionsWithActionSheer:(UIActionSheet *)actionSheet;
-(void)showShareViewWithItems:(UIActivityViewController *)shareItems;
-(void)deleteCurrentPost;
-(void)commentButtonSelected;

@end

@interface MainPostView : UIView <UIActionSheetDelegate>

@property (assign, nonatomic) UITableViewCell <MainPostViewDelegate> *delegate;

-(void)setElementsWithPost:(GLPPost *)post withViewPost:(BOOL)viewPost;

-(void)setNewHeightDependingOnLabelHeight:(float)height;

-(NSString *)content;

@end
