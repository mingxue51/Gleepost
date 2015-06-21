//
//  GLPLikesCell.h
//  Gleepost
//
//  Created by Silouanos on 15/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GLPLikesCellDelegate <NSObject>

@required
- (void)likesCellTouched;

@end

@interface GLPLikesCell : UITableViewCell

@property (weak, nonatomic) UIViewController<GLPLikesCellDelegate> *delegate;

- (void)setLikedUsers:(NSArray *)users withAnimation:(BOOL)animation;
- (void)setLikedUsers:(NSArray *)users;
+ (CGFloat)height;

@end
