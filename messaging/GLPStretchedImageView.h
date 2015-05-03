//
//  GLPGroupStretchedImageView.h
//  Gleepost
//
//  Created by Silouanos on 02/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPImageView.h"

@interface GLPStretchedImageView : GLPImageView<GLPImageViewDelegate>

- (void)configureTransparentImageView;
- (void)setHeightOfTransImage:(float)height;
- (void)setColourOverlay:(UIColor *)colourOverlay;
- (void)setAlphaOverlay:(CGFloat)alpha;

@end
