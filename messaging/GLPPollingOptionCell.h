//
//  GLPPollingOptionCell.h
//  Gleepost
//
//  Created by Silouanos on 20/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPPollingOptionCellDelegate <NSObject>

@required
- (void)titleTouchedWithIndexRow:(NSInteger)indexRow;

@end

@interface GLPPollingOptionCell : UITableViewCell

@property (assign, nonatomic) UIView<GLPPollingOptionCellDelegate> *delegate;

- (void)setTitle:(NSString *)title withPercentage:(CGFloat)percentage withIndexRow:(NSInteger)indexRow enable:(BOOL)enable;

+ (CGFloat)height;

@end
