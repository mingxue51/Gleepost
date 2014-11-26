//
//  GLPPendingCell.h
//  Gleepost
//
//  Created by Silouanos on 25/11/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPPendingCell : UITableViewCell

- (void)updateLabelWithNumberOfPendingPosts;
+ (CGFloat)cellHeight;

@end
