//
//  TopPostView.h
//  Gleepost
//
//  Created by Silouanos on 16/05/2014.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPPost.h"

@protocol TopPostViewDelegate <NSObject>

@required
- (void)locationPushed;

@end

@interface TopPostView : UIView

@property (weak, nonatomic) UITableViewCell <TopPostViewDelegate> *delegate;

-(void)setElementsWithPost:(GLPPost *)post;
+ (float)getContentLabelSizeForContent:(NSString *)content;
+ (BOOL)isTitleTextOneLineOfCodeWithContent:(NSString *)content;

@end
