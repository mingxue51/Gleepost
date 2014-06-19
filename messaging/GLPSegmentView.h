//
//  GLPSegmentView.h
//  Gleepost
//
//  Created by Σιλουανός on 19/6/14.
//  Copyright (c) 2014 Gleepost. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ConversationType) {
    kPrivate,
    kGroup
};

@protocol GLPSegmentViewDelegate <NSObject>

@required
- (void)segmentSwitched:(ConversationType)conversationsType;

@end


@interface GLPSegmentView : UIView

@property (assign, nonatomic) id<GLPSegmentViewDelegate> delegate;

- (void)configuration;

@end
