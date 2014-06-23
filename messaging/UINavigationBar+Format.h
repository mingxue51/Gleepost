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
    kWhite
};

@interface UINavigationBar (Format)

- (void)whiteBackgroundFormat;
- (void)setFontFormatWithColour:(GLPColour)colour;

@end
