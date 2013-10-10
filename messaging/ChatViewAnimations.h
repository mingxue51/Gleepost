//
//  ChatViewAnimations.h
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullDownScrollView.h"
#import "ChatViewController.h"

@interface ChatViewAnimations : UIView
{
    BOOL animationsFinished;
}

@property (strong, nonatomic) UIImageView *centralCircle;
@property (strong, nonatomic) NSMutableArray *bubblesOnTheScreen;
@property (strong, nonatomic) NSMutableArray *bubblesOffTheScreen;

@property (strong, nonatomic) PullDownScrollView *pullDownScrollView;
@property (strong, nonatomic) NSTimer *timer1;
@property (strong, nonatomic) NSTimer *timer2;
@property (strong, nonatomic) ChatViewController *chatViewController;


-(void) animateCirclesFancy;
-(void) removeElements;
-(void) navigateToNewRandomChat;

@end
