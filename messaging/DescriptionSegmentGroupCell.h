//
//  DescriptionSegmentGroupCell.h
//  Gleepost
//
//  Created by Σιλουανός on 29/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPThreeSegmentView.h"

@class GLPGroup;

@protocol DescriptionSegmentGroupCellDelegate <NSObject>

- (void)showGroupImageOptionsWithImage:(UIImage *)image;
- (void)segmentSwitchedWithButtonType:(ButtonType)buttonType;

@end

@interface DescriptionSegmentGroupCell : UITableViewCell <GLPSegmentViewDelegate>

@property (weak, nonatomic) UIViewController <DescriptionSegmentGroupCellDelegate> *delegate;

- (void)setGroupData:(GLPGroup *)group;

+ (float)getCellHeightWithGroup:(GLPGroup *)group;

@end
