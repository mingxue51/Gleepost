//
//  PollingPostView.h
//  Gleepost
//
//  Created by Silouanos on 17/04/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLPPoll;
@class GLPPost;

@interface PollingPostView : UIView

- (void)setPollData:(GLPPoll *)pollData;
+ (CGFloat)pollingTitleHeightWithText:(NSString *)text;
+ (CGFloat)cellHeightWithPostData:(GLPPost *)postData;

@end
