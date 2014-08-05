//
//  UINavigationBar+Format.h
//  Gleepost
//
//  Created by Σιλουανός on 23/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, GLPColour) {
    kRed,
    kBlack,
    kWhite,
    kGreen
};

@interface UINavigationBar (Format)

- (void)whiteBackgroundFormatWithShadow:(BOOL)shadow;
- (void)whiteBackgroundFormatWithShadow:(BOOL)shadow andView:(UIView *)view;
- (void)invisible;
- (void)makeVisibleWithTitle:(NSString *)title;
- (void)setFontFormatWithColour:(GLPColour)colour;
- (void)setCampusWallFontFormat;

@end
