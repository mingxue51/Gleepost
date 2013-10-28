//
//  LiveChatsView.h
//  Gleepost
//
//  Created by Σιλουανός on 22/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewTopicViewController.h"

@interface LiveChatsView : UIView

@property (weak, nonatomic) ViewTopicViewController *viewTopic;

+ (id)loadingViewInView:(UIView *)aSuperview;
- (void)removeView;
+ (BOOL)visible;
+(void) setVisibility:(BOOL)vis;

@end
