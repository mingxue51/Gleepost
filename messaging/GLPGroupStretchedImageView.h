//
//  GLPStretchedImageView.h
//  Gleepost
//
//  Created by Σιλουανός on 28/7/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLPStretchedImageView.h"

@interface GLPGroupStretchedImageView : GLPStretchedImageView

extern const float kStretchedImageHeight;

- (void)setTextInTitle:(NSString *)text;
//- (void)setHeightOfTransImage:(float)height;
//- (void)setColourOverlay:(UIColor *)colourOverlay;

@end
