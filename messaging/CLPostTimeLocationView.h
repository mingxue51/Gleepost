//
//  CLPostTimeLocationView.h
//  Gleepost
//
//  Created by Silouanos on 06/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPLocation;

@interface CLPostTimeLocationView : UIView

- (void)setLocation:(GLPLocation *)location andTime:(NSDate *)time;

@end
