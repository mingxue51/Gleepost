//
//  GLPLikesCell.h
//  Gleepost
//
//  Created by Silouanos on 15/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GLPLikesCell : UITableViewCell

- (void)setLikedUsers:(NSArray *)users;
+ (CGFloat)height;

@end
