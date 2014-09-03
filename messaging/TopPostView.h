//
//  TopPostView.h
//  Gleepost
//
//  Created by Silouanos on 16/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"
#import "MainPostView.h"

@protocol TopPostViewDelegate <NSObject>

@required
- (void)locationPushed;

@end

@interface TopPostView : UIView

@property (weak, nonatomic) UITableViewCell <TopPostViewDelegate> *delegate;

//TODO: Check that if limits the performance of table view.
@property (strong, nonatomic) MainPostView *mainPostView;

-(void)setElementsWithPost:(GLPPost *)post;
+ (float)getContentLabelSizeForContent:(NSString *)content;
+ (BOOL)isTitleTextOneLineOfCodeWithContent:(NSString *)content;

@end
