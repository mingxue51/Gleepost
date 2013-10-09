//
//  PullDownScrollView.h
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#define REFHEIGHT   10

@class ChatViewAnimations;

@interface PullDownScrollView : UIScrollView<UIScrollViewDelegate>
{
    BOOL isLoading;
    BOOL isDraging;
}

@property (strong, nonatomic) UIImageView *pullDownImageView;
@property (readonly, nonatomic) ChatViewAnimations *chatViewAnimations;


-(void) setChatViewAnimations:(ChatViewAnimations *)chatViewAnimations;

@end
