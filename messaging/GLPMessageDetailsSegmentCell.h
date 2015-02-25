//
//  GLPMessageDetailsSegmentCell.h
//  Gleepost
//
//  Created by Silouanos on 18/02/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPSegmentView.h"

@protocol GLPMessageDetailsSegmentCellDelegate <NSObject>

- (void)segmentSwitchedWithButtonType:(ButtonType)conversationsType;

@end

@interface GLPMessageDetailsSegmentCell : UITableViewCell

@property (weak, nonatomic) UIViewController <GLPMessageDetailsSegmentCellDelegate> *delegate;

+ (CGFloat)height;

@end
