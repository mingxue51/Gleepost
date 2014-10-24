//
//  GLPTableActivityIndicator.h
//  Gleepost
//
//  Created by Silouanos on 23/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TableActivityIndicatorPosition) {
    kActivityIndicatorCenter = 0,
    kActivityIndicatorBottom
};

@interface GLPTableActivityIndicator : NSObject

- (id)initWithPosition:(TableActivityIndicatorPosition)position withView:(UIView *)view;
- (void)stopActivityIndicator;
- (void)startActivityIndicator;

@end
