//
//  ChatViewAnimations.h
//  Gleepost
//
//  Created by Σιλουανός on 8/10/13.
//  Copyright (c) 2013 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PullDownScrollView.h"


@interface ChatViewAnimations : UIView

@property (strong, nonatomic) UIImageView *centralCircle;
@property (strong, nonatomic) NSMutableArray *cirlcles;
@property (strong, nonatomic) PullDownScrollView *pullDownScrollView;

@end
