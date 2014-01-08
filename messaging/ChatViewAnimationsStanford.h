//
//  ChatViewAnimationsStanford.h
//  Gleepost
//
//  Created by Σιλουανός on 7/1/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"
#import "ImageFormatterHelper.h"
#import "PullDownScrollView.h"

@interface ChatViewAnimationsStanford : UIView

@property (strong, nonatomic) ChatViewController *chatViewController;

//@property (strong, nonatomic) UIImageView *centralCircle;
@property (strong, nonatomic) NSMutableArray *clouds;

@property (strong, nonatomic) PullDownScrollView *pullDownScrollView;
@property (strong, nonatomic) NSTimer *timer1;
@property (strong, nonatomic) NSTimer *timer2;


-(void)removeElements;

@end
