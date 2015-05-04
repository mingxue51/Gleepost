//
//  GLPostTableView.h
//  Gleepost
//
//  Created by Silouanos on 04/05/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPPost;

@interface CLPostTableView : UIView

- (void)setPost:(GLPPost *)post;
- (void)removeObservers;
@end
