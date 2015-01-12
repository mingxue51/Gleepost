//
//  GLPTriggeredLabel.m
//  Gleepost
//
//  Created by Silouanos on 08/01/15.
//  Copyright (c) 2015 Gleepost. All rights reserved.
//
//  This class is a subclass of GLPLabel. We are doing that in order to implement
//  an extra feature on the label.

#import "GLPTriggeredLabel.h"
#import "UIView+Utils.h"
#import "GLPTriggeredLabelTrackViewsConnector.h"
#import "GLPVisibleViewControllersManager.h"

@implementation GLPTriggeredLabel

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)didMoveToWindow
{
    if(self.window != nil)
    {
        [self observeSuperviewsOnOffsetChange];
    }
}

- (void)dealloc
{
    [self removeAsSuperviewObserver];
}

- (void)observeSuperviewsOnOffsetChange
{
    if(![[GLPVisibleViewControllersManager sharedInstance] isAnyWallIsVisible])
    {
        return;
    }
    
    NSArray *superviews = [self getAllSuperviews];
    
    for (UIView *superview in superviews)
    {
        if([superview respondsToSelector:@selector(contentOffset)])
            [superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeAsSuperviewObserver
{
    if(![[GLPVisibleViewControllersManager sharedInstance] isAnyWallIsVisible])
    {
        return;
    }
    
    NSArray *superviews = [self getAllSuperviews];
    for (UIView *superview in superviews)
    {
        @try
        {
            if([superview respondsToSelector:@selector(contentOffset)])
            {
                [superview removeObserver:self forKeyPath:@"contentOffset"];
            }
        }
        @catch(NSException *exception) {
            
            DDLogDebug(@"Exception %@", exception);
            
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"] && [[GLPTriggeredLabelTrackViewsConnector sharedInstance] needsToAddRemoteKey:self.postRemoteKey])
    {
        [self checkIfFrameIsVisible];
    }
}

- (void)checkIfFrameIsVisible
{
    CGRect myFrameToWindow = [self.window convertRect:self.frame fromView:self];
    
    if(myFrameToWindow.size.width == 0 || myFrameToWindow.size.height == 0) return;
    
//    DDLogDebug(@"-> %f   %ld", myFrameToWindow.origin.y, (long)self.postRemoteKey);
    
    if(myFrameToWindow.origin.y < 500.0 && myFrameToWindow.origin.y > 200.0)
    {
        DDLogDebug(@"Label visible with remote key %ld - %f", (long)self.postRemoteKey, myFrameToWindow.origin.y);
        [[GLPTriggeredLabelTrackViewsConnector sharedInstance] trackPost:_postRemoteKey];
    
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
