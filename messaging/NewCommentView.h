//
//  NewCommentView.h
//  Gleepost
//
//  Created by Σιλουανός on 4/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimelineViewController.h"


@interface NewCommentView : UIView <UITextViewDelegate>
{
    float keyboardHeight;
}

@property (strong, nonatomic) TimelineViewController* delegate;

+ (id)loadingViewInView:(UIView *)aSuperview;
- (void)removeView;
-(void) cancelPushed: (id)sender;


@end
