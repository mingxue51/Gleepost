//
//  GLPPollingOptionCell.h
//  Gleepost
//
//  Created by Silouanos on 20/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPPollingOptionCell : UITableViewCell

- (void)setTitle:(NSString *)title withPercentage:(CGFloat)percentage enable:(BOOL)enable;

+ (CGFloat)height;

@end
