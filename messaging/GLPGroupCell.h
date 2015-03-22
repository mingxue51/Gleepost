//
//  GLPGroupCell.h
//  Gleepost
//
//  Created by Silouanos on 23/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPGroup;

@interface GLPGroupCell : UITableViewCell

- (void)setGroupData:(GLPGroup *)groupData;
- (UIImage *)groupImage;
+ (CGFloat)height;
+ (NSString *)cellIdentifier;

@end
