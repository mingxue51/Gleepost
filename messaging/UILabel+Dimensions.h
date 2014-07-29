//
//  UILabel+Dimensions.h
//  Gleepost
//
//  Created by Σιλουανός on 29/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Dimensions)

- (void)setHeightDependingOnText:(NSString *)text withFont:(UIFont *)font;
+ (float)getContentLabelSizeForContent:(NSString *)content withFont:(UIFont *)font andWidht:(float)labelWidth;

@end
