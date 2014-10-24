//
//  GLPEmptyView.h
//  Gleepost
//
//  Created by Silouanos on 24/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//


#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, GLPViewPosition) {
    kViewPositionCenter,
    kViewPositionBottom,
    kViewPositionFurtherBottom,
    kViewPositionTop
};

@interface GLPEmptyView : UIView

- (void)hideView;

- (float)yPosition:(GLPViewPosition)viewPosition;

@end
