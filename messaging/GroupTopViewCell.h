//
//  GroupTopViewCell.h
//  Gleepost
//
//  Created by Σιλουανός on 30/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TopTableViewCell.h"
#import "GLPSegmentView.h"

@class GLPGroup;

@protocol GroupTopViewCellDelegate <NSObject>

- (void)showGroupImageOptionsWithImage:(UIImage *)image;
- (void)segmentSwitchedWithButtonType:(ButtonType)buttonType;

@end

@interface GroupTopViewCell : TopTableViewCell <TopTableViewCellDelegate, GLPSegmentViewDelegate>

extern const float GROUP_TOP_VIEW_HEIGHT;

@property (weak, nonatomic) UIViewController <GroupTopViewCellDelegate> *delegate;


- (void)setGroupData:(GLPGroup *)group;
- (void)setDownloadedImage:(UIImage *)image;

@end
