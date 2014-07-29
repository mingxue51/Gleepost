//
//  UILabel+Dimensions.m
//  Gleepost
//
//  Created by Σιλουανός on 29/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import "UILabel+Dimensions.h"

@implementation UILabel (Dimensions)

- (void)setHeightDependingOnText:(NSString *)text withFont:(UIFont *)font
{
    if(!text)
    {
        return;
    }
    
    CGRectSetH(self, [self getContentLabelSizeForContent:text withFont:font]);
}

- (float)getContentLabelSizeForContent:(NSString *)content withFont:(UIFont *)font
{
    int maxWidth = self.frame.size.width;
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){maxWidth, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    return rect.size.height;
}

+ (float)getContentLabelSizeForContent:(NSString *)content withFont:(UIFont *)font andWidht:(float)labelWidth
{
    if(!content)
    {
        return 1.0;
    }
    
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName: font}];
    
    CGRect rect = [attributedText boundingRectWithSize:(CGSize){labelWidth, CGFLOAT_MAX}
                                               options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    return rect.size.height;
}

@end
