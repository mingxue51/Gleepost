//
//  LiveChatsView.h
//  Gleepost
//
//  Created by Σιλουανός on 22/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LiveChatsView : UIView

+ (id)loadingViewInView:(UIView *)aSuperview;
- (void)removeView;
+ (BOOL)visible;
+(void) setVisibility:(BOOL)vis;

@end
