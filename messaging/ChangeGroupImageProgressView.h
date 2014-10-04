//
//  ChangeGroupImageProgressView.h
//  Gleepost
//
//  Created by Silouanos on 03/10/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPGroup;

@interface ChangeGroupImageProgressView : UIProgressView

- (void)setGroup:(GLPGroup *)group;
- (GLPGroup *)group;

@end
