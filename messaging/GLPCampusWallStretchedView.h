//
//  GLPCampusWallStretchedView.h
//  Gleepost
//
//  Created by Silouanos on 02/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import "GLPStretchedImageView.h"

@protocol GLPCampusWallStretchedViewDelegate <GLPImageViewDelegate>

@required
- (void)takeALookTouched;

@end

@interface GLPCampusWallStretchedView : GLPStretchedImageView

extern const float kCWStretchedImageHeight;

@property (weak, nonatomic) UIViewController<GLPCampusWallStretchedViewDelegate> *delegate;

@end
